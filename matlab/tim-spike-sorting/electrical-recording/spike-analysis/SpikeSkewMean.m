function sm = SpikeSkewMean(spikes,tsplit)
nrpts = length(spikes);
nbins = length(tsplit)+1;
npb = zeros(nrpts,nbins);
for i = 1:nrpts
	npb(i,:) = HistSplit(spikes{i},tsplit);
end
sm = SkewMean(npb);
