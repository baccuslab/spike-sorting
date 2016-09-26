function posout = SetAxPosNorm(posin,normin)
% SetAxPosNorm: compute axes limits as fraction of given rectangle
% posout = AxPosNorm(posin,normin)
% Given the position "posin" of a region (figure or axis,
%	in whatever units), and a new region given in relative coordinates,
%	compute the position for the new region in the original units
% All regions are specified by [left bottom width height].
posout = [posin(1:2) 0 0] + normin.*[posin(3:4) posin(3:4)];
