function h = points(x,y,z,c)
% h = points(x,y,z,c)
% Plot the points specified by (x,y) with
% a (uniform) color specified by the RGB triple c,
% with an intensity given by z (one intensity/point)
% z must be in the range [0 1].
newplot
if (size(z,1) == 1)
	z = z';
end
if (size(c,2) == 1)
	c = c';
end
% Have to trick matlab into plotting as points even
% though we will use line, so plot each point as a line
% to itself
if (size(x,1) == 1)
	xc = [x;x];
else
	xc = [x';x'];
end
if (size(y,1) == 1)
	yc = [y;y];
else
	yc = [y';y'];
end

co = z*c + (1-z)*get(gca,'Color');		% Interpolate between the desired color & the background
set(gca,'ColorOrder',co);
line(xc,yc);
