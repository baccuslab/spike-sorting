function loglike = PSTRateLL(spikes,trange,p,nrpts,ratefunc,intratefunc)
r = feval(ratefunc,spikes,p);
if (~isempty(find(r<=0)))
	loglike = -Inf;
	return;
end
loglike = sum(log(r)) - nrpts*feval(intratefunc,trange,p);
