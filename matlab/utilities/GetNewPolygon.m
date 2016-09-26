function [pvx, pvy] = GetNewPolygon(color)
%
% Return vertices of a user-defined polygon, drawn onto the current plot.
%
% This is intended to be an implementation of the GetSelPolygon function,
% using Matlab's new handle-graphics interface, particularly the impoly
% function.
%
% (C) 2015 Benjamin Naecker bnaecker@stanford.edu

polyHandle = impoly(gca());
if isempty(polyHandle) || ~isvalid(polyHandle)
    pvx = [];
    pvy = [];
    return;
end
vertices = polyHandle.getPosition();
vertices(end + 1, :) = vertices(1, :);
pvx = vertices(:, 1);
pvy = vertices(:, 2);
delete(polyHandle);
return