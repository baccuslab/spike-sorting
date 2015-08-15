function [header,headersize] = ReadEigHeader(fid)
% [header,headersize] = ReadEigHeader(fid)
% Read the header from .eig files
headersize = fread(fid,1,'uint32');
header.type = fread(fid,1,'int16');
if (header.type ~= 2)
	error('File is not eig type');
end
header.version = fread(fid,1,'int16');
header.threshu = fread(fid,1,'float32');
header.threshp = fread(fid,1,'float32');
header.polarity = fread(fid,1,'int16');
header.neig = fread(fid,1,'int16');
header.left = fread(fid,1,'int16');
header.right = fread(fid,1,'int16');
header.dt = fread(fid,1,'float32');
header.scalemult = fread(fid,1,'float32');
header.totvar = fread(fid,1,'float32');
