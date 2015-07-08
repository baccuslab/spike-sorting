function pbest = FitPSTRate(spikes,pvarstart,pvarrange,nperbin)
%global gTRange gVarLoc gPFix gFixLoc
global gTRange gSpikes gNRpts gNExp gIntRateFunc
% First, unify the repeats
gNExp = length(spikes);
for i = 1:gNExp
	gNRpts(i) = length(spikes{i});
	gSpikes{i} = sort(cat(2,spikes{i}{:}));
end
% Now set up vertices of simplex
np = length(pvarstart);
pin = repmat(pvarstart,1,np+1) + [zeros(np,1),diag(pvarrange,0)];
% Optimize the parameters
%[pout,yout,nfunk] = amoebasafe(pin,1e-6,'PSTRateUntangle');
%pbest = pout(:,1);
pbest = fmins('PSTRateUntangle',pvarstart);
