function [r,g] = RateMMklog(tp,p)
% RateMMklog: Model for Michaelis-Menten firing rates and square pulses of ligand
% Like RateMMklin, except parameterized by log(Km) instead of k1 (Km = km/k1)
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = rprop
%	p(4) = log(Km)
%	p(5) = km
%	p(6) = T
%	p(7) = c
lkm = p(4);
c = p(7);
km = p(5);
k1 = km*exp(-lkm);

newp = p;
newp(4) = k1;
if (nargout == 1)
	r = RateMMklin(tp,newp);
else
	[r,gtemp] = RateMMklin(tp,newp);
	g = gtemp;
	% Change of variable rules...
	g(4,:) = -k1*gtemp(4,:);
	g(5,:) = exp(-lkm)*gtemp(4,:) + gtemp(5,:);
end
