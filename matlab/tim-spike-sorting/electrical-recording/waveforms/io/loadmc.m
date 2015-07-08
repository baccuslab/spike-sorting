function [data,header] = loadmc(filename,time)
% [data,header] = loadmc(filename,timerange)
% Like load64, except doesn't account for gain of amplifier
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
header = ReadAIHeader(fid);
% End of header
ShowAIHeader(header)
if (nargin == 2)
	data = ReadBinaryData(fid,header.numch,round(time*header.scanrate));
else
	data = ReadBinaryData(fid,header.numch);
end
fclose(fid);
% Convert to volts
%for i = 1:header.numch
%	data(i,:) = data(i,:)*header.scalemult + header.scaleoff;
%end
