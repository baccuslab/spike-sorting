function snip = CutSnippets(filename,channel,times,sniprange)
% CutSnippets: cut AI snippets at particular times from 1 channel
% snip = CutSnippets(filename,channel,sniprange,times)
% where
%	filename is the name of the AI data file (.bin extension)
%	channel is the channel #
%	times is a vector of scan number offsets
%	sniprange is a 2-vector spanning the time of the snippet (in scan #s)
% The ith snippet is cut from the range: times(i)+sniprange
% Note for industrial cutting of snippets (triggered on thresh crossing),
% use the C programs instead.
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header = ReadAIHeader(fid);
cpos = ftell(fid);
% Convert times to file offsets
chindx = find(header.channels == channel);
if (isempty(chindx))
	error('Selected channel was not recorded');
end
tpos = 2*(times*header.numch + chindx-1 + sniprange(1));   % factor of 2 cuz int16s
tindx = find(tpos >= 0 & times+sniprange(2) < header.nscans);
if (length(tindx) < length(tpos))
	warning('Some of the selected snippets extended beyond file boundaries, and were not cut');
end
fpos = tpos(tindx) + cpos;		% relative to end of header
ntimes = length(fpos);
width = sniprange(2)-sniprange(1)+1;
snip = zeros(width,ntimes);
for i = 1:ntimes
	fseek(fid,fpos(i),'bof');
	snip(:,i) = fread(fid,width,'int16',2*(header.numch-1));
end
fclose(fid);
snip = snip*header.scalemult + header.scaleoff;
