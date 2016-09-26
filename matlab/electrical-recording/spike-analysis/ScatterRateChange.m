function ScatterRateChange(ton,spikediff,stimlabels)
nstim = length(ton);
ncells = size(spikediff,2);
nsp = min([5,ceil(sqrt(ncells))]);
ncells = min([ncells,nsp*nsp-1]);	% This is the number we'll plot
newplot
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:nstim
	maxton(i) = max(ton{i});
end
maxton = max(maxton);
for i = 1:ncells
	subplot(nsp,nsp,i);
	cla
	hold on
	for j = 1:nstim
		colindx = mod(j-1,ncol)+1;
		plot(ton{j},spikediff{j,i},'.','Color',co(colindx,:),'MarkerSize',16);
	end
	plot([0 maxton],[0 0],'k-');
end
% Write the stimulus legend
subplot(nsp,nsp,nsp*nsp);
cla
set(gca,'Visible','off');
for j = 1:nstim
	colindx = mod(j-1,ncol)+1;
	text(0,j,stimlabels{j},'Color',co(colindx,:),'Visible','on');
end
axis([0 1 0 nstim+1]);
% Label the axes
hlax = axes('Units','normalized','Position',[0.05 0.03 0.775 0.815],'Visible','off');
text(0.47,0,'Valve on time (s)','Visible','on','FontSize',14);
text(0,0.4,'Change in firing rate (Hz)','Rotation',90,'Visible','on','FontSize',14);
