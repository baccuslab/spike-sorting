function [ir,g] = IntRateMMlinkoff(trangep,p)
% IntRateMMkoff: linear Michaelis-Menten model for firing rates, with hidden koff
% Like IntRateExpBase, except kr = k1*c+koff and rstim = rprop*k1*c/(k1*c + koff)
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = k1
%	p(4) = rprop
%	p(5) = kf
%	p(6) = koff
%	p(7) = T
%	p(8) = c
rprop = p(4);
k1 = p(3);
koff = p(6);
c = p(8);

newp = [p(1:5);p(7)];
kr = k1*c+koff;
newp(4) = kr;
newp(3) = rprop*k1*c/kr;
if (nargout == 1)
	ir = IntRateExpBase(trangep,newp);
else
	[ir,gtemp] = IntRateExpBase(trangep,newp);
	g = gtemp;
	% Change of variable rules...
	g(3,:) = c*gtemp(4,:) + rprop*koff*c/kr^2 * gtemp(3,:);
	g(4,:) = k1*c/kr * gtemp(3,:);
	g(6,:) = gtemp(4,:) - rprop*k1*c/kr^2 * gtemp(3,:);
end
