function [chi2,dof,alpha,beta,Aout,bout] = PSTRateMrqCoef(tsplit,mn,err,keep,trange,pvar,varloc,pfix,fixloc,nparms,intratefunc)
nexp = length(mn);
dims = [nparms nexp];
p = untangle(pvar,varloc,dims)+untangle(pfix,fixloc,dims);
pv = untangle(1:length(varloc),varloc,dims);	% Get indices in slots where there is a varied parameter
nvar = length(pvar);
alpha = zeros(nvar,nvar);
beta = zeros(nvar,1);
chi2 = zeros(1,nexp);
dof = zeros(1,nexp);
AoutC = {};
boutC = {};
for i = 1:nexp
	if (keep(i))
		% First compute the expected number of spikes in each bin, and the
		% gradient with respect to the varied parameters
		tsp = [trange(1,i),tsplit{i},trange(2,i)];
		mni = mn{i};
		erri = err{i};
		nbins = length(mni);
		nth = zeros(1,nbins);
		pvindx = find(pv(:,i));
		gth = zeros(length(pvindx),nbins);
		for j = 1:nbins
			[nth(j),gtemp] = feval(intratefunc,tsp([j j+1]),p(:,i));
			gth(:,j) = gtemp(pvindx)/erri(j);
		end
		b = (mni-nth)./erri;
		A = zeros(nvar,nbins);
		A(pv(pvindx,i),:) = gth;
		AoutC{end+1} = A;
		boutC{end+1} = b;
		chi2(i) = b*b';
		beta = beta + A*b';
		alpha = alpha + A*A';
		dof(i) = nbins;
	end
end
Aout = cat(2,AoutC{:});
bout = cat(2,boutC{:});
%if (rank(alpha) < size(alpha,1))
%	keyboard
%end
return
		
