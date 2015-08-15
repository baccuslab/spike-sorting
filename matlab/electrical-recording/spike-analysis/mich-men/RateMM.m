function [r,g] = RateMM(tp,p)
% RateMM: Michaelis-Menten model for firing rates and square ligand pulses
% Like RateExpBase, except kr = kf/(1-rstim/rprop) (MM kinetics)
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = rstim
%	p(4) = rprop
%	p(5) = kf
%	p(6) = T
rstim = p(3);
rprop = p(4);
kf = p(5);

newp = p;
fr = 1-rstim/rprop;
newp(4) = kf/fr;
if (nargout == 1)
	r = RateExpBase(tp,newp);
else
	[r,gtemp] = RateExpBase(tp,newp);
	g = gtemp;
	% Change of variable rules...
	g(3,:) = gtemp(3,:) + (kf/(rprop*fr^2))*gtemp(4,:);
	g(4,:) = -(kf*rstim/(fr^2*rprop^2))*gtemp(4,:);
	g(5,:) = gtemp(5,:) + gtemp(4,:)/fr;
end
