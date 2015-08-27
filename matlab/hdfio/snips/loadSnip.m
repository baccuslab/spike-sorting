function [snip, time] = loadSnip(filename, sniptype, channel, maxsnip)
% LoadSnip: load the snippets from a given channel in one file
%
% [snip, time ] = LoadSnip(filename,channel,maxsnip)
% The third argument (maxsnip) is optional; at most maxsnip snippets
%	will be read, with the default behavior to read all the snippets
% snip is returned in units of volts. This is the only reliable choice for sorting, as
%	the user might change the A/D scaling between files.
%
% INPUT:
%	filename	- The snippet file from which to load data
%	sniptype	- Load either 'spike' or 'noise' snippets
%	channel		- Channel from which to load data
%	maxsnip		- Maximum number of snippets to load, defaults to all
%
% (C) 2015 The Baccus Lab
%
% History:
% ?? - Tim Holy
%	- wrote it
%
% 2015-07-20 - Benjamin Naecker
% 	- updating to use HDF snippet file format

% Check file exists and read number of total snippets and their size
if ~exist(filename, 'file')
	error('hdfio:loadSnip:FileNotFound', ...
		'The snippet file does not exist: %s', filename);
end
if nargin < 4
	maxsnip = Inf;
else
	maxsnip = min(maxsnip, getNumSnips(filename, sniptype, channel));
end

if maxsnip == 0
    snip = [];
    time = [];
    return;
end

% Read the snippets and their indices
channelString = '/channel-%03d';
snipString = sprintf([channelString '/%s-snippets'], channel, sniptype);
idxString = sprintf([channelString '/%s-idx'], channel, sniptype);
snip = h5read(filename, snipString, [1 1], [Inf, maxsnip]);
time = h5read(filename, idxString, [1], [maxsnip]);

% Return snippets in actual voltage values
gain = h5readatt(filename, '/', 'gain');
offset = h5readatt(filename, '/', 'offset');
snip = single(snip) * gain + offset;

