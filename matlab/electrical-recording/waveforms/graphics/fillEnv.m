function fillEnv(data,scanrate,time)
% fillEnv(data,scanrate,time)
% Plots all 64 channels on screen, for envelope data
% loaded by loadFromEnv
% time (optional) gives the time range [tmin,tmax) in seconds
% if time is absent, the whole range is plotted
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
figure('Position',scnsize)
set(gcf,'DefaultAxesPosition',[0.05,0.025,0.95,0.95])
%dmax = max(max(data(7:size(data,1),:)));
%dmin = min(min(data(7:size(data,1),:)));
dmax = 2.5;
dmin = -2.5;
%dmin = -500;
%dmax = 500;
if (nargin == 3)
	t = time(1):1/scanrate:time(2)-1/scanrate;   %half-open interval
	xrange = round(time*scanrate+1);
	xrange(2) = xrange(1) + size(t,2) - 1;
else
	t = 0:1/scanrate:(size(data,2)-1)/scanrate;
	xrange = [1,size(data,2)];
end
for i = 1:(size(data,1)/2)
	axhndl(i) = vertsubplot(16,4,i);
	fillmm2(data(2*i-1,xrange(1):xrange(2)),data(2*i,xrange(1):xrange(2)),t);
	if i > 3
		axis([t(1),t(size(t,2)),dmin,dmax])
	else
		set(gca,'XLim',[t(1),t(size(t,2))]);
	end
	title(i-1)
end
% Make axes invisible on most plots
bkgndcol = get(gcf,'Color');
set(axhndl,'XColor',bkgndcol,'YColor',bkgndcol,'Color',bkgndcol)
% Show axes on bottom row
subax = [axhndl(16),axhndl(32),axhndl(48),axhndl(64)];
set(subax,'XColor',[0 0 0],'YColor',[0 0 0],'Color',bkgndcol,'Box','off')
