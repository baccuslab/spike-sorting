function [range,outbounds] = BuildRangeMF(nsnips,fr)
% BuildRangeMF: for selecting a subrange of snippets across many files
% nsnips is a vector containing the number of snippets/file
% fr: "fraction" or "range": if fr is a scalar 0 <= fr <= 1,
%   a constant fraction fr will be loaded from each file. If
%   fr is a 2-vector, a range of snippets will be loaded, where
%   the numbering is continuous across file boundaries
% range is a 2-by-n matrix giving the range within each file
%   to load to give the desired total
% If more are requested than available, outbounds is set to 1
if (length(fr) == 1)
	if (fr > 1 | fr < 0)
		error('Illegal fraction');
	end
	nload = ceil(fr*nsnips);
	range = [ones(1,length(nload)); nload];
elseif (length(fr) == 2)
	cumsnips = cumsum(nsnips);
	cumrange = [1,cumsnips(1:end-1)+1; cumsnips];
	for i = 1:length(nsnips)
		start = cumrange(1,i)-1;
		range(:,i) = overlap(cumrange(:,i),fr) - [start;start];
	end
	outbounds = 0;
	nload = diff(range)+1;
	if (sum(nload) ~= fr(2)-fr(1)+1)
		outbounds = 1;
	end
end

function rangeo = overlap(range1,range2)
maxmins = max(range1(1),range2(1));
minmaxs = min(range1(2),range2(2));
if (maxmins > minmaxs)
	rangeo = [range1(1);range1(1)-1];		% Will result in [1 0] in calling line above
else
	rangeo = [maxmins;minmaxs];
end
