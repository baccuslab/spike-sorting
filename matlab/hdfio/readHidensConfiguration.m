function config = readHidensConfiguration(filename)
%
% FUNCTION config = readHidensConfiguration(filename)
%
% Return the configuration saved in a HiDens HDF5 recording file. 
%
% The configuration is returned as a structure array, with one element for
% each channel in the file. Each element contains the following fields:
%
% 	.channel	- The channel number, in the range [0, 126]
%	.x			- The x-index of this electrode
%	.xpos		- The x-position of this electrode
%	.y			- The y-index of this electrode
%	.ypos		- The y-position of this electrode
%	.label		- The character label associated with this electrode.
%
% (C) 2016 Benjamin Naecker bnaecker@stanford.edu
% 
% History:
%	2016-01-31 - wrote it

if ~exist(filename, 'file')
	error('readHidensConfiguration:invalidFile', ...
		'The HiDens file "%s" does not exist.', filename);
end

dset_names = {'channels', 'xpos', 'x', 'ypos', 'y', 'label'};
for di = 1:length(dset_names)
	eval(sprintf('%s = h5read(''%s'', ''/configuration/%s'');', ...
		dset_names{di}, filename, dset_names{di}));
end

config = struct( ...
	'channel', channels(channels ~= -1), ...
	'x', x, ...
	'xpos', xpos, ...
	'y', y, ...
	'ypos', ypos, ...
	'label', label);

