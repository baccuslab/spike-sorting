function [data,header] = load64stupid(filename,time)
% [data,header] = load64stupid(filename,timerange)
% load 64-channel binary data from LabView.
% timerange is an optional 2-vector, indicating
% the range [,) to load in (in seconds),
% with 0 being the first point in the file.
% If timerange is absent, the whole file is loaded.
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
headersize = fread(fid,1,'uint32');
header = fread(fid,headersize,'char');
% End of header
if (nargin == 2)
	data = ReadBinaryData(fid,64,time*15000);
else
	data = ReadBinaryData(fid,64);
end
fclose(fid);
