function [data,header] = loadlv(filename,nchannels)
% Load 2-D binary data produced by LabView
fid = fopen(filename,'r');
headersize = fread(fid,1,'uint32');
header = fread(fid,headersize,'char');
data = fread(fid,[nchannels,inf],'int16');
fclose(fid);
