function plot64(data,scanrate,time)
% plot64(data,scanrate,time)
% Plots all 64 channels on screen
% time (optional) gives the time range [tmin,tmax) in seconds
% if time is absent, the whole range is plotted
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
figure('Position',scnsize)
set(gcf,'DefaultAxesPosition',[0.05,0.1,0.93,0.85])
dmax = max(max(data));
dmin = min(min(data));
if (nargin == 3)
	t = time(1):1/scanrate:time(2)-1/scanrate;   %half-open interval
	xrange = round(time*scanrate+1);
	xrange(2) = xrange(1) + size(t,2) - 1;
else
	t = 0:1/scanrate:(size(data,2)-1)/scanrate;
	xrange = [1,size(data,2)];
end
for i = 1:size(data,1)
	axhndl(i) = vertsubplot(16,4,i);
	plot(t,data(i,xrange(1):xrange(2)));
	if (i > 1)
		axis([t(1),t(size(t,2))+2/scanrate,dmin/1.6,dmax/1.6])
	else
		axis([t(1),t(size(t,2))+2/scanrate,min(data(i,:)),max(data(i,:))])
	end
	set(gca,'Visible','off');
	%ylabel(num2name(i-1),'Visible','on','Rotation',0)
	ylabel(i-1,'Visible','on','Rotation',0)
	set(gca,'YTick',[0],'YTickLabel','  ')
	xlabel('Time (s)')
end
% Make axes invisible on most plots
bkgndcol = get(gcf,'Color');
%set(axhndl,'XColor',bkgndcol,'YColor',bkgndcol,'Color',bkgndcol)
%set(axhndl,'Visible','off');
% Show axes on bottom row
subax = [axhndl(16),axhndl(32),axhndl(48),axhndl(64)];
set(subax,'Visible','on','XColor',[0 0 0],'YColor',[0 0 0],'YTick',[0],'YTickLabel','  ','Color',bkgndcol,'Box','off')
vertsubplot(axhndl(16));
ylabel(num2name(15),'Color',[0 0 0])
vertsubplot(axhndl(32));
ylabel(num2name(31),'Color',[0 0 0])
vertsubplot(axhndl(48));
ylabel(num2name(47),'Color',[0 0 0])
vertsubplot(axhndl(64));
ylabel(num2name(63),'Color',[0 0 0])
