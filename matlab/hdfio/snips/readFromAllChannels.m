function [snips, range] = readFromAllChannels(snipfile, sniptype, num, channels)
% FUNCTION [nsnips, range] = readFromAllChannels(snipfile, sniptype, num, channels)
%
% Read and return snippets of the given type from the given file, and the range
% of the snippets before and after the spike's peak
%
% INPUT:
% 	snipfile	- HDF snippet file from which snippets are read
% 	sniptype	- Read 'spike' or 'noise' snippets
%	num			- Maximum number of snippets to read, defaults to all
%	channels	- Channels from which data is to be read
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-07-20 - Benjamin Naecker
%	- wrote it

% Check inputs
if ~exist(snipfile, 'file')
	error('hdfio:snips:readFromAllChannels:FileNotFound', ...
		'The snippet file does not exist: %s', snipfile);
end
fileChannels = h5read(snipfile, '/channels');
if nargin == 2
	chans = fileChannels;
	num = Inf;
elseif nargin == 3
	chans = fileChannels;
else
	chans = intersect(channels, fileChannels);
end

% Read snippets from each file
snips = cell(length(chans), 1);
for i = 1:length(chans)
	snips{i} = loadSnip(snipfile, sniptype, chans(i), num);
end
snips = cat(2, snips{:});
range = getSnipRange(snipfile);

