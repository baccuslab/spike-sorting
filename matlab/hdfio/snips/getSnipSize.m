function sz = getSnipSize(filename)
% FUNCTION sz = getSnipSize(filename)
%
% Returns the size of snippets for the given snippet file
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-07-20 - Benjamin Naecker
%	- wrote it

if ~exist(filename, 'file')
	error('hdfio:snips:getSnipSize', ...
		'The snippet file does not exist: %s', filename);
end

% Get a channel that exists in the file
try 
	channels = h5read(filename, '/channels');
catch me
	error('hdfio:snips:getSnipSize', ...
		'The snippet file has no channel information');
end
chanStr = sprintf('/channel-%03d/spike-snippets', channels(1));

fid = H5F.open(filename);
dset = H5D.open(fid, chanStr);
[~, h5dim, ~] = H5S.get_simple_extent_dims(H5D.get_space(dset));
H5D.close(dset);
H5F.close(fid);
sz = h5dim(end);

