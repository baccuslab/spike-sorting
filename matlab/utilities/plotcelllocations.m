function plotcelllocations (locs)
figure
pos=getposition (2:63);
plot(pos(:,1),pos(:,2),'k+',locs(:,1),locs(:,2),'o');
num=1:size(locs,1);
for i=1:max(num)
	text(locs(i,1)+0.01,locs(i,2),num2str(num(i)+1));
end
%patch ([0 0.9 2.6 3.5 2.6 0.9 0],[1 2 2 1 0 0 1],[0.6 0.8 0.8]);
%line ([1.75 1.75 0.7],[1,1.2 2.25],'Color',[0.9 0.9 0.9],'LineWidth',2);
%xlim ([-0.25 3.75]);
%ylim([-0.25 2.25]);
set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],...
'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],'Color',[0.8 0.8 0.8]);
