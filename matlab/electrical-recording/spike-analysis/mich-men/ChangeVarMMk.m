function [pout,W] = ChangeVarMMk(pin)
% ChangeVarMMk: Change from (tdelay, km, rprop, kpf, kpm) to (tdelay, km, rprop, rprop*kpf/(kpf+km), rprop*kpm/(kpm+km))
% [pout,W] = ChangeVarMMk(pin)
% W is the chain-rule matrix, partial(new)/partial(old). Cnew = Winv'*Cold*Winv
kpf = pin(4); kpm = pin(5); rprop = pin(3); km = pin(2);
pout = [pin(1:3); rprop*kpf/(kpf+km); rprop*kpm/(kpm+km)];
W = [1 0 0 0 0; 0 1 0 -rprop*kpf/(kpf+km)^2 -rprop*kpm/(kpm+km)^2; 0 0 1 kpf/(kpf+km) kpm/(kpm+km); 0 0 0 rprop*km/(kpf+km)^2 0; 0 0 0 0 rprop*km/(kpm+km)^2];
%W = [1 0 0 0 0; 0 1 0 0 0; 0 0 1 -k1f/rprop -k1m/rprop; 0 0 0 1/rprop 0; 0 0 0 0 1/rprop];
