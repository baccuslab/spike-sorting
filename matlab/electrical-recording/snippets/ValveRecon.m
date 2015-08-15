function haxout = ValveRecon(filename,channel,tclust,stim,ylim)
% ValveRecon: reconstruct waveforms synchronized with valve openings
% haxout = ValveRecon(filename,channel,tclust,stim,ylim)
%      ylim is optional
[snip,time,h] = LoadSnip(filename,channel);
nstim = length(stim);
hax = [];
for i = 1:nstim
	hax(i) = subplot(nstim,1,i);
	tranges = stim{i}(2,[1 end]); % in seconds
	trange = round(tranges*h.scanrate);
	indx = find(time > trange(1) & time < trange(2));
	PlotRecon(snip(:,indx),time(indx),tclust,h.sniprange,h.scanrate,tranges(1));
	set(gca,'XLim',[0 tranges(2)-tranges(1)]);
	if (nargin == 5)
		set(gca,'YLim',ylim);
	end
end
if (nargout > 0)
	haxout = hax;
end
