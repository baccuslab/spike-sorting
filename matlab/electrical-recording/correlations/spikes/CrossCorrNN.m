function I = CrossCorrNN(spike0,spikes)
% I = CrossCorr(spike0,spikes)
% For a vector of spike times "spike0"
% and a cell array of vectors "spikes",
% compute the distribution of nearest-neighbor
% spike times between spike0 & spikes
% Assumes the vectors are sorted
indx = 1;	% The iterator for the different vectors in spikes
I = zeros(0,0);
while (indx <= length(spikes))
	i = 1;		% The iterator for spike0
	j = 1;		% The iterator in spikes{indx}
	while (i <= length(spike0))
		while (j <= length(spikes{indx}) & spikes{indx}(j) < spike0(i))
			j = j+1;
		end
		if (j > 1)
			dt = spikes{indx}(j-1:j)-spike0(i);
		else
			dt = spikes{indx}(j)-spike0(i);
		end
		[dtmin,jmin] = min(abs(dt));
		I(end+1) = dt(jmin);
		i = i+1;
	end
	indx = indx+1;
end
