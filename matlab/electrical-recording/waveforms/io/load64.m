function [data,header] = load64(filename,time)
% [data,header] = load64(filename,timerange)
% load 64-channel binary data from LabView.
% timerange is an optional 2-vector, indicating
% the range [,) to load in (in seconds),
% with 0 being the first point in the file.
% If timerange is absent, the whole file is loaded.
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
%header = ReadAIHeaderAncient(fid);
header = ReadAIHeader(fid);
% End of header
ShowAIHeader(header)
if (nargin == 2)
	data = ReadBinaryData(fid,header.numch,round(time*header.scanrate));
else
	data = ReadBinaryData(fid,header.numch);
end
fclose(fid);
% Convert to microvolts
for i = 1:header.numch
	data(i,:) = (data(i,:)*header.scalemult + header.scaleoff)/0.0147;
end
