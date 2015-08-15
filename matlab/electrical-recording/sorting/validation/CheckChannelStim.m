function CheckChannelStim(stim,snips,tsnips,tclust,sniprange,trange)
% CheckChannelStim: check stimulus against sorted spikes
% CheckChannelStim(stim,snips,tsnips,tclust,sniprange,trange)
% where
%	stim is a 2-by-n matrix of stimulus information (see ReadVlv)
%	snips is a matrix of snippets
%	tsnips is the peak time for snips
%	tclust is a cell array, where each cell contains the vector
%		of spike times for the sorted spikes
%	sniprange is the [snipbegin,snipend] relative to peak
%	trange (optional) specifies a subrange of time to plot (default:all)
%
% All times are measured in scan #.
if (nargin < 6)
	trange = [0,stim(2,end)-1];
end
ncells = length(tclust);
clustindx = cell(1,1+ncells);	% The first is the unassigned group
for i = 1:ncells
	[common,cindx] = intersect(tsnips,tclust{i});
	clustindx{i+1} = cindx;
end
cindx = cat(1,clustindx{:});
clustindx{1} = setdiff(1:length(tsnips),cindx);
newplot
subplot(2,1,1)
stsnip = StimSnip(stim,trange);
xlim = [stsnip(2,1),stsnip(2,end)];
stairs(stsnip(2,:),stsnip(1,:));
set(gca,'XLim',xlim);
subplot(2,1,2)
hold on
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:(ncells+1)
	[wcell,tcell] = ReconstructWaveform(snips(:,clustindx{i}),tsnips(clustindx{i}),sniprange,trange);
	plot(tcell,wcell,'Color',co(mod(i-1,ncol)+1,:));
end
set(gca,'XLim',xlim);
XZoomAll
