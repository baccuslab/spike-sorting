function [data,header] = load1channel(filename,channel,time)
% load1channel: load 1 channel of AI data, from a file which contains multiple channels.
% [data,header] = load1channel(filename,channel,timerange)
% timerange is an optional 2-vector, indicating
% 	the range [,) to load in (in seconds) (default: whole file).
% 0 is the first point in the file.
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header = ReadAIHeader(fid);
chindx = find(header.channels == channel);
if (isempty(chindx))
	error('Selected channel was not recorded');
end
% Advance to channel of interest
status = fseek(fid,(chindx-1)*2,'cof'); % *2 because int16s
if status
	error(ferror(fid))
end
% Read in data
if (nargin == 3)
	data = ReadBinaryDataSkip(fid,header.numch,round(time*header.scanrate));
else
	data = ReadBinaryDataSkip(fid,header.numch);
end
fclose(fid);
% Convert to volts
data = data*header.scalemult + header.scaleoff;
