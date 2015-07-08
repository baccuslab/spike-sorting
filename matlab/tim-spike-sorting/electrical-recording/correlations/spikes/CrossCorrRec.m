function [tccout,indxout] = CrossCorrRec(t1,t2,tmax,nbins)
% CrossCorrRec: compute spike crosscorrelations for vectors in a cell array
% [tccout,indxout] = CrossCorrRec(t1,t2,tmax,nbins)
% Calling syntax is just like CrossCorr, except t1 & t2 may be cell arrays
%   of spike time vectors
binning = 0;
if (nargin == 4)
	binning = 1;
end
if (nargout > 1 & binning)
	error('Only one output when binning');
end
if (~iscell(t1))			% Allow vector inputs for generality
	t1 = {t1};
end
if (~iscell(t2))
	t2 = {t2};
end
if (length(t1) ~= length(t2))
	error('t1 and t2 must have the same number of records');
end
if (binning)
	tccout = zeros(1,nbins);
	for i = 1:length(t1)
		if (and(size(t1{i},2)>0,size(t2{i},2)>0));
			tccout = tccout+CrossCorr(t1{i},t2{i},tmax,nbins);%-CrossCorr(mod(t1{i}+max(t1{i}/2),max(t1{i}/2)),t2{i},tmax,nbins);%		
		end
	end
else
	tccout = [];
	for i = 1:length(t1)
		[tcctemp,indxout{i}] = CrossCorr(t1{i},t2{i},tmax);
		tccout(end+1:end+length(tcctemp)) = tcctemp;
	end
end
