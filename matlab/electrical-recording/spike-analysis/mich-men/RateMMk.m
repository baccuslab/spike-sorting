function [r,g] = RateMMk(tp,p)
% RateMMk: Model for Michaelis-Menten firing rates and square pulses of ligand
% Like RateExpBase, with: kr = kp + km, kf = km, rstim = rprop*kp/(kp+km)
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = rprop
%	p(4) = kp
%	p(5) = km
%	p(6) = T
rprop = p(3);
kp = p(4);
km = p(5);

newp = p;
kr = kp+km;
rstim = rprop*kp/kr;
newp(3) = rstim;
newp(4) = kr;
if (nargout == 1)
	r = RateExpBase(tp,newp);
else
	[r,gtemp] = RateExpBase(tp,newp);
	g = gtemp;
	% Change of variable rules...
	g(3,:) = (kp/kr)*gtemp(3,:);
	g(4,:) = gtemp(4,:) + (rprop*km/kr^2)*gtemp(3,:);
	g(5,:) = gtemp(5,:) + gtemp(4,:) - (rprop*kp/kr^2)*gtemp(3,:);
end
