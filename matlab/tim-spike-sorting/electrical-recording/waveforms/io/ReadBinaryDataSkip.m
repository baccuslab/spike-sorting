function data = ReadBinaryDataSkip(fid,numch,range)
% data = ReadBinaryDataSkip(fid,numch,range)
% Read data from the file with ID fid,
% into a vector. Skips the number of channels given by numch.
% The range argument (optional) gives the range [,)
% in scans for reading from the current position
% If omitted, reads the rest of the file
if (nargin == 3)
	nsamp = range(2) - range(1);
	status = fseek(fid,numch*range(1)*2,'cof'); % *2 because int16s
	if status
		error(ferror(fid))
	end
	data = fread(fid,nsamp,'int16',(numch-1)*2);
else
	data = fread(fid,Inf,'int16',(numch-1)*2);
end
