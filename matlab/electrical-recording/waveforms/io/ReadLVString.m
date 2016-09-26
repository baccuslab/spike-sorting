function str = ReadLVString(fid)
% read a LabVIEW string
strlen = fread(fid,1,'int32');
str = char(fread(fid,strlen,'uchar'));
if (size(str,2) == 1)
	str = str';
end
