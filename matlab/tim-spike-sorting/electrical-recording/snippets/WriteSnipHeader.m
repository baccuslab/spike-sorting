function [nsnppos,timepospos,snippospos] = WriteSnipHeader(fid,header)
% WriteSnipHeader: writes the header for a snippets file
% [nsnppos,timepospos,snippospos] = WriteSnipHeader(fid,header)
% The outputs are file position values for items that are likely
%	to need updating later:
%	nsnppos: file positions for the # of snips/channel vector
%	timepospos: file positions for the spiketime-file-positions vector
%	snippospos: file positions for the spikewaveform-file-positions vector
if (~(header.type == 1 | header.type == 4))
	error('File is not AI type');
end
header.numch = length(header.channels);
header.numofsnips = zeros(1,header.numch);
header.timesfpos = zeros(1,header.numch);
header.snipsfpos = zeros(1,header.numch);
WriteAIHeader(fid,header);
fwrite(fid,header.sniptype,'int16');
fwrite(fid,header.snipbeginoffset,'int16');
fwrite(fid,header.snipendoffset,'int16');
fwrite(fid,header.thresh,'float32');
nsnppos = ftell(fid)+4*(0:header.numch-1);
fwrite(fid,header.numofsnips,'int32');
timepospos = ftell(fid)+4*(0:header.numch-1);
fwrite(fid,header.timesfpos,'uint32');
snippospos = ftell(fid)+4*(0:header.numch-1);
fwrite(fid,header.snipsfpos,'uint32');
return

