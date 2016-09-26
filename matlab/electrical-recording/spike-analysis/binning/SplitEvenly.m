function [tsplit,npb] = SplitEvenly(t,nbins)
% SplitEvenly: split data into bins with approximately
% equal numbers of data points/bin
% Assumes the data is already sorted!!!!
% [tsplit,npb] = SplitEvenly(t,nbins)
nspikes = length(t);
numperbin = nspikes/nbins;
npbf = ones(1,nbins)*numperbin;
cnpb = round(cumsum(npbf));
tsplit = (t(cnpb(1:end-1)) + t(cnpb(1:end-1)+1))/2;
npb = diff([0,cnpb]);
