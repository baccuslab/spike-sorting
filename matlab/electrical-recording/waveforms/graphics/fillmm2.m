function h = fillmm2(vmin,vmax,x)
% fillmm2(vmin,vmax,dx) plots filled polygonal region
% for a function whose envelope is specified by ymin,ymax pairs
% in the structure envmm
% The x coords are given by x

% Have to work around a bug in the MATLAB code, with limit
% on number of points passed to fill
h = fillmm2work(vmin,vmax,x);
return;
if (nargin==2)
	x = (1:length(vmin));
end
imax = 11;
if (length(vmin) > imax)
	l = length(vmin);
	n = ceil(l/imax);
	vmin(l+1:n*imax) = vmin(l);	% pad the end, for reshape
	vmax(l+1:n*imax) = vmax(l);
	x(l+1:n*imax) = x(l);
	vminr = reshape(vmin,n,imax);
	vmaxr = reshape(vmax,n,imax);
	xr = reshape(x,n,imax);
	fillmm2work(vminr,vmaxr,xr);
else
	fillmm2work(vmin,vmax,x);
end
return;


function h = fillmm2work(vmin,vmax,x)
yy = [vmin flipdim(vmax,2)];
xx = [x flipdim(x,2)];
h = fill(xx,yy,'b','EdgeColor','b');
return
