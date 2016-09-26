function [txtout,vlabel] = ParseUsrHdr(usrhdr)
% ParseUsrHdr: interpret the text placed in the AI file header
% [txtout,vlabel] = ParseUsrHdr(usrhdr)
% txtout is a cell array, where txtout{i} is one return-delimited
% line of the user header
% vlabel is a cell array from 1:12, where each line contains the text
% describing the corresponding valve contents
%	(it is assumed that the valve number appears at the beginning
%	 of the relevant line)
s = char(usrhdr);
ret = sprintf('\n');
[txtout{1},r] = strtok(s,ret);
while (~isempty(r))
	s = r;
	[txtout{end+1},r] = strtok(s,ret);
	if (isempty(txtout{end}))
		txtout(end) = [];
	end
end
for i = 1:length(txtout)
	disp(txtout{i});
end
if (nargout > 1)
	vlabel = cell(1,12);
	for i = 1:length(txtout)
		vnum = sscanf(txtout{i},'%d');
		if (isnumeric(vnum))
			vlabel{vnum} = txtout{i};
		end
	end
end
