function plotvert(data,scanrate,time)
% plotvert(data,scanrate,time)
% Plots all channels in data on screen
% time (optional) gives the time range [tmin,tmax) in seconds
% if time is absent, the whole range is plotted
%set(gcf,'Position',[256,334,400,300]);
scnsize = get(0,'ScreenSize');
figure('Position',scnsize)
if (nargin == 3)
	t = time(1):1/scanrate:time(2)-1/scanrate;   %half-open interval
	xrange = round(time*scanrate+1);
	xrange(2) = xrange(1) + size(t,2) - 1;
else
	t = 0:1/scanrate:(size(data,2)-1)/scanrate;
	xrange = [1,size(data,2)];
end
for i = 1:size(data,1)
	axhndl(i) = subplot(size(data,1),1,i);
	plot(t,data(i,xrange(1):xrange(2)));
	%axis([t(1),t(size(t,2)),-250,250]);
end
% Make parts of axes invisible
bkgndcol = get(gcf,'Color');
axcol = get(axhndl(1),'XColor');
set(axhndl,'XColor',bkgndcol,'Box','off')
%set(axhndl,'Box','off')
% Show bottom axis on bottom row
botax = axhndl(size(data,1));
set(botax,'XColor',axcol)
xlabel('Time (s)')
ax0 = axes;	% Full-figure axis
set(ax0,'Visible','off')
pos0 = get(ax0,'position');
set(ax0,'position',[pos0(1)-0.02,pos0(2),pos0(3),pos0(4)]);
yl = ylabel('Voltage (\muV)');
set(yl,'Visible','on')
