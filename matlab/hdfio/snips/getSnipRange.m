function range = getSnipRange(filename)
% FUNCTION range = getSnipRange(filename)
%
% Return the number of samples before and after the peak of a spike snippet.
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-07-20 - Benjamin Naecker
% 	- wrote it

% Verify file
if ~exist(filename, 'file')
	error('hdfio:snips:getSnipRange:FileNotFound', ...
		'The snippet file does not exist: %s', filename);
end
range = double([h5readatt(filename, '/', 'nsamples-before') ...
		 h5readatt(filename, '/', 'nsamples-after')]);

