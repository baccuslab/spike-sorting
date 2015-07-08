function chconfig = ReadChConfig(fid)
% Read LabVIEW's channel configuration info from header
chconfig.channel = readLVstring(fid);
chconfig.uilim = fread(fid,1,'float32');
chconfig.lilim = fread(fid,1,'float32');
chconfig.range = fread(fid,1,'float32');
chconfig.polarity = fread(fid,1,'uint16');
chconfig.gain = fread(fid,1,'float32');
chconfig.coupling = fread(fid,1,'uint16');
chconfig.inputmode = fread(fid,1,'uint16');
chconfig.scalemult = fread(fid,1,'float32');
chconfig.scaleoff = fread(fid,1,'float32');
