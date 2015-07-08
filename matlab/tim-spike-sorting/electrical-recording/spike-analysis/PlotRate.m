function PlotRate(record,cellnum,width,trange,hrate)
% PlotRast(record,cellnum,trange,hrate)
% record: the cell-array with the stimulus info & neural responses,
%    arranged in records
% cellnum: the cell # to plot
% width: the width of the smoothing gaussian (in seconds)
% trange: the range of the time axis (will be calculated if omitted)
% hrate: axis handle for the raster plot (will create a new plot window if omitted)
%
% This version bins the spikes into bins of width/10, then smooths this with
% the gaussian. Should be much faster.
if (nargin < 3)
	error('PlotRate needs at least 3 arguments');
elseif (nargin == 3)
	trange = GetRecTimeRange(record);
end
if (nargin < 5)
	figure
	hrate = gca;
end
axes(hrate)

toSecs = 50e-6;
allspikes = [];
for i = 1:length(record)
	allspikes(end+1:end+length(record{i}.T{cellnum})) = record{i}.T{cellnum};
end

allspikes = toSecs*allspikes;
oversamp = 10;
wide = 5;
wingsize = round(wide*oversamp);
nbins = oversamp*(trange(2)-trange(1))/width;
xbins = linspace(trange(1)+width/(2*oversamp),trange(2)-width/(2*oversamp),nbins);
nperbin = hist(allspikes,xbins);
smoothrange = linspace(-wide,wide,2*wingsize+1);
smooth = exp(-smoothrange.^2/2);
norm = sum(smooth);
smooth = smooth/norm;			% Since this is a discrete approx, should be discretely normalized
dt = (trange(2)-trange(1))/nbins;
rate = conv(smooth,nperbin)/(length(record)*dt);
maxr = max(rate);
axis([trange 0 maxr]);
axis manual
hold on
plot(xbins,rate(wingsize+1:end-wingsize));

ylabel('Firing rate (Hz)');
if (nargin < 5)
	xlabel('Time (s)')
end
