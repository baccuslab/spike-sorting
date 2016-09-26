function newrecs = SplitRecordCell(oldrec,cellnum,first)
% newrecs = SplitRecordCell(oldrec,first)
% Take a repeating record and split it into sub-records.
% The beginning is identified by a valve 0 -> first transisition.
% If first is omitted, it defaults to first = 1
if (nargin < 2)
	first = 1;
end
v = oldrec.evP;
% Find the 0->first transitions
istart = zeros(0,0);
for i = 1:length(v)-1
	if (v(i) == 0 & v(i+1) == first)
		istart(end+1) = i+1;
	end
end
if (length(istart) == 0)
	newrecs = {oldrec};
	return
end
% Get rid of any trailing transitions
% (those for which there are no future open valves)
while (isempty(find(v(istart(end):end) > 1)))
	istart(end) = [];
end
nnew = length(istart);
if (nnew <= 1)
	newrecs = {oldrec};
	return;
end
tstart = oldrec.evT(istart);
gap = mean(tstart(2:nnew) - oldrec.evT(istart(2:nnew)-1));
len = mean(diff(tstart));
if (oldrec.evT(end) >= tstart(end)+len)
	tstart(end+1) = tstart(end)+len;
else
	tstart(end+1) = oldrec.evT(end);
end
for i = 1:nnew
	% First, split everything up
	newrecs{i}.StartClock = 0;
	newrecs{i}.EndClock = 1;	% Should fix this
	% Split the transition intervals in half
	evindx = find(oldrec.evT >= tstart(i)-gap/2 & oldrec.evT <= tstart(i+1)-gap/2);
	newrecs{i}.evT = [tstart(i)-gap/2,oldrec.evT(evindx),tstart(i+1)-gap/2];
	newrecs{i}.evW = [0,oldrec.evW(evindx),0];
	newrecs{i}.evP = [0,oldrec.evP(evindx),0];
%	for j = 1:length(oldrec.T)
	j = cellnum;
		indxg = find(oldrec.T{j} >= newrecs{i}.evT(1));
		indxl = find(oldrec.T{j} < newrecs{i}.evT(end));
		indx = intersect(indxg,indxl);
		newrecs{i}.T{j} = oldrec.T{j}(indx);
%	end
	% Now, set start times to 0
%	for j = 1:length(newrecs{i}.T)
		newrecs{i}.T{j} = newrecs{i}.T{j} - newrecs{i}.evT(1);
%	end
	newrecs{i}.evT = newrecs{i}.evT - newrecs{i}.evT(1);
end
	
