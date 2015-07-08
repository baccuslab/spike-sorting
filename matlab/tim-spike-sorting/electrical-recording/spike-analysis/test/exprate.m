function r = exprate(t,p)
r = zeros(size(t));
indx = find(t < 0);
r(indx) = 0;
indx = find(t >= 0);
r(indx) = p(1)*exp(-t(indx)*p(2));
