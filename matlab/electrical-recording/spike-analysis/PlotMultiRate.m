function [xbinsout,ratesout] = PlotMultiRate(record,cellnum,width,trange,hrate)
% PlotMultiRate: like PlotRate, except it plots rates for all records separately
% PlotMultiRate(record,cellnum,trange,hrate)
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
% Binning parameters
oversamp = 10;
wide = 5;
wingsize = round(wide*oversamp);
nbins = oversamp*round((trange(2)-trange(1))/width);
xbins = linspace(trange(1)+width/(2*oversamp),trange(2)-width/(2*oversamp),nbins);
% Smoothing parameters
smoothrange = linspace(-wide,wide,2*wingsize+1);
smooth = exp(-smoothrange.^2/2);
norm = sum(smooth);
smooth = smooth/norm;			% Since this is a discrete approx, should be discretely normalized
dt = (trange(2)-trange(1))/nbins;
% Calculate the smoothed firing rates over each trial
rates = zeros(nbins+2*wingsize,length(record));
for i = 1:length(record)
	nperbin = hist(toSecs*record{i}.T{cellnum},xbins);
	rates(:,i) = conv(smooth,nperbin)'/dt;
end
maxr = max(1,max(max(rates)));
axis([trange 0 maxr]);
axis manual
hold on
plot(xbins,rates(wingsize+1:end-wingsize,:));

ylabel('Firing rate (Hz)');
if (nargin < 5)
	xlabel('Time (s)')
end
if (nargout > 0)
	xbinsout = xbins;
	ratesout = rates(wingsize+1:end-wingsize,:);
end
