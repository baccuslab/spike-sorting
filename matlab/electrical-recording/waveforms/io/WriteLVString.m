function WriteLVString(fid,str)
% WriteLVString: Write a string prepended with its (4 byte) length
% WriteLVString(fid,str)
fwrite(fid,length(str),'int32');
fwrite(fid,str,'char');
