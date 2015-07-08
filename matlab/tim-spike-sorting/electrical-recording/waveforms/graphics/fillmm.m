function hpatch = fillmm(envmm,x)
% hpatch = fillmm(envmm,x) plots filled polygonal region
% for a function whose envelope is specified by ymin,ymax pairs
% in the structure envmm
% The x coords are given by x
if (nargin==1)
	x = 1:size(envmm.min,2);
end
yy = [envmm.min flipdim(envmm.max,2)];
xx = [x flipdim(x,2)];
hpatch = fill(xx,yy,'b','EdgeColor','b');
