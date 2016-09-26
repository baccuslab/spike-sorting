function ir = intexprate(trange,p)
trange(1) = max(0,trange(1));
trange(2) = max(0,trange(2));
ir = p(1)/p(2) * (exp(-p(2)*trange(1))-exp(-p(2)*trange(2)));
