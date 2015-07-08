function [r,g] = IntRateMMklin(trangep,p)
% IntRateMMklin: Model for Michaelis-Menten firing rates and square pulses of ligand
% Like IntRateMMk, with kp = k1*c
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = rprop
%	p(4) = k1
%	p(5) = km
%	p(6) = T
%	p(7) = c
k1 = p(4);
c = p(7);

newp = p(1:6);
kp=k1*c;
newp(4) = kp;
if (nargout == 1)
	r = IntRateMMk(trangep,newp);
else
	[r,gtemp] = IntRateMMk(trangep,newp);
	g = gtemp;
	% Change of variable rules...
	g(4,:) = c*gtemp(4,:);
end
