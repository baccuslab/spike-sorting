function [ll,meanll,varll] = ExpectPSTRate(spikes,trange,pvar,varloc,pfix,fixloc,nparms,ratefunc,intratefunc)
% ExpectPSTRate: estimates for goodness-of-fit parameters for a poisson process
% [ll,meanll,varll] = ExpectPSTRate(spikes,trange,pvar,varloc,pfix,fixloc,nparms,ratefunc,intratefunc)
% Reports the mean expected log likelihood and
%	variance in the expected log likelihood for a model with
%	Poisson firing statistics. Also reports the log likelihood
%	of the experimental spike train, given the model.
%
% See StatPSTRate for an explanation of the input parameters.
% Outputs: ll, meanll, and varll are vectors of length nexp,
%	where the values are reported for each experiment separately.
%	The combined value is obtained by summing over the individual
%	experiments.
% A rough measure of the goodness of fit is abs(ll-meanll)/sqrt(varll);
%	this tells you the number of standard deviations away from the
%	expected value.
nexp = size(trange,2);
dims = [nparms nexp];
p = untangle(pvar,varloc,dims) + untangle(pfix,fixloc,dims);
for i = 1:nexp
	nrpts(i) = length(spikes{i});
	ll(i) = PSTRateLL(sort(cat(2,spikes{i}{:})),trange(:,i),p(:,i),nrpts(i),ratefunc,intratefunc);
	c(1,i) = quad('logrm1',trange(1,i),trange(2,i),[],[],p(:,i),ratefunc);
	c(2,i) = quad('logr2',trange(1,i),trange(2,i),[],[],p(:,i),ratefunc);
end
meanll = nrpts.*c(1,:);
varll = nrpts.*c(2,:);
