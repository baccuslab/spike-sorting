function [spikebin,ontime] = BinSpikes(stim,spike,vlvnum,tsplit)
% BinSpikes: bins relative to valve opening time
% [spikebin,ontime] = BinSpikes(stim,spike,vlvnum,trange)
% Inputs:
%	stim{vlvindx}{rptnum} is the 2-by-n stimulus snippet
%	spike{vlvindx,cellnum}{rptnum} is the corresponding vector of spike times
%	vlvnum is the vector of valve numbers (indexed by vlvindx)
%	tsplit is the vector of times (relative to valve opening) of bin boundaries.
%		Must be sorted in increasing order
%
% Outputs:
%	spikebin{vlvindx,cellnum}(rptnum,:) is the vector of spike numbers
%		in each bin. The first bin contains all spikes occuring before
%		tsplit(1), and the last bin contains all spikes after tsplit(end).
%		Therefore, there are length(tsplit)+1 bins.
%	ontime{vlvindx}(rptnum) is the duration of valve opening
%
% See MomentsRateChange for doing statistics on these quantities
nvalve = length(stim);
if (length(vlvnum) ~= nvalve)
	error('Valve indices and number of valves do not match');
end
ncells = size(spike,2);
spikebin = cell(nvalve,ncells);
if (nargout == 2)
	ontime = cell(nvalve);
end
for i = 1:nvalve
	nrpts = length(stim{i});
	for k = 1:nrpts
		% First figure out when the valve opened
		onIndx = find(stim{i}{k}(1,:) == vlvnum(i));
		if (length(onIndx) == 0)
			error('Valve must turn on during snippet!');
		else if (length(onIndx) > 1)
			warning('Valve turned on more than once during snippet');
			onIndx = onIndx(1);
		end
		stimtime = stim{i}{j}(2,:);
		ton = stimtime(onIndx);
		stimtime = stimtime - ton;
		if (stimtime(1) > tsplit(1) | stimtime(end) < tsplit(end))
			warning('Snippet does not include entire binning range');
		end
		if (nargout == 2)
			if (length(stimtime <= onIndx))
				error('Valve opening occured at the end of the snippet');
			end
			ontime{i}(k) = stimtime(onIndx+1)-stimtime(onIndx);
			if (stim{i}{j}(1,onIndx+1) == vlvnum(i))
				warning('Valve never shut off during snippet');
			end
		end
		for j = 1:ncells
			tsp = spike{i,j}{k} - ton;
			spikebin{i,j}(k,:) = HistSplit(tsp,tsplit);
		end
	end
end
