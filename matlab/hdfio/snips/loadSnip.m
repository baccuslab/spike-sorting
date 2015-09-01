function [snip, time] = loadSnip(filenames, sniptype, channel, maxsnip)
% LoadSnip: load the snippets from a given channel in one file
%
% [snip, time ] = LoadSnip(filename, sniptype, channel,maxsnip)
% The fourth argument (maxsnip) is optional; at most maxsnip snippets
%	will be read, with the default behavior to read all the snippets
% snip is returned in units of volts. This is the only reliable choice for sorting, as
%	the user might change the A/D scaling between files.
%
% INPUT:
%	filenames	- Cell array of the snippet files from which to load data
%	or single file
%	sniptype	- Load either 'spike' or 'noise' snippets
%	channel		- Channel from which to load data
%	maxsnip		- Maximum number of snippets to load across all files, defaults to all
%
% (C) 2015 The Baccus Lab
%
% History:
% ?? - Tim Holy
%	- wrote it
%
% 2015-07-20 - Benjamin Naecker
% 	- updating to use HDF snippet file format

% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality

if ischar(filenames)
    filenames = {filenames};
end

if nargin < 4
    maxsnip = Inf;
else
    maxsnip = min(maxsnip, getNumSnips(filenames, sniptype, channel));
end

snip = [];%cell(1, length(filenames));
time = [];%cell(1, length(filenames));

if maxsnip == 0
    return;
end

snip_needed = maxsnip;

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
    if size(temp_snip, 2) > snip_needed
        temp_snip = temp_snip(:,1:snip_needed);
        temp_time = temp_time(1:snip_needed,:);
    end
    
    % Return snippets in actual voltage values
    gain = h5readatt(filenames{fnum}, '/', 'gain');
    offset = h5readatt(filenames{fnum}, '/', 'offset');
    temp_snip = single(temp_snip) * gain + offset;

%    snip{fnum} = temp_snip;
%    time{fnum} = temp_time;
    snip = [snip temp_snip];
    time = [time; temp_time];

    snip_needed = snip_needed - size(temp_snip,2);
    if snip_needed <= 0
        break
    end
end
