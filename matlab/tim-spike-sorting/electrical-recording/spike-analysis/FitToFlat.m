function chisq = FitToFlat(n,mn,sigma)
nstim = length(n);
ncells = size(mn,2);
chisq = zeros(nstim,ncells);
for i = 1:ncells
	for j = 1:nstim
		err = sigma{j,i}./sqrt(n{j});
		nzindx = find(abs(err)>100*eps);
		scdmn = mn{j,i}(nzindx)./err(nzindx);
		if (~isempty(scdmn))
			chisq(j,i) = sum(scdmn.^2);
		end
	end
end
