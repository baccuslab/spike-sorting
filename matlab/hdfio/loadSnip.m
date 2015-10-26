function [snip, time] = loadSnip(filename, sniptype, channel, maxsnip)
% FUNCTION [snip, time] = loadSnip(filename, sniptype, channel,maxsnip)
%
% Load the first `maxsnip` snippets of the given type from a single file.
%
% INPUT:
%	filenames	- A string giving the file from which snippets are loaded
%	sniptype	- Load either 'spike' or 'noise' snippets
%	channel		- Channel from which to load snippets
%	maxsnip		- Maximum number of snippets to load across all files.
%					Defaults to all, and loads up to min(maxsnip, nsnips).
%
% OUTPUT:
%	snip		- An array of snippets, shaped as (snipsize, min(maxsnip, nsnips))
%	time 		- The time index into the original raw data file at which
%					each snippet occurred.
%
% (C) 2015 The Baccus Lab
%
% History:
% ?? - Tim Holy
%	- wrote it
%
% 2015-07-20 - Benjamin Naecker
% 	- updating to use HDF snippet file format
%
% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality
%
% 2015-10-21 - Benjamin Naecker
%	- removing multiple file functionality

if ~exist(filename, 'file')
	error('hdfio:loadSnip:FileNotFound', ...
		'The snippet file does not exist: %s', filename);
end

numSnips = getNumSnips(filename, sniptype, channel);
if (isempty(numSnips) || numSnips == 0)
	snip = [];
	time = [];
	return;
end
if nargin < 4
	maxsnip = numSnips;
end
maxsnip = min(maxsnip, numSnips);

% Read requested number of snippets
channelString = '/channel-%03d';
snip = double(h5read(filename, ...
	sprintf([channelString '/%s-snippets'], channel, sniptype), ...
	[1 1], [Inf, maxsnip]));
time = double(h5read(filename, ...
	sprintf([channelString '/%s-idx'], channel, sniptype), ...
	[1], [maxsnip]));

% Return snippets in actual voltage values
gain = double(h5readatt(filename, '/', 'gain'));
% offset = double(h5readatt(filename, '/', 'offset'));
offset = 0.0;
snip = snip * gain + offset;

