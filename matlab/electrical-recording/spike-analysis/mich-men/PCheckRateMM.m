function [ok,badindx] = PCheckRateMM(p)
ok = 1;
% kf must be positive
badindx = find(p(5,:) < 0);
% Keep kp positive
badindx = [badindx,find(p(3,:) >= p(4,:))];
% Keep tdelay in range [0,2]
badindx = [badindx,find(p(1,:) > 2),find(p(1,:) < 0)];
badindx = sort(badindx);
if (~isempty(badindx))
	ok = 0;
end
