function psim = SimPSTRateChi(spikes,trange,popt,varloc,pfix,fixloc,nparms,intratefunc,parmcheckfunc,skewtol,nsim)
nexp = length(spikes);
for i = 1:nexp
	nrpts(i) = length(spikes{i});
end
psim = zeros(length(popt),nsim);
tsplit = cell(1,nexp); mn = tsplit; err = tsplit; sk = tsplit; 
for i = 1:nsim
	spikesbs = cell(1,nexp);
	for j = 1:nexp
		indx = round(nrpts(j)*rand(1,nrpts(j))+0.5);	% Same # of repeats, but randomly chosen (with replacement)
		%spikesbs{j} = spikes{j}(indx);
		% Wiggle the spikes a little, so they don't lie precisely on top of each other
		% This makes future histogramming a lot easier.
		for k = 1:nrpts(j)
			spikesbs{j}{k} = spikes{j}{indx(k)};
			if (~isempty(spikesbs{j}{k}))
				spikesbs{j}{k} = spikesbs{j}{k} + 0.001*rand(1,length(spikesbs{j}{k}));
			end
		end
	end
	for j = 1:nexp
		[tsplit{j},mn{j},err{j},sk{j}] = SplitGauss(spikesbs{j},skewtol);
	end
	keep = zeros(1,nexp);
	for j = 1:nexp
		if (length(sk{j}) > 1 | sk{j}(1) < skewtol), keep(j) = 1; end;
	end;
	psim(:,i) = FitPSTRateChi(tsplit,mn,err,keep,trange,popt,varloc,pfix,fixloc,nparms,intratefunc,parmcheckfunc);
end

