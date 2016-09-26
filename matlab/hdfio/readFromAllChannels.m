function [snips, range] = readFromAllChannels(snipfile, sniptype, num, channels)
% FUNCTION [nsnips, range] = readFromAllChannels(snipfile, sniptype, num, channels)
%
% Read and return snippets of the given type from the given file, and the range
% of the snippets, i.e., the number of samples before and after a spike peak
%
% INPUT:
% 	snipfiles	- String giving the file from which to read data
% 	sniptype	- Read 'spike' or 'noise' snippets
%	num			- Maximum number of snippets to read across all channels.
%                   Defaults to all snippets from each channel.
%	channels	- Channels from which data is to be read
%
% OUTPUT:
%   snips       - Snippets from all channels, concatenated. The array has
%                   size (snipSize, length(channels) * num)
%   range       - The number of samples before and after a spike peak
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-07-20 - Benjamin Naecker
%	- wrote it

% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality
% 2015-09-08 - Lane McIntosh
%   - changed channels dataset
%
% 2015-10-21 - Benjamin Naecker
%	- removing support for multiple files

if ~exist(snipfile, 'file')
	error('hdfio:readFromAllChannels', ...
		'File does not exist: %s', snipfile);
end
try 
	fileChannels = double(h5read(snipfile, '/extracted-channels'));
catch me
	error('hdfio:invalidFile', ...
		'The file does not have extracted channels: %s', snipfile);
end
if nargin == 2
	num = Inf;
elseif nargin == 3
	channels = fileChannels;
end
chans = intersect(fileChannels, channels);

numSnips = getNumSnips(snipfile, sniptype, channels);
totalNumSnips = sum(numSnips);
fracSnips = min(1, num / totalNumSnips);

snips = cell(length(chans), 1);
for i = 1:length(chans)
	snips{i} = loadSnip(snipfile, sniptype, chans(i), ...
        max(floor(fracSnips * numSnips(i)), 1));
end
snips = cat(2, snips{:});
range = getSnipRange(snipfile);

