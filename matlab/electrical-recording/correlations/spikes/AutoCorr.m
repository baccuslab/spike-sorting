% AutoCorr: compute auto-correlations for spike-train data
% [tac,indx] = AutoCorr(t,tmax):
%   "t" is the time of the spikes
%   "tmax" is the maximum absolute time difference to consider
%   "tac" contains all time differences less (in abs value) than tmax,
%   "indx" contains the indices that contribute to the samples in tac.
%
% nPerBin = AutoCorr(t,tmax,nbins)
%	Bins the time differences into nbins. The number per bin is returned.
% This is written in C for speed.
