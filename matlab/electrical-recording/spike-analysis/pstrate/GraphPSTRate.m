function GraphPSTRate(texp,rexp,tth,rth)
nexp = length(texp);
%figure
%hold on
co = get(gca,'ColorOrder');
ncol = size(co,1);
% Do this in two separate loops so that creating a legend
% works well
for i = 1:nexp
	cindx = mod(i-1,ncol)+1;
	line(texp{i},rexp{i},'Color',co(cindx,:),'LineStyle','-','LineWidth',1);
end
for i = 1:nexp
	cindx = mod(i-1,ncol)+1;
	line(tth{i},rth{i},'Color',co(cindx,:),'LineStyle','--','LineWidth',1);
end
%set(gca,'XLimMode','manual');
set(gca,'XLim',[-5 10],'Box','off','FontSize',14);
%xlabel('Time (s)')
%ylabel('Firing rate (Hz)');
