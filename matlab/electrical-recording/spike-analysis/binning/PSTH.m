function [rout,tout,rerrout] = PSTH(stim,spike,binwidth)
% PSTH: compute peri-stimulus time histogram for a particular stimulus
% (content & duration should be identical btw repeats)
% [rout,tout,rerrout] = PSTH(stim,spike,binwidth)
% stim, spike are cell arrays with the information for a single
% valve & cell.
% All times (rout^-1, tout, rerrout^-1, and binwidth) are
% measured in seconds.
nrpts = length(stim);
if (nrpts ~= length(spike))
	error('Number of repeats in stimulus and spike must agree');
end
Tsnip = stim{1}(2,end)-stim{1}(2,1);
for i = 2:nrpts
	if (abs(Tsnip-stim{i}(2,end)+stim{i}(2,1)) > 0.01)
		error('Not all stimulus presentations are of the same duration!');
	end
end
for i = 1:nrpts
	zspike{i} = spike{i} - stim{i}(2,1);
end
nbins = round(Tsnip/binwidth);
binwidth = Tsnip/nbins;
tsplit = (1:nbins-1)*binwidth;
npb = zeros(nrpts,nbins);
for i = 1:nrpts
	npb(i,:) = HistSplit(zspike{i},tsplit);
end
rout = mean(npb)/binwidth;
rerrout = std(npb)/(binwidth*sqrt(nrpts-1));
tout = [binwidth/2,tsplit + binwidth/2];
return;

allspikes = cat(2,zspike{:});
tout = linspace(binwidth/2,Tsnip-binwidth/2,nbins);
rout = hist(allspikes,tout);
rout = rout/(binwidth*nrpts);
