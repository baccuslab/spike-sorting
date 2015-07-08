function [ir,g] = IntRateExpBase(trangep,p)
% IntRateExpBase: Model for non-adapting firing rates with exponential transition times and square pulses of ligand
%	ir = IntRateExpBase(trange,p) returns the definite integral from
%		trange(1) to trange(2) of the model described in RateExpBase.
%	[ir,g] = IntRateExpBase(trange,p) also returns the gradient
%		with respect to the parameters.
%
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = rstim
%	p(4) = kr
%	p(5) = kf
%	p(6) = T
tdelay = p(1);
rspont = p(2);
rstim = p(3);
kr = p(4);
kf = p(5);
T = p(6);

trange = trangep - tdelay;
dt = diff(trange);
trm = IntersectIntervals(trange,[0,T]);
%trr = IntersectIntervals(trange,[T,Inf]);
trr = IntersectIntervals(trange,[T,trange(2)+1]);
eAtOff = exp(-kr*T);
fracAtOff = 1-eAtOff;
% Do the spont. contribution right now
ir = rspont*dt;
if (nargout == 2)
	g = zeros(5,1);
	g(2) = dt;	% \partial_tspont
end
if (isempty(trm) & isempty(trr))	% speedy exit
	return
end
% Gradient with respect to tdelay requires
% special handling, so do this now
if (nargout == 2)
	if (~isempty(trm))
		if (trm(1) == trange(1))
			g(1) = g(1)+rstim*(1-exp(-kr*trm(1)));
		end
		if (trm(2) == trange(2))
			g(1) = g(1)-rstim*(1-exp(-kr*trm(2)));
		end
	end
	if (~isempty(trr))
		if (trr(1) == trange(1))
			g(1) = g(1)+rstim*fracAtOff*exp(-kf*(trr(1)-T));
		end
		if (trr(2) == trange(2))
			g(1) = g(1)-rstim*fracAtOff*exp(-kf*(trr(2)-T));
		end
	end
end
% Now can cheat on the definition of the overlapping
% intervals
if isempty(trm)
	trm = [0 0];
end
if isempty(trr)
	trr = [0 0];
end
% OK, let's do it
em = exp(-kr*trm);
er = exp(-kf*(trr-T));
i2p = -diff(em)/kr;
i3p = -diff(er)/kf;
i2 = diff(trm) - i2p;
i3 = fracAtOff*i3p;

ir = ir + rstim*(i2+i3);
if (nargout == 2)
	% \partial_rstim
	g(3) = i2+i3;
	% \partial_kr
	g(4) = rstim*(-diff(trm.*em)/kr + i2p/kr + T*eAtOff*i3p);
	% \partial_kf
	g(5) = rstim*fracAtOff*(diff((trr-T).*er)/kf - i3p/kf);
end
