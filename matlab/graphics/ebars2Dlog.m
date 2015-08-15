function hpatch = ebars2Dlog(pin,Cin,cnum)
% ebars2Dlog: 2-d error bars on a log-log plot
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
fac = sqrt(2.3);
for k = ncells:-1:1
	i = indx(k);
	[V,D] = eig(Cin(:,:,i));
	R = fac*V*sqrt(D);
	xc = pin(1,i); yc = pin(2,i);
	% The columns of R are the principal axes
	heb1 = line(exp([xc-R(1,1),xc+R(1,1)]),exp([yc-R(2,1),yc+R(2,1)]),'Color',0.5*[1 1 1]);
	heb2 = line(exp([xc-R(1,2),xc+R(1,2)]),exp([yc-R(2,2),yc+R(2,2)]),'Color',0.5*[1 1 1]);
	hpatch(i) = line(exp(xc),exp(yc),'LineStyle','none','Marker','o','MarkerFaceColor','k',...
		'MarkerEdgeColor','k','MarkerSize',4,'Tag','Cntr');
%	h = patch(exp(ellps(1,:) + xc),exp(ellps(2,:) + yc),0.9*[1 1 1]*(ra^(1/2)),'LineStyle','none');
	if (nargin == 3)
		text(xc,yc,sprintf('%d',cnum(i)));
	end
end
set(gca,'XScale','log','YScale','log')
