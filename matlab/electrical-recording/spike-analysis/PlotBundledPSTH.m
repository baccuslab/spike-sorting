function PlotBundledPSTH(stim,spike,binwidth,toff,ebars)
% PlotBundledPSTH: PSTH plots with multiple lines
% PlotBundledPSTH(stim,spike,binwidth,toff,ebars)
% 	stim & spike are of the format CollectResponses/UnifyResponses
%	binwidth, toff (time offset) are measured in seconds (toff defaults to 0)
%	ebars is a flag: if true, error bars are plotted
if (nargin < 4)
	toff = 0;
end
if (nargin < 5)
	ebars = 0;
end
if isempty(toff)
	toff = 0;
end
if ~(iscell(stim) & iscell(spike))
	error('All inputs must be cell arrays of cell arrays, one bundle/cell');
end
nbundles = length(stim);
if (length(spike) ~= nbundles)
	error('Number of bundles inconsistent');
end
nrpts = zeros(1,nbundles);
for i = 1:nbundles
	nrpts(i) = length(stim{i});
	if (length(spike{i}) ~= nrpts(i))
		error('Inconsistent number of repeats');
	end
end
cnrpts = cumsum(nrpts);
nrptstot = cnrpts(end);
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
set(gca,'XLim',[0 tmax]+toff);
hold on
% Plot the PSTH
for i = 1:nbundles
	colindx = mod(i-1,ncol)+1;	% Wrap-around color indices
	[r,t,err] = PSTH(stim{i},spike{i},binwidth);
	if ~ebars
		plot(t+toff,r,'Color',co(colindx,:));
	else
		errorbars(t+toff,r,err,'Color',co(colindx,:));
	end
end
hold off
