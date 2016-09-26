function [data,header] = load64(filename,channel,time)
% [data,header] = load1from64(filename,channel,timerange)
% load 1 channel out of 64 of binary data.
% (channels numbers are unit-offset)
% timerange is an optional 2-vector, indicating
% the range [,) to load in (in seconds),
% with 0 being the first point in the file.
% If timerange is absent, the whole file is loaded.
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header = ReadAIHeader(fid);
% End of header
ShowAIHeader(header)
% Advance to channel of interest
status = fseek(fid,(channel-1)*2,'cof'); % *2 because int16s
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
% Convert to microvolts
data = (data*header.scalemult + header.scaleoff)/0.0147;
