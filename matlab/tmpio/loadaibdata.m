function data = loadaibdata(files, channels, times, range)
%
% FUNCTION data = loadaibdata(files, channels, times, range)
%
% Load raw data from old-school AIB data files.
%
% This function is a pure-Matlab implementation of the loadaibdata.cpp
% MEX-function, to avoid having to compile it.
%
% INPUT:
% 	files		- Cell array of filenames from which data will be loaded
%	channels	- A single array of channels from which data will be loaded.
%					This is the same across all files. Indexing is ZERO-BASED.
%	times		- A cell array of arrays, one for each file. Each array gives
% 					the time points in the file from which raw data is to be
%					loaded. These are integer indices, in samples. Note that 
%					indexing is ZERO-BASED.
%	range		- A 2-element array, giving the number of samples to be loaded
%					before and after the time points given in `times`. Both elements
%					should be positive, and the first will be used as a negative offset.
%
% OUTPUT:
%	data 		- A cell array, shaped as (nchannels, nfiles). Each element of
%					the cell array contains an array shaped as (snipSize, length(times{i}))
%					where times{i} gives the times in the i-th file.
%
% (C) 2015 Benjamin Naecker bnaecker@stanford.edu
%
% History:
%
% 2015-10-22 - Benjamin Naecker
%	- wrote it

nfiles = length(files);
nchannels = length(channels);
data = cell(nchannels, nfiles);
if length(times) ~= nfiles
	error('loadaibdata:BadTimesArray', ...
		'The array of times must be a cell array of the same length as files');
end
range = abs(range);
sz = sum(range) + 1;

for fi = 1:nfiles
	if ~exist(files{fi}, 'file')
		error('loadaibdata:FileNotFound', ...
			'The AIB file %s could not be found', files{fi});
	end
	header = ReadAIBHeader(files{fi});
	blockSize = header.windowsize * header.numch;

	[fid, msg] = fopen(files{fi}, 'r', 'b');
	if fid == -1
		error(msg);
	end
	dataOffset = fread(fid, 1, 'uint32');

	ntimes = length(times{fi});
	for ci = 1:nchannels
		data{ci, fi} = zeros(sz, ntimes);
		for ti = 1:ntimes
			block = floor(times{fi}(ti) / header.windowsize);
            idx = mod(times{fi}(ti), header.windowsize);
            fseek(fid, dataOffset + ...
                (block * blockSize + ...
                channels(ci) * header.windowsize + ...
                idx - range(1)) * 2, 'bof');
			data{ci, fi}(:, ti) = double(fread(fid, sz, 'int16'));
		end
	end
	data(:, fi) = cellfun(@(x) x * header.scalemult + header.scaleoff, ...
		data(:, fi), 'UniformOutput', false);
	fclose(fid);
end

