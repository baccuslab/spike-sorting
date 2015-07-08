function snipout = SubSnip(snipin,timein,timeout)
% SubSnip: choose a subset of snippets based on their time
% snipout = SubSnip(snipin,timein,timeout)
% All times are supplied in scan #s
[comm,indxin,indxout] = intersect(timein,timeout);
if (length(comm) < length(timeout))
	warning('Not all requested times had snippets');
end
snipout = snipin(:,indxin);
