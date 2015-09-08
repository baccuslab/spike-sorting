function [snips, range] = readFromAllChannels(snipfiles, sniptype, num, channels)
% FUNCTION [nsnips, range] = readFromAllChannels(snipfiles, sniptype, num, channels)
%
% Read and return snippets of the given type from the given file, and the range
% of the snippets before and after the spike's peak
%
% INPUT:
% 	snipfiles	- Cell array of HDF snippet files from which snippets are
% 	read or single file
% 	sniptype	- Read 'spike' or 'noise' snippets
%	num			- Maximum number of snippets to read per channel, defaults to all
%	channels	- Channels from which data is to be read
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

if ischar(snipfiles)
    snipfiles = {snipfiles};
end

% Check inputs
for fnum = 1:length(snipfiles)
    if ~exist(snipfiles{fnum}, 'file')
        error('hdfio:snips:readFromAllChannels:FileNotFound', ...
            'The snippet file does not exist: %s', snipfiles);
    end
    if fnum==1
        fileChannels = h5read(snipfiles{fnum}, '/extracted-channels');
    else
        if fileChannels ~= h5read(snipfiles{fnum}, '/extracted-channels')
            error('All snipfiles should have data for the same channels')
        end
    end
end

if nargin == 2
	num = Inf;
	chans = fileChannels;
elseif nargin == 3
	chans = fileChannels;
else
	chans = intersect(channels, fileChannels);
end

% Read snippets from each file
snips = cell(length(chans), 1);
for i = 1:length(chans)
	snips{i} = loadSnip(snipfiles, sniptype, chans(i), num);
end
snips = cat(2, snips{:});
range = getSnipRange(snipfiles);

