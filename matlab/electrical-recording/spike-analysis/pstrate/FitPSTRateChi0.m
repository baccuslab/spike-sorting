function [pbest,chi2,dof,Cinv] = FitPSTRateChi(tsplit,mn,err,keep,trange,pvarstart,varloc,pfix,fixloc,nparms,intratefunc,parmcheckfunc)
% FitPSTRateChi: fit spike data to a rate function
% Performs chi-squared fitting of a model to the
%	time-dependent average spike rate.
% Goodness-of-fit is reported in terms of both total chi^2 and by a breakdown
%	in individual bins.
%
% This is a complex function because it is very general: can simultaneously fit
% several different "experiments," with some parameters unique to a particular experiment
% while others are common to some/all. Some parameters may be held fixed while
% others are optimized.
%
% [pbest,chi2,dof,Cinv] = FitPSTRateChi(tsplit,mn,err,keep,trange,pvarstart,varloc,pfix,fixloc,nparms,intratefunc,parmcheckfunc)
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
%	nparms: The total number of parameters necessary to specify the model.
%		Necessary for the untangling process.
%	intratefunc: The name of the definite integral of ratefunc, and its gradient wrt parms.
%		intratefunc(trange,p) for a time range [trange(1),trange(2)]
%		and parameters p should return the definite integral over trange. It should
%		also (when asked) return the gradient of the definite integral with respected
%		to the parameters.
%	parmcheckfunc: A function to call to see whether the proposed set of parameters
%		actually makes sense (e.g., negative rate constants, etc.). This function
%		should return 1 if everything is OK, otherwise 0.
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
tol = 1e-4;
condtol = 1e-10;
svdtol = 1e-6;
itermax = 200;
iter = 0;
lambda = 1e-3;
nexp = length(tsplit);
dims = [nparms nexp];
nvar = length(pvarstart);
pbest = pvarstart;
[chi2v,dofv,alpha,beta,A,b] = PSTRateMrqCoef(tsplit,mn,err,keep,trange,pbest,varloc,pfix,fixloc,nparms,intratefunc);
chi2 = sum(chi2v);
dof = sum(dofv);
if (dof <= nvar)
	warning('Fewer bins than there are parameters!');
	chi2 = -1;		% Signal that something is wrong
	return
end
ochi2 = chi2 + 4*tol*chi2;
while (ochi2-chi2 > tol*(ochi2+chi2)/2 & iter<itermax)
	ochi2 = chi2;
	accept = 0;
	while (~accept & iter<itermax)
		rcond(alpha)
		if (rcond(alpha) < 1e-10)
			% Solve by SVD
			'SVD'
			[U,S,V] = svd(A',0);
			dS = diag(S);
			maxS = max(dS);
			goodindx = find(dS > svdtol*maxS);
			dsinv(goodindx) = 1./dS(goodindx);
			if (length(dsinv) < nvar)
				dsinv(nvar) = 0;
			end
			dp = V*diag(dsinv)*U'*b'/(1+lambda);
		else
			alphap = alpha+lambda*diag(diag(alpha));
			dp = alphap\beta;
		end
		if (feval(parmcheckfunc,untangle(pbest+dp,varloc,dims)))
			[chi2v,dofv,alphanew,betanew] = PSTRateMrqCoef(tsplit,mn,err,keep,trange,pbest+dp,varloc,pfix,fixloc,nparms,intratefunc);
			chi2 = sum(chi2v);
			dof = sum(dofv);
		else
			chi2 = ochi2 + 1;
		end
		if (chi2 < ochi2)
			accept = 1;
			pbest = pbest+dp;
			alpha = alphanew;
			beta = betanew;
			lambda = lambda/10;
		else
			lambda = lambda*10;
		end
		iter = iter+1;
	end
end
if (iter == itermax)
	warning('Failed to converge!');
	Cinv = -1;
else
	Cinv =alpha;
end
