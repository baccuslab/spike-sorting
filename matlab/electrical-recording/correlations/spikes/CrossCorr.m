% CrossCorr: compute cross-correlations for spike-train data
% [tcc,indx] = CrossCorr(t1,t2,tmax):
%   "t1" & "t2" are the times of the spikes
%   "tmax" is the maximum absolute time difference to consider
%   "tcc" contains all time differences less (in abs value) than tmax,
%   "indx" contains the indices that contribute to the samples in tcc
%			(a 2-by-n matrix)
%
% nPerBin = CrossCorr(t1,t2,tmax,nbins)
%	Bins the time differences into nbins. The number per bin is returned.
% This is written in C for speed.
