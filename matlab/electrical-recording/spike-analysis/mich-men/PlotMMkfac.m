function PlotMMkfac(c,pbest,C,cellindx)
ncells = size(pbest,2);
if (length(C) ~= ncells)
	error('The number of cells in the parameters & cov. matrices do not match');
end
[dims,hax] = CalcSubplotDims(ncells,'c','r_{stim}k_+/k_- ( Hz/rel. conc. )');
bottomrow = (dims(1)-1)*dims(2);
for i = 1:ncells
	subplot(dims(1),dims(2),i);
	Cc = C{i};
	koff = pbest(2,i);
	rprop = pbest(3,i);
	kp = pbest(4:11,i);
	pc = zeros(4,2);
	pcerr = pc;
	for j = 1:4
		Ctemp = Cc([1:3,3+j,7+j],[1:3,3+j,7+j]);
		ptemp = pbest([1:3,3+j,7+j],i);
		[pout,W] = ChangeVarMMklin(ptemp);
		Wi = inv(W);
		pc(j,1:2) = pout(4:5)';
		dCnew = diag(Wi'*Ctemp*Wi);
		pcerr(j,1:2) = sqrt(dCnew(4:5))';
	end
	errorbar([c',c'],pc,pcerr);
	goodval = find(pcerr < pc);
	maxy = max(max(pc)); miny = min(min(pc));
	if (~isempty(goodval))
		maxy = max(maxy,max(pc(goodval)+pcerr(goodval)));
		miny = min(miny,min(pc(goodval)-pcerr(goodval)));
	end
	%set(gca,'YLim',[miny maxy]);
	set(gca,'XLim',[0 max(c)]);
	%goodval
	if (i <= bottomrow)
		set(gca,'XTick',[]);
	end
	%axis tight
	title(sprintf('%d',cellindx(i)));
end
set(hax,'HandleVisibility','on');	% avoid printing bug (?)
