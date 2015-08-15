function [header,headersize] = ReadAIBHeader(file)
% ReadAIBHeader: Read the header from raw waveform files (AI = analog input)
% [header,headersize] = ReadAIBHeader(file)
% AI files are written either by (version 1) the
%	LabVIEW VI 'create AI binary header.vi,' or
%	(version 2) by C code.
% Other header creators are derived from this one, and
% start with it.
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
if (~(header.type == 2))
	error('File is not AIB type');
end
header.version = fread(fid,1,'int16');
if (header.version == 1)
	
	header.nscans = fread(fid,1,'uint32');
	header.numch = fread(fid,1,'int32');
	header.channels = fread(fid,header.numch,'int16');
	if (size(header.channels,2) == 1)
		header.channels = header.channels';
	end
	header.scanrate = fread(fid,1,'float32');
	header.windowsize=fread(fid,1,'int32');
	header.scalemult = fread(fid,1,'float32');
	header.scaleoff = fread(fid,1,'float32');
	header.date = ReadLVString(fid);
	header.time = ReadLVString(fid);
	header.usrhdr = ReadLVString(fid);
end	
if (ischar(file))
	fclose(fid);
end
