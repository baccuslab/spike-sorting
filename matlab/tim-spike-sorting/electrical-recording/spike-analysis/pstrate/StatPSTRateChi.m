function [pbest,chi2,dof,C,psim] = StatPSTRateChi(spikes,trange,pvarstart,varloc,pfix,fixloc,nparms,intratefunc,gradintratefunc,skewtol,skewdiscard,nsim)
% StatPSTRateChi: fit spike data to a rate function
% Performs chi-squared fitting of a model to the
%	time-dependent average spike rate.
% Goodness-of-fit is reported in terms of both total chi^2 and by a breakdown
%	in individual bins.
% Uncertainties in parameters are estimated by bootstrap Monte Carlo;
%	the parameters are re-fit using a random resampling of repeats, over
%	many different resamplings.
%
% This is a complex function because it is very general: can simultaneously fit
% several different "experiments," with some parameters unique to a particular experiment
% while others are common to some/all. Some parameters may be held fixed while
% others are optimized.
%
% [pbest,excess,psim] = StatPSTRateChi(spikes,trange,pvarstart,pvarrange,varloc,pfix,fixloc,nparms,intratefunc,skewtol,skewdiscard,nsim)
% Inputs:
%	spikes: a cell array, where each cell corresponds to a different
%		"experiment" (i.e., different variants of the stimulus). spikes{i}
%		is a cell array containing all the repeats of the ith experiment,
%		where each element is the vector of spike times.
%	trange: a 2-by-NExp matrix, giving the time range of the recorded
%		spikes for each experiment.
%	pvarstart/varloc,pfix/fixloc: pairs of values/locations that determine
%		the pattern of unique/common parameters for fitting the experiment.
%		See the help for UNTANGLE to understand how to specify values
%		and locations. The "var" pair refer to values that should be
%		optimized (variable), while the "fix" pair refer to ones that are
%		to be held fixed (not optimized over). pvarstart should contain
%		starting guesses for the parameters-to-be-optimized.
%	pvarrange: for each parameter in pvarstart, determines the
%		range to initially vary this parameter during optimization.
%	nparms: The total number of parameters necessary to specify the model.
%		Necessary for the untangling process.
%	ratefunc: The name of the model for the rate function. ratefunc(t,p),
%		for a vector of input spike times t and parameters p,
%		should return a vector of rates at the spike times.
%	intratefunc: The name of the definite integral of ratefunc.
%		intratefunc(trange,p) for a time range [trange(1),trange(2)]
%		and parameters p should return the definite integral over trange.
%	skewtol: tolerance for skewness. Will expand bins until the skewness
%		is less than or equal to skewtol, or until the entire experiment
%		is reduced to a single bin. Defaults to 0.5
%		if you supply the empty matrix.
%	skewdiscard: threshold for using a bin in a fit. After binning to
%		a tolerance skewtol, only those bins with skewness < skewdiscard
%		will be used in computing chi^2. Main use is in handling the case
%		when the experiment gets reduced to a single bin with skew>skewtol;
%		you can control whether to keep (skewdiscard > skew) or discard
%		(skewdiscard = skewtol) that experiment. It would be dangerous to
%		set skewdiscard < skewtol, as you wouldn't know know how much of your
%		data you're actually using. skewdiscard defaults to skewtol
%		if you supply the empty matrix.
%	nsim: specify only if you want to estimate uncertainties in the
%		parameters. This is the number of bootstrap Monte Carlo
%		simulations to perform. You must request spike excesses if you
%		want to do the Monte Carlo.
%
% Outputs:
%	pbest: The optimal set of parameters, in the same format as pvarstart.
%	excess (optional): a cell array of spike excesses, where each element of the
%		cell array corresponds to one experiment. The elements are
%		n-by-4 matrices, where the first column is the bin-center times,
%		the second is the excess number of spikes in the bin, the 3rd is the actual
%		mean number of spikes in the bin, and the 4th is the standard error.
%	psim (optional, but must have excess first): The different outcomes of the
%		optimal parameters from the bootstrap Monte Carlo.
%
%	Put in error checking on the parameters!
global gTRange gVarLoc gPFix gFixLoc gNParms gRateFunc gIntRateFunc
if (~iscell(spikes))
	error('Input spikes must be a cell array');
end
gTRange = trange;
gVarLoc = varloc;
gPFix = pfix;
gFixLoc = fixloc;
gRateFunc = ratefunc;
gIntRateFunc = intratefunc;
gNParms = nparms;
if (isempty(skewtol))
	skewtol = 0.5;
end
% First task: do the binning
nexp = length(spikes);
for i = 1:nexp
	[tsplit{i},mn{i},err{i},sk{i}] = SplitGauss(spikes{i},skewtol);
end
% Now: do the fitting

pbest = FitPSTRateChi(mn,err,sk,skewdiscard,pvarstart,pvarrange);
% Next task: if requested, compute excess spiking in bins
if (nargout > 1)
	excess = PSTRateExcess(spikes,pbest,skewtol);	% This is safe because FitPSTRate computed the globals
end
% Final task: bootstrap Monte Carlo simulation for confidence limits on parameters
% Do this conservatively; consider the repeats to be the independent
% variables, and randomly choose among repeats
if (nargout > 2)
	fprintf('Beginning Monte Carlo simulation\n');
	nexp = length(spikes);
	for i = 1:nexp
		nrpts(i) = length(spikes{i});
	end
	psim = zeros(length(pbest),nsim);
	for i = 1:nsim
		spikesbs = cell(1,nexp);
		for j = 1:nexp
			indx = round(nrpts(j)*rand(1,nrpts(j))+0.5);	% Same # of repeats, but randomly chosen (with replacement)
			spikesbs{j} = spikes{j}(indx);
		end
		psim(:,i) = FitPSTRate(spikesbs,pbest,pvarrange);
	end
end
