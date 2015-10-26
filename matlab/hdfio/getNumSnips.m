function nsnips = getNumSnips(filenames, sniptype, chans)
% FUNCTION nsnips = getNumSnips(filenames, sniptype, chans)
%
% Return the number of snippets in each file for the given channels
%
% INPUT:
% 	filenames	- Cell array of snippet files or string of single file
%	sniptype	- Read either 'noise' or 'spike' snippets
%	chans		- The channel(s) from which data is to be read
%
% OUTPUT:
% 	nsnips 		- An array with the number of snippets in each file and 
%					channel. The array has shape (nchannels, nfiles)
%
% (C) 2015 The Baccus Lab
%
% Updates:
% 2015-07-20 - Benjamin Naecker
%	- wrote it

% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality
% 2015-09-08 - Lane McIntosh
%   - changed /channels to /extracted-channels

% Parse input
if ischar(filenames) %check if cell array
    filenames = {filenames};
end

fileChannels = double(h5read(filenames{1}, '/extracted-channels'));
if nargin == 1
    sniptype = 'spike';
    chans = fileChannels;
end
if nargin == 2
    chans = fileChannels;
end
if strcmp(sniptype, 'spike') == 0
    dsetIdx = 1;
else
    dsetIdx = 3;
end

nchans = length(chans);
nfiles = length(filenames);
nsnips = zeros(nchans, nfiles);

for fi = 1:nfiles
	
	try 
		info = h5info(filenames{fi});
	catch me
		error('hdfio:snips:getNumSnips', ...
			'The snippet file does not exist or is invalid: %s', ...
			filenames{fi});
    end
	channelOffset = fileChannels(1);
	channels = intersect(fileChannels, chans);
	for ci = 1:nchans
		nsnips(ci, fi) = info.Groups(channels(ci) - ...
			channelOffset + 1).Datasets(dsetIdx).Dataspace.Size;
	end
end

