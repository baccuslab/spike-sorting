function [spikeout,rspont,rsponterr] = ClipSpike0(spikein,tr)
% ClipSpike0: clip all spikes occuring before time 0, and return rspont
% [spikeout,rspont,rsponterr] = ClipSpike0(spikein,tr)
% Note: rsponterr really makes sense only when the duration of the intervals
%	before 0 is equal across all experiments.
nexp = length(spikein);
spikeout = cell(1,nexp);
numspike0 = [];			% Catalog of number of spikes before t = 0
time0 = [];				% Catalog of recording duration before t = 0
for i = 1:nexp
	nrpts = length(spikein{i});
	spikeout{i} = cell(1,nrpts);
	for j = 1:nrpts
		indx = find(spikein{i}{j} > 0);
		spikeout{i}{j} = spikein{i}{j}(indx);
		numspike0(end+1) = length(spikein{i}{j}) - length(indx);
		time0(end+1) = max(-tr(1,i),0);
	end
end
rspont = sum(numspike0)/sum(time0);
indx = find(time0);
rs = numspike0(indx)./time0(indx);
rsponterr = std(rs)/sqrt(length(rs));
if (nargout == 3)
	sk = SkewMean(numspike0');
	if (sk > 0.5)
		warnmsg = sprintf('Skewness of %g in bins in time before 0',sk);
		warning(warnmsg);
	end
end
