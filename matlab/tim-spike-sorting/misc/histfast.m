function [n,x] = histfast(y,m)
% histfast: compute histogram quickly, for equally spaced bins
% [n,x] = histfast(y,m)
% y,n,x are all vectors
% m is the number of bins (default: 10)
% x contains the bin centers
if (nargin == 1)
	m = 10;
end
if (m ~= round(m))
	error('m must be an integer');
end
ymax = max(y);
ymin = min(y);
yi = round((y-ymin)*(m/(ymax-ymin))+0.5);	% Maps to the range [0.5,m+0.5], then rounds
o = ones(size(yi));
ntemp = sparse(yi,o,o,m+1,1);	% m+0.5 gets rounded to m+1, have to allow this
n = full(ntemp(1:m));
n(end) = n(end)+ntemp(m+1);
if (nargout == 2)
	binwidth = (ymax-ymin)/m;
	x = ymin + binwidth*((0:m-1)+0.5);
end
