function loglike = PSTRateUntangle(pvar)
global gTRange gSpikes gNRpts gNExp gVarLoc gPFix gFixLoc gNParms gRateFunc gIntRateFunc
dims = [gNParms gNExp];
p = untangle(pvar,gVarLoc,dims)+untangle(gPFix,gFixLoc,dims);
loglike = 0;
for i = 1:gNExp
	loglike = loglike - PSTRateLL(gSpikes{i},gTRange(:,i),p(:,i),gNRpts(i),gRateFunc,gIntRateFunc);
end
