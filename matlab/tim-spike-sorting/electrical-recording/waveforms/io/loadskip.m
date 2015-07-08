function [data,header] = loadskip(filename,skip)
% [data,header] = loadskip(filename,skip)
% load binary data from LabView.
% if skip = 0, all points are read in
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header = ReadAIHeader(fid);
% End of header
ShowAIHeader(header)
data = ReadBinaryDataSkip(fid,skip);
fclose(fid);
	data = data*header.scalemult + header.scaleoff;
