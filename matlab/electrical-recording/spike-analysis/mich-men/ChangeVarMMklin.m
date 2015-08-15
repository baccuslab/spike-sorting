function [pout,W] = ChangeVarMMklin(pin)
% ChangeVarMMklin: Change from (tdelay, km, rprop, k1f, k1m) to (tdelay, km, rprop, rprop*k1f/km, rprop*k1m/km)
% [pout,W] = ChangeVarMMklin(pin)
% W is the chain-rule matrix, partial(old)/partial(new). Cnew = Winv'*Cold*Winv
k1f = pin(4); k1m = pin(5); rprop = pin(3); km = pin(2);
pout = [pin(1:3); rprop*k1f/km; rprop*k1m/km];
W = [1 0 0 0 0; 0 1 0 k1f/km k1m/km; 0 0 1 -k1f/rprop -k1m/rprop; 0 0 0 km/rprop 0; 0 0 0 0 km/rprop];
%pout = [pin(1:3); rprop*k1f; rprop*k1m];
%W = [1 0 0 0 0; 0 1 0 0 0; 0 0 1 -k1f/rprop -k1m/rprop; 0 0 0 1/rprop 0; 0 0 0 0 1/rprop];
