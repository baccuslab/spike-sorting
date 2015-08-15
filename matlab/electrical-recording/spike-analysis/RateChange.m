function [ton,spikediff] = RateChange(stim,spike,trange)
% RateChange: for each presentation, compute the rate differential
% [ton,spikediff] = RateChange(stim,spike,trange)
% See MomentsRateChange for doing statistics on these quantities
tbefore = -trange(1);
invt = 1./abs(trange);
nvalve = length(stim);
ncells = size(spike,2);
ton = cell(1,nvalve);
spikediff = cell(nvalve,ncells);
for i = 1:nvalve
	nrpts = length(stim{i});
	for j = 1:nrpts
		% First figure out how long the stimulus is on
		stimtime = stim{i}{j}(2,:);
		tstart = stimtime(1);
		indxon = find(abs(stimtime-tstart-tbefore) < eps);
		if (~isempty(indxon))
			if (length(indxon) == 1 & indxon+1 <= length(stimtime))
				ton{i}(end+1) = stimtime(indxon+1)-stimtime(indxon);
			elseif (length(indxon) > 1)
				error('Valve turned on more than once!');
			elseif (indxon+1 > length(stimtime))	% Valve never shut off within trange
				ton{i}(end+1) = trange(2);
			end
			% Now count the spikes & compute rate differential
			for k = 1:ncells
				nbefore = length(find(spike{i,k}{j}-tstart <= tbefore));
				nafter = length(spike{i,k}{j})-nbefore;
				spikediff{i,k}(end+1) = nafter*invt(2)-nbefore*invt(1);
			end
		end
	end
end
