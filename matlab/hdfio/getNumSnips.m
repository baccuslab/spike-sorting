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

if ~all(ismember(chans, fileChannels))
    badChannels = setdiff(chans, fileChannels);
    fmt = repmat('%d', [1 length(badChannels)]);
    error(['The snippet file does not contain extracted snippets ' ...
        'from all the requested channels: ' fmt], badChannels);
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
    channelNames = {info.Groups.Name};
	for ci = 1:nchans
        channelName = sprintf('/channel-%03d', chans(ci));
        ix = strcmp(channelName, channelNames);
		nsnips(ci, fi) = info.Groups(ix).Datasets(dsetIdx).Dataspace.Size;
	end
end

