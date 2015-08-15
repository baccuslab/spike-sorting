function [texp,rexp,tth,rth] = PlotdataPSTRate(spikes,trange,pvar,varloc,pfix,fixloc,nparms,ratefunc,dt)
% PlotdataPSTRate: calculate binned data & theoretical curves for plotting
% [texp,rexp,tth,rth] = PlotdataPSTRate(spikes,trange,pvar,varloc,pfix,fixloc,nparms,ratefunc,dt)
nexp = length(spikes);
dims = [nparms nexp];
p = untangle(pvar,varloc,dims)+untangle(pfix,fixloc,dims);
for i = 1:nexp
	allspikes = sort(cat(2,spikes{i}{:}));
	Tsnip = trange(2,i)-trange(1,i);
	nbins = Tsnip/dt;
	nrpts = length(spikes{i});
	texp{i} = linspace(trange(1,i)+dt/2,trange(2,i)-dt/2,nbins);
	rexp{i} = hist(allspikes,texp{i})/(dt*nrpts);
	rth{i} = feval(ratefunc,texp{i},p(:,i));
	tth{i} = texp{i};
end
