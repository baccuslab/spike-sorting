function PlotBundledRast(stim,spike,ylabels,toff)
% PlotBundledRast: raster plots with multiple panels
% PlotBundledRast(stim,spike,ylabels)
% 	stim & spike are of the format CollectResponses/UnifyResponses
%	ylabels (optional) is a cell array of bundle names
%	toff (optional) is the time offset (measured in seconds)
%	If only one of ylabels, toff is being supplied, they may be in any order
if ~(iscell(stim) & iscell(spike))
	error('All inputs must be cell arrays of cell arrays, one bundle/cell');
end
nbundles = length(stim);
if (nargin < 3)
	ylabels = cell(1,nbundles);
	toff = 0;
elseif (nargin < 4)
	if (isnumeric(ylabels) & length(ylabels) == 1)
		toff = ylabels;
		ylabels = cell(1,nbundles);
	end
end
if (length(spike) ~= nbundles | length(ylabels) ~= nbundles)
	error('Number of bundles inconsistent');
end
nrpts = zeros(1,nbundles);
for i = 1:nbundles
	nrpts(i) = length(stim{i});
	if (length(spike{i}) ~= nrpts(i))
		error('Inconsistent number of repeats');
	end
end
% Set the y values of the rasters, leaving a gap for the different bundles
cnrpts = cumsum(nrpts);
nrptstot = cnrpts(end);
bindx = [0,cnrpts];
bshift = [0,cnrpts + (1:nbundles)];
yc = cell(1,nbundles);
for i = 1:nbundles
	yc{i} = bshift(i) + (1:nrpts(i)); 
end
y = cat(2,yc{:});
% Compute the time range, as the maximum range in stim
allstim = cat(2,stim{:});
tr = zeros(nrptstot,2);
for i = 1:nrptstot
	tr(i,:) = allstim{i}(2,[1 end]);
end
tmax = max(diff(tr'));
% Do the necessary graphics preliminaries
newplot
co = get(gca,'ColorOrder');
ncol = size(co,1);
set(gca,'YDir','Reverse','XLim',[0 tmax]+toff,'YLim',[0 y(end)+1]);
set(gca,'YTick',[]);
% Plot the boundary lines
for i = 1:nbundles-1
	line([0 tmax]+toff,yc{i}(end)+[1 1],'Color','k','LineStyle',':','Tag','Boundary');
end
% Label the bundles, if labels were supplied
ym = zeros(1,nbundles);
for i = 1:nbundles
	ym(i) = mean(yc{i}([1 end]));
end
set(gca,'YTick',ym,'YTickLabel',ylabels,'TickLength',[0 0]);
% Plot the rasters
for i = 1:nbundles
	colindx = mod(i-1,ncol)+1;	% Wrap-around color indices
	for j = 1:nrpts(i)
		k = j + bindx(i);		% index within concatenated data
		nspikes = length(spike{i}{j});
		thisy = [ones(1,nspikes)+0.2;ones(1,nspikes)-0.2] + y(k)-1;
		x = repmat(spike{i}{j}-tr(k,1),2,1);
		line(x+toff,thisy,'Color',co(colindx,:),'LineWidth',0.25,'Tag','Rast');
	end
end
