function PlotMMkoffCstarCI(c,pbest,ci,cellindx)
ncells = size(pbest,2);
if (length(ci) ~= ncells)
	error('The number of cells in the parameters & confidence intervals do not match');
end
%dims = CalcSubplotDims(ncells,'k_r (Hz)','r_{\rm stim} (Hz)');
%bottomrow = (dims(1)-1)*dims(2);
for i = 1:ncells
	%subplot(dims(1),dims(2),i);
	cic = ci{i};
	x(i) = 1/MMHalfMax(c,pbest(5:8,i));
	y(i) = 1/MMHalfMax(c,pbest(9:12,i));
	lx(i) = x(i) - cic(1,21);
	ly(i) = y(i) - cic(1,22);
	ux(i) = cic(2,21) - x(i);
	uy(i) = cic(2,22) - y(i);
end
errorbar(x,y,ly,uy,'o');
hold on
xerrorbar(x,y,lx,ux,'o');
for i = 1:ncells
	text(x(i),y(i),sprintf('%d',cellindx(i)));
end
figure
scatter(x,y);
for i = 1:ncells
	text(x(i),y(i),sprintf('%d',cellindx(i)));
end
