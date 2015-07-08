function WriteAIHeader(fid,header)
% WriteAIHeader: Write the header for raw waveform files (AI = analog input)
% WriteAIHeader(fid,header)
% Writes version 2 or 3 headers
if (~(header.type == 1 | header.type == 4))
	error('File is not AI type');
end
headersize = 0;			% Update this later
fwrite(fid,headersize,'uint32');
fwrite(fid,header.type,'int16');
fwrite(fid,header.version,'int16');	% Header version
if (header.version == 2)
	fwrite(fid,header.nscans,'uint32');
	fwrite(fid,header.numch,'int32');
	fwrite(fid,header.channels,'int16');
	fwrite(fid,header.scanrate,'float32');
	fwrite(fid,header.scalemult,'float32');
	fwrite(fid,header.scaleoff,'float32');
	WriteLVString(fid,header.date);
	WriteLVString(fid,header.time);
	WriteLVString(fid,header.usrhdr);
	% Now update header size
	fcur = ftell(fid);
	fseek(fid,0,-1);
	fwrite(fid,fcur,'uint32');
	fseek(fid,fcur,-1);
end
if (header.version == 3)
	fwrite(fid,header.nscans,'uint32');
	fwrite(fid,header.numch,'int32');
	fwrite(fid,header.channels,'int16');
	fwrite(fid,header.scanrate,'float32');
	fwrite(fid,header.scalemult,'float32');
	fwrite(fid,header.scaleoff,'float32');
	WriteLVString(fid,header.date);
	WriteLVString(fid,header.time);
	WriteLVString(fid,header.usrhdr);
	% Now update header size
	fcur = ftell(fid);
	fseek(fid,0,-1);
	fwrite(fid,fcur,'uint32');
	fseek(fid,fcur,-1);
end

