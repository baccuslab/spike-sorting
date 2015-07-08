function CheckChannelEnv(denv,decfactor,snips,tsnips,tclust,sniprange,trange)
% CheckChannelEnv: check envelopes against sorted spikes
% CheckChannelEnv(denv,decfactor,snips,tsnips,tclust,sniprange,trange)
% where
%	denv is a 2-by-n matrix of envelope data
%	decfactor is the decimation factor in making the envelope
%	snips is a matrix of snippets
%	tsnips is the peak time for snips
%	tclust is a cell array, where each cell contains the vector
%		of spike times for the sorted spikes
%	sniprange is the [snipbegin,snipend] relative to peak
%	trange (optional) specifies a subrange of time to plot (default:all)
%
% All times are measured in scan #.
tdec = (0:(size(denv,2)-1))*decfactor;
if (nargin < 7)
	trange = [0,tdec(end)+decfactor-1];
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
tdecsubindx = find(tdec >= trange(1) & tdec <= trange(2));
%fillmm2(denv(1,tdecsubindx),denv(2,tdecsubindx),tdec(tdecsubindx));
plot(tdec(tdecsubindx),denv(2,tdecsubindx));
subplot(2,1,2)
hold on
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:(ncells+1)
	[wcell,tcell] = ReconstructWaveform(snips(:,clustindx{i}),tsnips(clustindx{i}),sniprange,trange);
	plot(tcell,wcell,'Color',co(mod(i-1,ncol)+1,:));
end
ylim = get(gca,'YLim');
subplot(2,1,1)
set(gca,'YLim',ylim);
XZoomAll
