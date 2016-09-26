function array = getArrayType(filename)
%
% FUNCTION array = getArrayType(filename)
%
% Return the type of the array from which data in the given HDF5 recording
% file was recorded.
%
% INPUT:
%   filename    - HDF5 recording file name. (string)
%
% OUTPUT:
%   array       - Array type (string)
%
% (C) 2016 Benjamin Naecker bnaecker@stanford.edu
%
% History:
%   2016-01-31 - wrote it

if ~exist(filename, 'file')
    error('getArrayType:invalidFile', 'The given file does not exist: %s', ...
        filename);
end

try
    array = h5readatt(filename, '/data', 'array');
catch me
    try
        array = h5readatt(filename, '/', 'array');
    catch me
        error('getArrayType:noArray', ...
            'No array attribute exists in the given file');
    end
end
