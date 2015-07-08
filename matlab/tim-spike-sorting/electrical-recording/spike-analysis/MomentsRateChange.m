function [tonout,n,mn,sigma] = MomentsRateChange(stim,spike,vlvnum,trange)
% MomentsRateChange: Calculate the mean & std dev. of the firing rate change
% [tonout,n,mn,sigma] = MomentsRateChange(stim,spike,vlvnum,trange)
% Inputs:
%	stim{vlvindx}{rptnum} is the 2-by-n stimulus snippet
%	spike{vlvindx,cellnum}{rptnum} is the corresponding vector of spike times
%	vlvnum is the vector of valve numbers (indexed by vlvindx)
%	trange is the 2-vector of times (relative to valve opening = 0)
%		of bin boundaries. First must be negative, the second positive.
% Outputs:
%	tonout: a vector containing the list of unique valve open times
%	n(vlvnum,cellnum,tonindx): the number of presentations for given valve,
%		cell, and on time
%	mn and sigma: have the same index pattern as n. Are the mean and
%		standard deviation, respectively.
%
% See RateChange and PlotMeanRateChange
if (trange(1) > 0 | trange(2) < 0)
	error('Times must be specified on either side of 0');
end
nvalves = length(stim);
ncells = size(spike,2);
% Compute rate differential
[spikebin,ton] = BinSpikes(stim,spike,vlvnum,[trange(1) 0 trange(2)]);
spikediff = cell(nvalves,ncells);
for i = 1:nvalves
	for j = 1:ncells
		spikediff{i,j} = spikebin(:,3)/trange(2) + spikebin(:,2)/trange(1);
	end
end
% Lump equivalent on-times together
res = 100;		% Round all times to nearest 0.01s
tonall = round(res*cat(2,ton{:}))/res;
tonout = unique(tonall);
nton = length(tonout);
% Now compute moments
n = zeros(nvalves,ncells,nton);
mn = n;
sigma = n;
for i = 1:nvalves
	% Determine which valve opening times go together
	t = round(res*ton{i})/res;	% round to nearest 1/res seconds
	for k = 1:nton
		indx = find(t == tonout(k));
		n(i,:,k) = length(indx);
		if (length(indx) == 0)
			mn(i,:,k) = NaN;
			sigma(i,:,k) = NaN;
		else
			for j = 1:ncells
				sd = spikediff{i,j}(indx);
				mn(i,j,k) = mean(sd);
				sigma(i,j,k) = std(sd);
			end
		end
	end
end
