function hax = PlotValvePSTH(stim,spike,binwidth)
% PlotValvePSTH: stimulus timing and PSTH plot
% hax = PlotValvePSTH(stim,spike,binwidth)
% This splits the current axis into two, one for
%	the stimulus and one for the PSTH
% 	stim & spike are of the format CollectResponses/UnifyResponses
%	binwidth is measured in seconds
% The returned handles are for the 2 new axes
stim1 = stim{1};
xlim = [0 stim1(2,end)-stim1(2,1)];
[r,t,err] = PSTH(stim,spike,binwidth);
pos = get(gca,'Position');
h1 = 0.83*pos(4);
b2 = h1+pos(2)+0.01*pos(4);
h2 = 0.147*pos(4);
delete(gca);
haxout = axes('position',[pos(1:3) h1]);
%plot(t,r,'b');
errorbar(t,r,err,'b');
ylim = get(gca,'YLim');
set(gca,'Box','off','FontSize',14,'YLim',[0 ylim(2)],'XLim',xlim);
%ylabel('Firing rate (Hz)','FontSize',14);
%xlabel('Time (s)','FontSize',14);
haxout = [haxout,axes('position',[pos(1) b2 pos(3) h2])];
stim1 = stim{1};
stairs(stim1(2,:)-stim1(2,1),stim1(1,:),'r');
set(gca,'XTick',[],'YTick',[],'Box','off','XLim',xlim);
if (nargout > 0)
	hax = haxout;
end
