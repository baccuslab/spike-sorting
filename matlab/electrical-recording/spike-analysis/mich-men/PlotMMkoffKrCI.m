function [hxlabel,hylabel] = PlotMMkoffKrCI(c,pbest,ci,cellindx)
ncells = size(pbest,2);
if (length(ci) ~= ncells)
	error('The number of cells in the parameters & confidence intervals do not match');
end
dims = CalcSubplotDims(ncells,'k_r (Hz)','r_{\rm stim} (Hz)');
bottomrow = (dims(1)-1)*dims(2);
for i = 1:ncells
	subplot(dims(1),dims(2),i);
	cic = ci{i};
	koff = pbest(4,i);
	rprop = pbest(3,i);
	kr = koff./(1-pbest(5:12,i)/rprop);
	l = [kr(1:4),kr(5:8)] - [cic(1,5:8)',cic(1,9:12)'];
	u = [cic(2,5:8)',cic(2,9:12)'] - [kr(1:4),kr(5:8)];
	errorbar([c',c'],[kr(1:4),kr(5:8)],l,u);
	if (i <= bottomrow)
		set(gca,'XTick',[]);
	end
	axis tight
	title(sprintf('%d',cellindx(i)));
end
