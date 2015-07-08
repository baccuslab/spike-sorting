function [pstim,errstim] = KtoStim(pin,C,indx)
ncells = size(pin,2);
if (ncells ~= length(C))
	error('Number of input cells is not consistent');
end
nconc = size(indx,1);
for i = 1:ncells
	for j = 1:nconc
		ptemp = pin(indx(j,:),i);
		Ctemp = C{i}(indx(j,:),indx(j,:));
		[pstimtemp,W] = ChangeVarMMk(ptemp);
		%Winv = inv(W);
		%W
		%Winv
		errstimtemp = sqrt(diag(W'*Ctemp*W));
		pstim(indx(j,:),i) = pstimtemp;
		errstim(indx(j,:),i) = errstimtemp;
	end
end
