function ellipse(pin,Cin,cnum)
% ellipse: 2-d error ellipses
ncells = size(Cin,3);
if (size(pin,2) ~= ncells)
	error('Number of cells does not match');
end
ang = linspace(0,2*pi,400);
x = sqrt(2.3)*cos(ang); y = sqrt(2.3)*sin(ang);
% First, figure out the area of each ellipse. Stack
%  them in order biggest to smallest
a = zeros(1,ncells);
for i = 1:ncells
	a(i) = sqrt(det(Cin(:,:,i)));
end
[sa,indx] = sort(a);
% Now figure out the range, and use this to set
%	the colorscale
if (ncells > 1)
	amin = sa(1);
else
	amin = 0;
end
aprop = 1/(sa(end)-amin);
for k = ncells:-1:1
	i = indx(k);
	[V,D] = eig(Cin(:,:,i));
	R = V*sqrt(D);
	% Old one: R = sqrt(D)*V';
	ellps = R*[x;y];
	xc = pin(1,i); yc = pin(2,i);
	ra = aprop*(a(i)-amin);	% relative area
	h = patch(exp(ellps(1,:) + xc),exp(ellps(2,:) + yc),0.9*[1 1 1]*(ra^(1/2)),'LineStyle','none');
	if (nargin == 3)
		text(xc,yc,sprintf('%d',cnum(i)));
	end
end
set(gca,'XScale','log','YScale','log')
