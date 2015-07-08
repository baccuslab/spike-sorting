function excess = PSTRateExcess(spikes,pvar,skewtol)
global gTRange gNRpts gNExp gVarLoc gPFix gFixLoc gNParms gRateFunc gIntRateFunc
dims = [gNParms gNExp];
p = untangle(pvar,gVarLoc,dims)+untangle(gPFix,gFixLoc,dims);
excess = cell(1,gNExp);
% Split up into intervals with approximately Gaussian errors,
% and compute the differential Nspikes-Nexpected
% for each interval
for i = 1:gNExp
	sp = spikes{i};
	[tsplit,mn,err] = SplitGauss(sp,skewtol);
	nbins = length(mn);
	tr = gTRange(:,i);
	nrpts = gNRpts(i);
	tsplit = [tr(1),tsplit,tr(2)];
	excess{i} = zeros(nbins,4);
	excess{i}(:,1) = (tsplit(1:end-1)+tsplit(2:end))/2;	% bin centers
	for j = 1:nbins
		excess{i}(j,2) = mn(j) - feval(gIntRateFunc,tsplit([j j+1]),p(:,i));
	end
	excess{i}(:,3) = mn;
	excess{i}(:,4) = err;
end
