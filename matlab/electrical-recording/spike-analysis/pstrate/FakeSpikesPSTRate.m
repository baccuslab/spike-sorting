function spikes = FakeSpikesPSTRate(iratefunc,p,trange,nrpts)
nbins = 1000;
tsplit = linspace(trange(1),trange(2),nbins+1);
intbin = zeros(nbins,1);
for i = 1:nbins
	intbin(i) = feval(iratefunc,tsplit(i:i+1),p);
end
cintbin = cumsum(intbin);
cibl = [0;cintbin(1:end-1)];
mnnsp = cintbin(nbins);
nsp = poissrnd(mnnsp,1,nrpts);
dT = diff(trange);
for i = 1:nrpts
	tinv = mnnsp*rand(1,nsp(i));
	npb = HistSplit(tinv,cintbin');
	spikes{i} = [];
	indx = find(npb > 0);
	while (~isempty(indx))
		spikes{i} = [spikes{i},trange(1)+(indx-rand(1,length(indx)))*dT/nbins];
		npb = npb-1;
		indx = find(npb > 0);
	end
	spikes{i} = sort(spikes{i});
end	
