function [tsplit,mn,err,sk] = SplitGauss(spikes,tol,minnpb,verbose)
% SplitGauss: draw bin boundaries so that the distribution of the mean is gaussian
% [tsplit,mn,err,sk] = SplitGauss(spikes,tol,minnpb,verbose)
% Inputs:
%	spikes: a cell array of repeats, where each entry contains the vector of spike times
%	tol: skewness tolerance. Default value 0.3.
%	minnpb: minimum total number of spikes/bin. Default value 10.
%	verbose: set to 1 if you want to see how many bins got consolidated.
% Outputs:
%	tsplit: the bin boundaries
%	mn: the mean number of spikes for each bin
%	err: the standard error in the mean for each bin
%	sk: the skewness of each bin
% One known bug: if many of the spike times are identical, this can run into
%	trouble. Haven't gotten around to fixing this yet.
if (~iscell(spikes))
	error('Input "spikes" must be a cell array');
end
if (nargin < 4)
	verbose = 0;
end
if (nargin < 3 | isempty(minnpb))
	minnpb = 10;
end
if (nargin < 2 | isempty(tol))
	tol  = 0.3;
end
nrpts = length(spikes);
allspikes = sort(cat(2,spikes{:}));
nspikestot = length(allspikes);
% tol = tol^2;	% Did I do this for some reason??
% As a start, set bins so that there are 10 spikes/bin
nbins = round(nspikestot/10)+1;
tsplit = SplitEvenly(allspikes,nbins);
bflag = [0,TestGauss(spikes,tsplit,tol),0];	% sentinels make life easier later
if (verbose)
	fprintf('%d out of %d starting bins were non-gaussian\n',length(find(bflag)),nbins);
end
while (~isempty(find(bflag)) & length(bflag) > 3)
	tsplitpad = [allspikes(1)-1,tsplit,allspikes(end)+1]; % more sentinels
	% First find the clusters
	cbound = [];
	cbound(1,:) = find(diff(bflag) == 1);		% 0->1 transitions
	cbound(2,:) = find(diff(bflag) == -1);	% 1->0 transitions
	nclust = size(cbound,2);
	cbound(:,end+1) = [1;1]*length(bflag);	% more sentinels
	% Now loop over the clusters and parcel out the values
	% of tsplit into lumps corresponding to the clusters or the
	% spaces between the clusters
	regions = {};
	regbad = [];
	if (cbound(1,1) > 1)
		regions{end+1} = tsplitpad(1:cbound(1,1)-1);
		regbad(end+1) = 0;
	end
	for i = 1:nclust
		regions{end+1} = tsplitpad(cbound(1,i):cbound(2,i));
		regbad(end+1) = 1;
		if (cbound(1,i+1)-cbound(2,i) > 1)	% If there's a gap of good bins...
			regions{end+1} = tsplitpad(cbound(2,i)+1:cbound(1,i+1)-1);
			regbad(end+1) = 0;
		end
	end
	% Now process the bad clusters
	badc = find(regbad);
	nbad = length(badc);
	for i = nbad:-1:1
		bindx = badc(i);
		reg = regions{bindx};
		nbins = length(reg)-1;
		if (nbins > 1)	% Split into nbins-1 bins
			sindx = find(allspikes > reg(1) & allspikes < reg(end));
			regions{bindx} = [reg(1),SplitEvenly(allspikes(sindx),nbins-1),reg(end)];
		else			% Split in half, and merge
			if (bindx == length(regbad) | bindx == 1)	% exception: kill the split at ends
				regions(bindx) = [];
			else
				sindx = find(allspikes > reg(1) & allspikes < reg(end));
				regions{bindx} = SplitEvenly(allspikes(sindx),2);
			end
		end
	end
	% Now catenate everything again into a list of splitting times		
	tsplit = cat(2,regions{:});
	tsplit = setdiff(tsplit,[allspikes(1)-1,allspikes(end)+1]); % eliminate remaining sentinels	
	% Try again
	bflag = [0,TestGauss(spikes,tsplit,tol),0];
	%fprintf('%d bad bins out of %d remain...\n',length(find(bflag)),length(tsplit)+1);
end
nbins = length(tsplit)+1;
if (~(length(bflag) > 3) & bflag(2) & verbose)
	warning('Couldn''t bin and get gaussian errors');
elseif (verbose)
	fprintf('Reduced to %d bins with gaussian errors\n',nbins);
end
% Now we have the bins, let's calculate the mean and std. err
npb = zeros(nrpts,nbins);
for i = 1:nrpts
	npb(i,:) = HistSplit(spikes{i},tsplit);
end
mn = mean(npb);
err = std(npb)/sqrt(nrpts);
sk = SkewMean(npb);
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
