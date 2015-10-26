function range = getSnipRange(filenames)
% FUNCTION range = getSnipRange(filenames)
%
% Return the number of samples before and after the peak of a spike snippet.
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-07-20 - Benjamin Naecker
% 	- wrote it

% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality

if ischar(filenames)
    filenames = {filenames};
end
for fnum=1:length(filenames)
    % Verify file
    if ~exist(filenames{fnum}, 'file')
        error('hdfio:snips:getSnipRange:FileNotFound', ...
            'The snippet file does not exist: %s', filenames{fnum});
    end
    if fnum==1
        range = double([h5readatt(filenames{fnum}, '/', 'nsamples-before') ...
                 h5readatt(filenames{fnum}, '/', 'nsamples-after')]);
    else
        range_other = double([h5readatt(filenames{fnum}, '/', 'nsamples-before') ...
                 h5readatt(filenames{fnum}, '/', 'nsamples-after')]);
        if range ~= range_other
            error('Each snippet file must have the same snip range!')
        end
    end
end

