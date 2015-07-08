function [tsplit,mn,err] = SplitGaussEven(spikes,tol)
if (~iscell(spikes))
	error('Input "spikes" must be a cell array');
end
nrpts = length(spikes);
allspikes = sort(cat(2,spikes{:}));
nspikestot = length(allspikes);
tol = tol^2;
% As a start, set bins so that there are 10 spikes/bin
nsppb = 10;
nbins = round(nspikestot/nsppb);
tsplit = SplitEvenly(allspikes,nbins);
bflag = TestGauss(spikes,tsplit,tol);
fprintf('%d out of %d starting bins were non-gaussian\n',length(find(bflag)),nbins);
while (~isempty(find(bflag)) & length(bflag) > 1)
	nsppb = nsppb + 1;
	nbins = round(nspikestot/nsppb);
	tsplit = SplitEvenly(allspikes,nbins);
	bflag = TestGauss(spikes,tsplit,tol);
end
if (~(length(bflag) >1))
	error('Couldn''t bin and get gaussian errors');
end
nbins = length(tsplit)+1;
fprintf('Reduced to %d bins with gaussian errors\n',nbins);
% Now we have the bins, let's calculate the mean and std. err
nbins = length(tsplit)+1;
npb = zeros(nrpts,nbins);
for i = 1:nrpts
	npb(i,:) = HistSplit(spikes{i},tsplit);
end
mn = mean(npb);
err = std(npb)/sqrt(nrpts);
return;			% done!


function bflag = TestGauss(spikes,tsplit,tol)
nrpts = length(spikes);
nbins = length(tsplit)+1;
npb = zeros(nrpts,nbins);
for i = 1:nrpts
	npb(i,:) = HistSplit(spikes{i},tsplit);
end
sd = SkewMean(npb);
bflag = (sd > tol);
