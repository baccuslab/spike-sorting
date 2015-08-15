function igrnd = logrm1(t,p,ratefunc)
r = feval(ratefunc,t,p);
igrnd = r.*(log(r)-1);

