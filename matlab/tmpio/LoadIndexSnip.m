function [snips, times] = LoadIndexSnip(file, channel, indices)
% FUNCTION [snips, times] = LoadIndexSnip(file, channel, indices)
%
% Load snippets from the given file by their index.
%
% This function loads snippets from old-school .ssnp and .rsnp
% snippet files. It is a pure-Matlab implementation of the C++
% function, LoadIndexSnip.cpp, to avoid having to compile the
% MEX library.
%
% INPUT:
% 	file		- String naming the snippet file
%	channel		- The integer channel from which to load snippets
% 	indices		- Array of indices of the snippets to load
%
% OUTPUT:
%	snips		- An array of snippets, shaped as 
%					(snipSize, min(length(indices), nSnippetsInFile)).
%					The snippets have datatype int16, but the array is 
%					returned as a double array.
%	times		- An array listing the start time (in samples) of
%					each snippet returned in snips
%
% (C) 2015 Benjamin Naecker bnaecker@stanford.edu
%
% History:
%
% 2015-10-22 - Benjamin Naecker
%		- wrote it

if ~exist(file, 'file')
	error('LoadIndexSnip:FileNotFound', ...
		'The snippet file does not exist: %s', file);
end
if numel(channel) ~= 1
	error('LoadIndexSnip:TooManyChannels', ...
		'Only one channel may be read at a time');
end

hdr = ReadSnipHeader(file);
if isempty(intersect(channel, hdr.channels))
	error('LoadIndexSnip:BadChannel', ...
		'The requested channel %d is not in the file', channel);
end
chindx = find(hdr.channels == channel, 1, 'first');
if isempty(chindx)
	snips = [];
	times = [];
	return;
end
snipsize = -hdr.snipbeginoffset + hdr.snipendoffset + 1;
nsnips = length(indices);
snips = zeros(snipsize, nsnips, 'int16');
times = zeros(nsnips, 1);

[fid, msg] = fopen(file, 'r', 'b');
if fid == -1
	error(msg);
end
fseek(fid, hdr.snipsfpos(chindx), 'bof');
for i = 1:nsnips
	times(i) = hdr.snipsfpos(chindx) + ...
		snipsize * 2 * (indices(i) - 1);
	fseek(fid, times(i), 'bof');
	snips(:, i) = fread(fid, snipsize, 'int16');
end
fclose(fid);
snips = double(snips);

