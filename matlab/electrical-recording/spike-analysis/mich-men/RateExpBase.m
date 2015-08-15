function [r,g] = RateExpBase(tp,p)
% RateExpBase: Model for non-adapting firing rates with exponential transition times and square pulses of ligand
% r = RateExpBase(t,p)
% r = rspont + rstim * f(t), where:
%	f(t) = 0                           for     t < 0
%	f(t) = 1-exp(-kr*t)                for 0 < t < T
%	f(t) = (1-exp(-kr*T))*exp(-kf*t)   for T < t
% In addition, the input times may be offset by a time tdelay, i.e.
%	if the user inputs times t', then use times t = t'-tdelay
%	when plugging into the formulas above.
%
% Parameters:
%	p(1) = tdelay
%	p(2) = rspont
%	p(3) = rstim
%	p(4) = kr
%	p(5) = kf
%	p(6) = T
%
%
% [r,g] = RateExpBase(t,p) also calculates the gradients of the
%	rate with respect to the first 5 parameters
tdelay = p(1);
rspont = p(2);
rstim = p(3);
kr = p(4);
kf = p(5);
T = p(6);

t = tp - tdelay;
im = find(t > 0 & t <= T);
ir = find(t > T);
em = exp(-kr*t(im));		% Calculate these exponentials only once
er = exp(-kf*(t(ir)-T));
eAtOff = exp(-kr*T);
fracAtOff = 1-eAtOff;

r = zeros(1,length(t)) + rspont;
r(im) = r(im) + rstim*(1-em);
r(ir) = r(ir) + rstim*fracAtOff*er;

% Do the gradients
if (nargout == 2)
	g = zeros(5,length(t));
	% \partial_tdelay
	g(1,im) = -rstim*kr*em;
	g(1,ir) = rstim*fracAtOff*kf*er;
	% \partial_rspont
	g(2,:) = 1;
	% \partial_rstim
	g(3,im) = 1-em;
	g(3,ir) = fracAtOff*er;
	% \partial_kr
	g(4,im) = rstim*t(im).*em;
	g(4,ir) = rstim*T*eAtOff*er;
	% \partial_kf
	g(5,ir) = -rstim*fracAtOff*(t(ir)-T).*er;
end
