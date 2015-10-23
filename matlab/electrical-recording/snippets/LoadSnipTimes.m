function [time,header] = LoadSnipTimes(filename,channel,nsnips)
% LoadSnipTimes: load the snippet times from a given channel in one file
% [time,header] = LoadSnipTimes(filename,channel)
[fid,message] = fopen(filename,'r', 'b');
if (fid < 1)
	error(message)
end
header = ReadSnipHeader(fid);
width = header.sniprange(2)-header.sniprange(1)+1;
chindx = find(header.channels == channel);
time = [];
if (~isempty(chindx))
	if (nargin<3)
		nsnips = header.numofsnips(chindx);
	else
		nsnips=min(nsnips,header.numofsnips(chindx));
	end
	fseek(fid,header.timesfpos(chindx),'bof');
	time = fread(fid,nsnips,'int32');
end
