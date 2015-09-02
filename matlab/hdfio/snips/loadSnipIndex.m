function [snip, time] = loadSnipIndex(filenames, sniptype, channel, indices)
% loadSnipIndex: load snippets specified by indices, rather than just the first n.
%
% [snip, time] = loadSnipIndex(filename, sniptype, channel,indices)
% snip is returned in units of volts. This is the only reliable choice for sorting, as
%	the user might change the A/D scaling between files.
%
% INPUT:
%	filenames	- Cell array of the snippet files from which to load data
%	or single file
%	sniptype	- Load either 'spike' or 'noise' snippets
%	channel		- Channel from which to load data
%	indices		- Indices of snips to grab
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-09-02 - Lane McIntosh
%	- wrote it, copying largely from loadSnip()

if ischar(filenames)
    filenames = {filenames};
end

snip = [];%cell(1, length(filenames));
time = [];%cell(1, length(filenames));

for fnum=1:length(filenames)
    % Check file exists and read number of total snippets and their size
    if ~exist(filenames{fnum}, 'file')
        error('hdfio:loadSnip:FileNotFound', ...
            'The snippet file does not exist: %s', filenames{fnum});
    end

    % Read the snippets and their indices
    channelString = '/channel-%03d';
    snipString = sprintf([channelString '/%s-snippets'], channel, sniptype);
    idxString = sprintf([channelString '/%s-idx'], channel, sniptype);
    temp_snip = double(h5read(filenames{fnum}, snipString, [1 1], [Inf, Inf]));
    temp_time = double(h5read(filenames{fnum}, idxString, [1], [Inf]));

    % select the subset of temp_snip specified by indices
    temp_snip = temp_snip(:,indices);
    temp_time = temp_time(indices,:);
    
    % Return snippets in actual voltage values
    gain = h5readatt(filenames{fnum}, '/', 'gain');
    offset = h5readatt(filenames{fnum}, '/', 'offset');
    temp_snip = single(temp_snip) * gain + offset;

    snip = [snip temp_snip];
    time = [time; temp_time];
end
