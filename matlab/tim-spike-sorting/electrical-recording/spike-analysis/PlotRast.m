function PlotRast(record,cellnum,trange,hrast)
% PlotRast(record,cellnum,trange,hrast)
% record: the cell-array with the stimulus info & neural responses,
%    arranged in records
% cellnum: the cell # to plot
% trange: the range of the time axis (will be calculated if omitted)
% hrast: axis handle for the raster plot (will create a new plot window if omitted)
if (nargin < 2)
	error('PlotRast needs at least 2 arguments');
elseif (nargin == 2)
	trange = GetRecTimeRange(record);
end
if (nargin < 4)
	figure
	hrast = gca;
end
axes(hrast)
axis([trange 0 length(record)+1]);
hold on
toSecs = 50e-6;
for i = 1:length(record)
	y1 = ones(1,length(record{i}.T{cellnum}));
	y = [(i-0.2)*y1;(i+0.2)*y1];
	x = [toSecs*record{i}.T{cellnum};toSecs*record{i}.T{cellnum}];
	plot(x,y,'b');
end
hold off

ylabel('Repeat #');
if (nargin < 4)
	xlabel('Time (s)');
else
	bkgndcol = get(gcf,'Color');
	set(hrast,'XColor',bkgndcol);
end
dx = 1;
if (length(record) > 10)
	dx = 5;
end
if (length(record) > 20)
	dx = 10;
end
yt(1) = 1;
i = 1;
while (yt(i) + dx <= length(record))
	i = i + 1;
	yt(i) = yt(i-1)+dx;
end
set(hrast,'YTick',yt);
set(hrast,'YDir','reverse');
