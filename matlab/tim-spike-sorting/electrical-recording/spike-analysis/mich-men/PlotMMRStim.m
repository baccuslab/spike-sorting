function PlotMMRStim(c,pbest,C,cellnum)
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
[dims,hax] = CalcSubplotDims(ncells,'Relative concentration','r_{stim} (Hz)');
bottomrow = (dims(1)-1)*dims(2);
for i = 1:ncells
	perr = sqrt(diag(C{gindx(i)}));
	subplot(dims(1),dims(2),i);
	errorbar([c',c'],[pbest(4:7,gindx(i)),pbest(8:11,gindx(i))],[perr(4:7),perr(8:11)]);
	if (i <= bottomrow)
		set(gca,'XTick',[]);
	end
	title(sprintf('%d',cellnum(gindx(i))));
	axis tight
	ylim = get(gca,'YLim');
	set(gca,'XLim',[0 max(c)],'YLim',[min(0,ylim(1)),max(0,ylim(2))]);
end
haxc = findobj(hax);
set(haxc,'HandleVisibility','on');
