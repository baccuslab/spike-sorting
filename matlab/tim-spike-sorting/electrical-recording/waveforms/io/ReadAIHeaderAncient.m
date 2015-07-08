function [header,headersize] = ReadAIHeaderAncient(fid)
% [header,headersize] = ReadAIHeaderAncient(fid)
% Read the acquisition header, from back before the type
% and version identifiers.
% The Labview that writes these headers is 'create AI binary header0.vi'
headersize = fread(fid,1,'uint32');
header.chstr = readLVstring(fid);
chconfiglen = fread(fid,1,'uint32');
header.numch = fread(fid,1,'int32');
%header.chinfo(1,header.numch);
for i=1:header.numch
	header.chinfo(i) = readChConfig(fid);
end
header.scanrate = fread(fid,1,'float32');
header.chclock = fread(fid,1,'float32');
posn = ftell(fid);
header.string = fread(fid,headersize-(posn-4),'char');
return
header.date = readLVstring(fid);
header.time = readLVstring(fid);
header.datetime = readLVstring(fid);
header.usrhdr = readLVstring(fid);
header.acqtime = fread(fid,1,'float32');
