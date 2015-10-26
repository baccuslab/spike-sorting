function [snip, time] = loadIndexSnip(filename, sniptype, channel, indices)
%
% FUNCTION [snip, time] = loadIndexSnip(filename, sniptype, channel,indices)
%
% Load snippets from a single file, by the snippet indices. Snippets are
% returned in units of volts.
%
% INPUT:
%	filenames	- String giving the file from which snippets are to be loaded
%	sniptype	- Load either 'spike' or 'noise' snippets
%	channel		- Channel from which to load data
%	indices		- Indices of snips to load
%
% OUTPUT:
%	snip		- An array of snippets, shaped as [snipsize, nsnips]
%	time 		- An array of giving the start time of each snippet, as an
%					index in the original recording file, shpaed as [nsnips, 1]
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-09-02 - Lane McIntosh
%	- wrote it, copying generously from loadSnip()
%
% 2015-10-21 - Benjamin Naecker
%	- Removing multi-file functionality

% Check file exists and read number of total snippets and their size
if ~exist(filename, 'file')
	error('hdfio:loadSnip:FileNotFound', ...
		'The snippet file does not exist: %s', filename);
end

% Read the snippets and their indices
channelString = '/channel-%03d';
snipString = sprintf([channelString '/%s-snippets'], channel, sniptype);
idxString = sprintf([channelString '/%s-idx'], channel, sniptype);
snip = double(h5read(filename, snipString, [1 1], [Inf, Inf]));
time = double(h5read(filename, idxString, [1], [Inf]));

% Truncate indices 
if nargin == 3
    indices = 1:length(time);
else
    indices = indices(indices <= size(snip, 2));
end

% Return snippets in actual voltage values
gain = double(h5readatt(filename, '/', 'gain'));
% offset = double(h5readatt(filename, '/', 'offset'));
offset = 0.0;
snip = snip(:, indices) * gain + offset;
time = double(time(indices));

