function [stim,spike] = CollectResponses(rec,trange,cellnum)
% CollectResponses: organize responses by stimulus
% [stim,spike] = CollectResponses(rec,trange,cellnum)
% trange is the time (in secs) before and after the valve opening
% 	that should be collected
% cellnum is an optional vector of cell numbers; if absent, all
% 	cells are processed
% rec is a cell array of records, or a single record
%
% The outputs:
% stim{recindx,vlvnum}{rptnum} is a 2-by-n matrix containing a
%	"stimulus snippet", the valve numbers and transition times
%	(or at least beg/end time of range).
% spike{recindx,vlvnum,cellindx}{rptnum} contains the corresponding spike times.
%
% All times are measured in seconds.
if (~iscell(rec))
	rec = {rec};
end
nrec = length(rec);
for i = 1:nrec
	ncells(i) = length(rec{i}.T);
end
if (~isempty(find(ncells-ncells(1))))
	error('Must have the same cells in all records');
end
ncells = ncells(1);
if (nargin < 3)
	cellnum = 1:ncells;
else
	if (~isempty(find(cellnum > ncells)))
		error('Not all chosen cells were recorded');
	end
end
nvalves = 12;
stim = cell(nrec,nvalves);
spike = cell(nrec,nvalves,ncells);
toSecs = 50e-6;
for j = 1:nrec
	evT = rec{j}.evT*toSecs;
	for i = 1:nvalves
		vindx = find(rec{j}.evP == i);
		nrpt = length(vindx);
		stim{j,i} = cell(1,nrpt);
		for k = 1:nrpt
			ttransition = evT(vindx(k));
			currange = ttransition + trange;
			% First cut out a snippet of the stimulus
			tindx = find(evT >= currange(1) & evT <= currange(2));
			previndx = max([tindx(1)-1,1]); postindx = min([tindx(end)+1,length(evT)]);
			temp = [rec{j}.evP(previndx:postindx); evT(previndx:postindx)];
			temp(2,1) = currange(1);
			temp(2,end) = currange(2);
			temp(1,end) = temp(1,end-1);
			stim{j,i}{k} = temp;
			% Now collect the spikes for all the cells
			for kk = 1:ncells
				T = rec{j}.T{cellnum(kk)}*toSecs;
				tindx = find(T >= currange(1) & T <= currange(2));
				spike{j,i,kk}{k} = T(tindx);
			end
		end
		if (nrpt == 0)	% If valve was not turned on
			stim{j,i} = {[0 0;trange]};
			for kk = 1:ncells
				spike{j,i,kk} = {[]};
			end
		end
	end
end
