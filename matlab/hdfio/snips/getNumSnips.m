function nsnips = getNumSnips(filename, sniptype, chans)
% FUNCTION nsnips = getNumSnips(filename, sniptype, chans)
%
% Return the number of snippets in the given file on each channel
%
% INPUT:
% 	filename	- Snippet file
%	sniptype	- Read either 'noise' or 'spike' snippets, defaults to 'spike'
%	chans		- The channel(s) from which data is to be read, defaults to
%					all in the file
%
% (C) 2015 The Baccus Lab
%
% Updates:
% 2015-07-20 - Benjamin Naecker
%	- wrote it

% Parse input
if nargin == 1
	sniptype = 'spike';
	chans = 0:126; % Max for all channels, including HiDens system
elseif nargin == 2
	chans = 0:126;
end

% Check that the file exists
if ~exist(filename, 'file')
	error('hdfio:snips:getSnipDims', ...
		'The snippet file does not exist: %s\n', filename);
end

% Open the snippet file and verify that channel information exists
try 
	channels = h5read(filename, '/channels');
catch me
	error('hdfio:snips:getSnipDims', ...
		'The snippet file does not contain any channel information');
end
ch = intersect(chans, channels);
if (isempty(ch))
	snipsize = [];
	nsnips = [];
	return
end

% Read the size of the snippets for each channel
fid = H5F.open(filename);
nsnips = zeros(length(ch), 1);
for c = 1:length(ch)
	chanString = sprintf('/channel-%03d/%s-snippets', ch(c), sniptype);
	dset = H5D.open(fid, chanString);
	[~, h5dim, ~] = H5S.get_simple_extent_dims(H5D.get_space(...
		H5D.open(fid, chanString)));
	nsnips(c) = h5dim(1);
	H5D.close(dset);
end
H5F.close(fid);

