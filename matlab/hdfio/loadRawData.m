function allData = loadRawData(filenames, channels, times, range)
% FUNCTION d = loadRawData(filenames, channels, times, range)
%
% Loads raw data from the HDF recording file in filename at the given times.
%
% This function is an attempt to provide as close as possible to the same
% API as the `loadaibdata` function, while using the new HDF5 data file format.
%
% INPUT:
%	filenames	- Cell array of raw data file names or single file
%	channels	- Array giving channels from which data is to be loaded. 
%                   Indexing of channels is zero-based.
%	times		- Cell array of the indices into each file from which the
%					data should be read or single array of indices.
%					Indexing of times are zero-based.
% 	range		- The number of points to be read, starting from each idx.
%                   Both numbers should be positive, and will be used to
%                   retrieve times in the interval 
%                   [time - range(1), time + range(2)] 
%	
% OUTPUT:
%	allData 	- A cell array containing the raw data. The cell array itself
%					is shaped as (nchannels, nfiles). Each element within the
%					array is shaped as (len, length(time)), where time give the
%					times requested for that file.
%
% (C) 2015 The Baccus Lab
% 
% History:
% 2015-07-20 - Benjamin Naecker
%	- wrote it
%
% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality
%	
% 2015-09-10 - Lane McIntosh
%   - added voltage flag
%
% 2015-10-21 - Benjamin Naecker
%	- making output conform to that of old loadaibdata MEX function

if ischar(filenames)
    filenames = {filenames};
end
if isnumeric(times)
    times = {times};
end
if length(filenames) ~= length(times)
    error('hdfio:raw:loadRawData:MissingIndices', ...
		'Need to specify indices for every file!');
end
if isempty(channels) || nargin < 4
    allData = {};
    return
end

% Preallocate array for all data
nfiles = length(filenames);
nchannels = length(channels);
channels = reshape(channels, [nchannels, 1]);
if nchannels == 1
	channels = [channels; channels + 1];
end
len = -range(1) + range(2) + 1;
allData = cell(nchannels, nfiles);
for fi = 1:nfiles
end

for fi = 1:nfiles

	if ~exist(filenames{fi}, 'file')
		error('hdfio:raw:loadRawData:FileNotFound', ...
			'The raw data files does not exist: %s', filenames{fi});
	end

	time = times{fi}(:);
	ntimes = length(time);
	if ntimes == 1
		time = [time; time + 1];
	end
	info = h5info(filenames{fi});
	if any([max(time) + range(2) max(channels)] > info.Datasets.Dataspace.Size)
		error('hdfio:raw:loadRawData:IndicesOutOfBounds', ...
			'The indices [%d %d] are out of bounds for the dataset of size [%d %d]', ...
			max(time), max(channels), info.Datasets.Dataspace.Size);
	end
	[allData{:, fi}] = deal(zeros(len, ntimes));

	% Use low-level API for speed
	file = H5F.open(filenames{fi}, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
	dataset = H5D.open(file, '/data');
	space = H5D.get_space(dataset);
	memspace = H5S.create_simple(2, [1 len], []);
	for ci = 1:nchannels
		for ti = 1:ntimes
			H5S.select_hyperslab(space, 'H5S_SELECT_SET', ...
				[channels(ci)  time(ti) + range(1)], ...
				[], [1 len], []);
			allData{ci, fi}(:, ti) = H5D.read(dataset, 'H5ML_DEFAULT', ...
				memspace, space, 'H5P_DEFAULT');
		end
	end
	H5S.close(memspace);
	H5S.close(space);
	H5D.close(dataset);
	H5F.close(file);
end

gain = double(h5readatt(filenames{1}, '/data', 'gain'));
% offset = double(h5readatt(filenames{1}, '/data', 'offset'));
offset = 0;
allData = cellfun(@(x) x * gain + offset, allData, 'UniformOutput', false);

