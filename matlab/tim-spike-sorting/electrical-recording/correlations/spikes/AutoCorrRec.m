function [tacout,indxout] = AutoCorrRec(t,tmax,nbins)
% AutoCorrRec: compute spike autocorrelations for vectors in a cell array
% Calling syntax is just like AutoCorr, except t may be a cell array
% of spike time vectors
binning = 0;
if (nargin == 3)
	binning = 1;
end
if (nargout > 1 & binning)
	error('Only one output when binning');
end
if (~iscell(t))			% Allow vector inputs for generality
	if (binning)
		tacout = AutoCorr(t,tmax,nbins);
	else
		[tacout,indxout] = AutoCorr(t,tmax);
	end
	return
end
if (binning)
	tacout = zeros(1,nbins);
	numspikes=0;
	for i = 1:length(t)
		tacout = tacout + AutoCorr(t{i},tmax,nbins);
		numspikes=numspikes+size(t{i},2);
	end
	tacout=tacout/numspikes/(tmax/nbins);
else
	tacout = [];
	for i = 1:length(t)
		[tactemp,indxout{i}] = AutoCorr(t{i},tmax);
		tacout(end+1:end+length(tactemp)) = tactemp;
	end
end
