function igrnd = logr2(t,p,ratefunc)
r = feval(ratefunc,t,p);
igrnd = r.*log(r).^2;
