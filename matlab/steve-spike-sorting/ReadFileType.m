function [header,headersize] = ReadFileType(file)
% ReadAIType: Get AI file type
% If "file" is a string, it's treated as a filename
% If "file" is numeric, it's treated as a file identifier
if (ischar(file))
	[fid,message] = fopen(file,'r','ieee-be');
	if (fid < 1)
		error(message);
	end
elseif (isnumeric(file))
	fid = file;
else
	error(['Do not recognize input ',file]);
end
headersize = fread(fid,1,'uint32');
header.type = fread(fid,1,'int16');
header.version = fread(fid,1,'int16');
