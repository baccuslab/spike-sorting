function [ok,badindx] = PCheckRateMMk(p)
ok = 1;
% No negative rate constants
[badindxr,badindx] = find(p(5,:) < 0);
% Keep tdelay in range [0,2]
badindx = [badindx,find(p(1,:) > 2),find(p(1,:) < 0)];
% No NaNs or Infs
snan = sum(isnan(p));
badindx = [badindx,find(snan)];
sinf = sum(isinf(p));
badindx = [badindx,find(sinf)];
% Tidy everything
badindx = sort(badindx);
if ~isempty(badindx)
	ok = 0;
end
