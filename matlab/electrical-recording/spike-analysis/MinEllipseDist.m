function d = MinEllipseDist(x0,y0,C,m,b)
% MinEllipseDist: compute the minimum distance between a line and a point,
%	measured in elliptical coordinates.
% d = MinEllipseDist(x0,y0,C,m,b)
% The point is specified by (x0,y0), the error bars by the covariance
%	matrix C, and the line by its slope (m) and y-intercept (b)
Cinv = inv(C);
vl = [1;m];
x = (vl'*Cinv*[x0;y0-b])/(vl'*Cinv*vl);
dxy = [x-x0;m*x+b-y0];
d = sqrt(dxy'*Cinv*dxy);
