function [tac,indx] = AutoCorr(t,tmax,nbins)
% AutoCorr: compute auto-correlations for spike-train data
% [tac,indx] = AutoCorr(t,tmax):
%   "t" is the time of the spikes
%   "tmax" is the maximum absolute time difference to consider
%   "tac" contains all time differences less (in abs value) than tmax,
%   "indx" contains the indices that contribute to the samples in tac.
% nPerBin = AutoCorr(t,tmax,nbins)
%	Bins the time differences into nbins. The number per bin is returned.
% The fast version is AutoCorr, written in C.
tac = [];
indx = [];
n = length(t);
for j = 1:n-1
	k = 1; 	% iterator over following spikes
	while (j+k <= n & t(j+k)-t(j) <= tmax)
		tac(end+1) = t(j+k)-t(j);
		indx(end+1) = j;
		k = k+1;
	end
end
if (nargin == 3)
	binwidth = tmax/nbins;
	xc = linspace(binwidth/2,tmax-binwidth/2,nbins);
	tac = hist(tac,xc);
end

%[tac,indx] = CrossCorr(record,cell,cell,tmax);
%Ikeep = find(tac ~= 0);
%tac = tac(Ikeep);
%indx = indx(Ikeep);
