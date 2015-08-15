function PlotMeanRateChange(ton,n,mn,sigma,stimlabels,celllabels)
nstim = length(ton);
ncells = size(mn,2);
if (nargin < 6)
	celllabels = 1:ncells;
end
nsp = min([5,ceil(sqrt(ncells+1))]);
ncells = min([ncells,nsp*nsp-1]);	% This is the number we'll plot
ncells = max([2 ncells]);			% Make sure there's room for stim. legend
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
		plot(ton{j},mn{j,i},'Color',co(colindx,:));
		err = sigma{j,i}./sqrt(n{j});
		h = errorbar(ton{j},mn{j,i},err);
		set(h,'Color',co(colindx,:));
	end
	plot([0 maxton],[0 0],'k-');
	set(gca,'XLim',[0 maxton]);
	title(num2str(celllabels(i)));
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
