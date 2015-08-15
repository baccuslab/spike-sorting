function PlotMMkoffRStim(c,pbest,C,cellnum)
ncells = size(pbest,2);
if (length(C) ~= ncells)
	error('The number of cells in the parameters & covariances do not match');
end
gindx = [];
for i = 1:ncells
	if (C{i} ~= -1)
		gindx(end+1) = i;
	end
end
ncells = length(gindx);
dims = CalcSubplotDims(ncells);
bottomrow = (dims(1)-1)*dims(2);
for i = 1:ncells
	perr = sqrt(diag(C{gindx(i)}));
	subplot(dims(1),dims(2),i);
	errorbar([c',c'],[pbest(5:8,gindx(i)),pbest(9:12,gindx(i))],[perr(5:8),perr(9:12)]);
	if (i <= bottomrow)
		set(gca,'XTick',[]);
	end
	title(sprintf('%d',cellnum(gindx(i))));
end
