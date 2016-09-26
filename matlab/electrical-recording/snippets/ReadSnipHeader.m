function [header,headersize] = ReadSnipHeader(file)
% [header,headersize] = ReadSnipHeader(file)
% Read the header from the snippet cutter
% If "file" is a string, it's treated as a filename
% If "file" is numeric, it's treated as a file identifier
if (ischar(file))
	[fid,message] = fopen(file,'r', 'b');
	if (fid < 1)
		error(message);
	end
elseif (isnumeric(file))
	fid = file;
else
	error(['Do not recognize input ',file]);
end
header = ReadAIHeader(fid);
header.sniptype = fread(fid,1,'int16');
header.snipbeginoffset = fread(fid,1,'int16');
header.snipendoffset = fread(fid,1,'int16');
header.thresh = fread(fid,header.numch,'float32');
header.numofsnips = fread(fid,header.numch,'int32');
header.timesfpos = fread(fid,header.numch,'uint32');
header.snipsfpos = fread(fid,header.numch,'uint32');
header.sniprange = [header.snipbeginoffset header.snipendoffset];
if (ischar(file))
	fclose(fid);
end
return
%For checking snippet times and first N snippets on first channel
%snipsize=header.snipendoffset-header.snipbeginoffset+1;
%N=500
%for i=1:header.numch
%	for j=1:header.numofsnips(i)
%		header.times(i,j) = fread(fid,1,'int32');
%	end
%end
%for i=1:1
%	for j=1:N
%		for k=1:snipsize
%		header.points(k,j,i) = fread(fid,1,'int16');
%		end
%	end
%end
