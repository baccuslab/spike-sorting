function [snip,time,header] = LoadSnip(filename,channel,maxsnip)
% LoadSnip: load the snippets from a given channel in one file
% [snip,time,header] = LoadSnip(filename,channel,maxsnip)
% The third argument (maxsnip) is optional; at most maxsnip snippets
%	will be read, with the default behavior to read all the snippets
% snip is returned in units of volts. This is the only reliable choice for sorting, as
%	the user might change the A/D scaling between files.
[fid,message] = fopen(filename,'r', 'b');
if (fid < 1)
	error(message)
end
header = ReadSnipHeader(fid);
width = header.sniprange(2)-header.sniprange(1)+1;
chindx = find(header.channels == channel);
if (isempty(chindx))
	snip = [];
	time = [];
	return;
end
nsnips = header.numofsnips(chindx);
if (nargin == 3)
	if (maxsnip >= 0 & maxsnip < nsnips)
		nsnips = maxsnip;
	end
end
fseek(fid,header.timesfpos(chindx),'bof');
time = fread(fid,nsnips,'int32');
fseek(fid,header.snipsfpos(chindx),'bof');
snip = fread(fid,[width,nsnips],'int16')*header.scalemult + header.scaleoff;
%snip = fread(fid,[width,nsnips],'int16');
header.thresh = header.thresh*header.scalemult + header.scaleoff;
