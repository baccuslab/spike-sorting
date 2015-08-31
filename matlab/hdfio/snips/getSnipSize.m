function sz = getSnipSize(filenames)
% FUNCTION sz = getSnipSize(filenames)
%
% Returns the size of snippets for the given snippet file
%
% (C) 2015 The Baccus Lab
%
% History:
% 2015-07-20 - Benjamin Naecker
%	- wrote it

% Updates:
% 2015-08-31 - Aran Nayebi and Pablo Jadzinsky
%   - added multiple file functionality

if ischar(filenames)
    filenames = {filenames};
end

for fnum=1:length(filenames)
    if ~exist(filenames{fnum}, 'file')
        error('hdfio:snips:getSnipSize', ...
            'The snippet file does not exist: %s', filenames{fnum});
    end
    if fnum==1
        % Get a channel that exists in the file
        try 
            channels = h5read(filenames{fnum}, '/channels');
        catch me
            error('hdfio:snips:getSnipSize', ...
                'The snippet file has no channel information');
        end
        chanStr = sprintf('/channel-%03d/spike-snippets', channels(1));

        fid = H5F.open(filenames{fnum});
        dset = H5D.open(fid, chanStr);
        [~, h5dim, ~] = H5S.get_simple_extent_dims(H5D.get_space(dset));
        H5D.close(dset);
        H5F.close(fid);
        sz = h5dim(end);
    else
        % Get a channel that exists in the file
        try 
            channels = h5read(filenames{fnum}, '/channels');
        catch me
            error('hdfio:snips:getSnipSize', ...
                'The snippet file has no channel information');
        end
        chanStr = sprintf('/channel-%03d/spike-snippets', channels(1));

        fid = H5F.open(filenames{fnum});
        dset = H5D.open(fid, chanStr);
        [~, h5dim, ~] = H5S.get_simple_extent_dims(H5D.get_space(dset));
        H5D.close(dset);
        H5F.close(fid);
        sz_other = h5dim(end);
        if sz ~= sz_other
            error('Each snippet file must have the same snip size!')
        end
    end
end

