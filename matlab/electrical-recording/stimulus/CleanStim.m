function stimout = CleanStim(stimin,dtmin)
% CleanStim: eliminate artifacts on the stimulus channel
% stimout = CleanStim(stimin)
% Assumes that valves always go off between on times
% stim is a 2-by-N matrix, where stim(1,:) are the value #s
% and stim(2,:) are the switching times
if (nargin < 2)
	dtmin = 10;
end
% First find cases where the valve number changes
% without going back to zero
indxnz = find(stimin(1,:)>0);	% Get all nonzero entries
if (length(indxnz) == 0 | length(indxnz) == length(stimin(1,:)))
	stimout = stimin;
	return;
end
indxcheck = find(diff(indxnz) == 1);	 % Nonzero for at least 2 in a row
indxcheck = unique([indxnz(indxcheck),indxnz(indxcheck)+1]);
dt = diff(stimin(2,:));
%[stimin(1,indxcheck);indxcheck;dt(indxcheck)]	% Printout line
badii = find(dt(indxcheck) < dtmin);
good = setdiff(1:size(stimin,2),indxcheck(badii));
stimout = stimin(:,good);
% Occasionally you get 2 repeated zero entries at this stage
% (when we eliminated some fluctuation away from 0 in prev. step), so
% get rid of those now
indxz = find(stimout(1,:) == 0);
iikill = find(diff(indxz) == 1);
badi = indxz(iikill)+1;
%badi
good = setdiff(1:size(stimout,2),badi(1:end-1));	% Don't get rid of terminal 0
stimout = stimout(:,good);
% Now just get rid of any really short
