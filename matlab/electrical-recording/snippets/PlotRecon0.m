function PlotRecon(snips,tsnips,tclust,sniprange)
% PlotRecon: Reconstruct waveform from sorted spikes (color code cells)
% PlotRecon(snips,tsnips,tclust,sniprange)
% tclust is a cell array of spike time vectors, one for each sorted cell
% All times are in units of scan #s!
ncells = length(tclust);
clustindx = cell(1,1+ncells);	% The first is the unassigned group
for i = 1:ncells
	[common,cindx] = intersect(tsnips,tclust{i});
	clustindx{i+1} = cindx;
end
cindx = cat(1,clustindx{:});
clustindx{1} = setdiff(1:length(tsnips),cindx);
hold on
set(gca,'XLim',[tsnips(1)+sniprange(1),tsnips(end)+sniprange(end)]);
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:(ncells+1)
	[wcell,tcell] = ReconstructWaveform(snips(:,clustindx{i}),tsnips(clustindx{i}),sniprange);
	plot(tcell,wcell,'Color',co(mod(i-1,ncol)+1,:));
end
