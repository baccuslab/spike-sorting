function total_d = loadRawData(filenames, channels, idxs, len)
% FUNCTION d = loadRawData(filenames, channels, idxs, len)
%
% Loads raw data from the HDF recording file in filename at the given times.
%
% INPUT:
%	filenames	- Cell array of raw data file names or single file
%	channels	- Array giving channels from which data is to be loaded
%	idxs		- Cell array of the indices into each file from which the
%	data should be read or single array of indices
% 	len			- The number of points to be read, starting from each idx
%	
% OUTPUT:
%	total_d 		- A cell array with one cell for each channel. Each entry of
%					the cell array is a matrix of size length(idx)-by-length,
%					giving the sections of the raw data on that channel of length
%					`length`, starting at each index `idx`.
%
% (C) 2015 The Baccus Lab
% 
% History:
% 2015-07-20 - Benjamin Naecker
%	- wrote it
% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality

if ischar(filenames) %check if filenames is a cell array
    filenames = {filenames};
end

if isnumeric(idxs) %check if idx is an array; if so make it a cell array of arrays
    idxs = {idxs};
end

if length(filenames) ~= length(idxs)
    error('Need to specify indices for every file!');
end

if isscalar(channels)
    channels = [channels];
end

if isempty(channels) || nargin < 4
    total_d = {};
    return
end

% Preallocate array for all data
nchannels = length(channels);
total_d = cell(nchannels, 1);
tot_nidx = 0;
for fnum=1:length(filenames)
    tot_nidx = tot_nidx + length(idxs{fnum});
end
[total_d{:}] = deal(zeros(tot_nidx, len));
acc = 1;

for fnum=1:length(filenames)
    % Verify inputs
    if ~exist(filenames{fnum}, 'file')
        error('hdfio:raw:loadRawData:FileNotFound', ...
            'The raw data file does not exist: %s', filenames{fnum});
    end

    if isscalar(idxs{fnum})
        idxs{fnum} = [idxs{fnum}];
    end

    % Read data
    nidx = length(idxs{fnum});
    if max(diff(channels) == 1)
        if (max(diff(idxs{fnum})) == 1 && len == 1)
            % Reading a contiguous block of channels and samples. One read 
            % and then redistribute, rather than many reads
            tmp = h5read(filenames{fnum}, '/data', [min(idxs{fnum}) min(channels)], ...
                [nidx nchannels]);
            for c = 1:nchannels
                total_d{c}(acc:acc+nidx-1, 1) = tmp(c, :);
            end
        else
            % Reading a contiguous block of channels, so read larger chunks
            % and then redistribute rather than many reads
            for i = 1:nidx
                for c = 1:nchannels
                    file_idx = idxs{fnum};
%                    tmp = h5read(filenames{fnum}, '/data', [file_idx(i) channels(c)], ...
%                    [len 1]);
%                    total_d{c}(acc+i, :) = tmp;
                    total_d{c}(acc+i-1, :) = h5read(filenames{fnum}, '/data', [file_idx(i) channels(c)], [len 1]);


                
                end
            end
        end
    else
        % Reading arbitrary points in the file
        for c = 1:length(channels)
            for i = 1:nidx
                file_idx = idxs{fnum};
                total_d{c}(acc+i-1, :) = h5read(filenames{fnum}, '/data', [file_idx(i) channels(c)], [len 1]);
            end
        end
    end
    acc = acc + nidx;
    total_d = cellfun(@double, total_d, 'UniformOutput', false);
end
