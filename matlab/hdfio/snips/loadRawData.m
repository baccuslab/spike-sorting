function d = loadRawData(filename, channels, idx, len)
% FUNCTION d = loadRawData(filename, channels, idx, len)
%
% Loads raw data from the HDF recording file in filename at the given times.
%
% INPUT:
%	filename	- Raw data file name
%	channels	- Array giving channels from which data is to be loaded
%	idx			- The indices into the file from which the data should be read.
% 	len			- The number of points to be read, starting from each idx
%	
% OUTPUT:
%	d 			- A cell array with one cell for each channel. Each entry of
%					the cell array is a matrix of size length(idx)-by-length,
%					giving the sections of the raw data on that channel of length
%					`length`, starting at each index `idx`.
%
% (C) 2015 The Baccus Lab
% 
% History:
% 2015-07-20 - Benjamin Naecker
%	- wrote it

% Verify inputs
if ~exist(filename, 'file')
	error('hdfio:raw:loadRawData:FileNotFound', ...
		'The raw data file does not exist: %s', filename);
end
if isempty(channels) || nargin < 4
	d = {};
	return
end
if isscalar(channels)
	channels = [channels];
end
if isscalar(idx)
	idx = [idx];
end

% Preallocate array for all data
nchannels = length(channels);
nidx = length(idx);
d = cell(nchannels, 1);
[d{:}] = deal(zeros(nidx, len));

% Read data
if max(diff(channels) == 1)
	if (max(diff(idx) == 1) && len == 1)
		% Reading a contiguous block of channels and samples. One read 
		% and then redistribute, rather than many reads
		tmp = h5read(filename, '/data', [min(idx), min(channels)], ...
			[nidx, nchannels]);
		for c = 1:nchannels
			d{c}(:, 1) = tmp(:, c);
		end
	else
		% Reading a contiguous block of channels, so read larger chunks
		% and then redistribute rather than many reads
		for i = 1:nidx
			tmp = h5read(filename, '/data', [idx(i) min(channels)], ...
				[len, nchannels]);
			for c = 1:nchannels
				d{c}(i, :) = tmp(:, c);
			end
		end
	end
else
	% Reading arbitrary points in the file
	for c = 1:length(channels)
		for i = 1:nidx
			d{c}(i, :) = h5read(filename, '/data', [idx(i) channels(c)], [len 1]);
		end
	end
end

