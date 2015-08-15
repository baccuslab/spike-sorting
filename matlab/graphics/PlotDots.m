function hlines = PlotDots(x,Y,spacing)
% PlotDots: give user control over spacing of dotted lines
% hlines = PlotDots(x,Y,spacing)
% The one tricky part is that spacing has to be done in terms
% of normalized units, rather than physical units; therefore,
% you must set the axis limits to their final values BEFORE
% calling this function. "spacing" is provided in normalized units.
x = x(:);
npts = length(x);
nvecs = size(Y,2);
co = get(gca,'ColorOrder');
ncol = size(co,1);
xlim = get(gca,'XLim');
ylim = get(gca,'YLim');
xscale = diff(xlim); yscale = diff(ylim);
for i = 1:nvecs
	y = Y(:,i);
	ds = sqrt(diff(x/xscale).^2 + diff(y/yscale).^2);
	s = [0;cumsum(ds)];
	npts = ceil(s(end)/spacing);
	se = linspace(0,s(end),npts);
	XYe = interp1(s,[x y],se);
	colindx = mod(i-1,ncol)+1;
	hlines(i) = line(XYe(:,1),XYe(:,2),'LineStyle','none',...
		'Marker','.','Color',co(colindx,:));
end
