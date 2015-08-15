function [d,h] = loadanc(filename,time);
[fid,message] = fopen(filename,'r');
if (fid < 1)
	error(message)
end
h = ReadAIHeaderAncient(fid);
d = ReadBinaryData(fid,h.numch,round(time*h.scanrate));
fclose(fid);
% Convert to microvolts
for i = 1:h.numch
	d(i,:) = (d(i,:)*h.chinfo(i).scalemult + h.chinfo(i).scaleoff)/0.0147;
end
