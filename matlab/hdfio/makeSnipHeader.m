function header = makeSnipHeader(filename, sniptype)
%
% FUNCTION header = makeSnipHeader(filename)
%
% This function approximates the functionality of ReadSnipHeader, for HDF5
% snippet files.
%
% INPUT:
%   filename - The string identifying the HDF5 snippet file
%   sniptype - The snippet type about which information should be returned.
%               This can be either 'spike' or 'noise'. Defaults to 'spike'.
%   
% OUTPUT:
%   header   - A structure array containing all meaningful information
%               about the snippet file.
%
% The old function ReadSnipHeader, returned the actual header for the
% binary snippet file format, which includes information about the size of
% the file, the thresholds, the number of snippets per channel, etc. This
% information is no longer stored in a header, but can be gleaned from the
% HDF5 snippet file format. This function attempts to return a struct
% containing all of the meaningful information that can be reconstructed.
% Note that this should *NOT* be used when you need to actually read the
% snippet files, only when you need most of the information about snippet
% files, but in a format expected by certain functions.
%
% (C) 2015 Benjamin Naecker bnaecker@stanford.edu
%
% History
%
% 2015-10-26 - Benjamin Naecker
%   - wrote it

info = h5info(filename);
header.sniptype = sniptype;
header.channels = double(h5read(filename, '/extracted-channels'));
header.channels = header.channels(:)';
header.numch = length(header.channels);
header.thresh = double(h5read(filename, '/thresholds'));
header.thresh = header.thresh(:)';
header.sniprange = getSnipRange(filename);
attributeNames = {info.Attributes.Name};
header.scanrate = double(info.Attributes(strcmp('sample-rate', ...
    attributeNames)).Value);
header.nscans = double(info.Attributes(strcmp('nsamples', ...
    attributeNames)).Value);
header.scaleoff = double(info.Attributes(strcmp('gain', ...
    attributeNames)).Value);
header.scalemult = double(info.Attributes(strcmp('offset', ...
    attributeNames)).Value);
header.date = info.Attributes(strcmp('date', attributeNames)).Value;
header.numofsnips = zeros(1, header.numch);
if strcmp(sniptype, 'spike')
    dsetIdx = 3;
else
    dsetIdx = 1;
end
for ci = 1:header.numch
    header.numofsnips(ci) = ...
        info.Groups(ci).Datasets(dsetIdx).Dataspace.Size;
end
