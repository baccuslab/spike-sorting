function [axh,npix] = CreateAxes64
% axh = CreateAxes64
% Sets up the axes for 64-channel acquisition & plotting
% axh is the vector of handles to the axes
% npix is the length of the x axis in pixels
set(0,'Units','pixels')
% A trick for producing correct-sized screen:
%scrnsize = get(0,'ScreenSize');
%figure('Position',scrnsize);	% Will actually produce a somewhat smaller fig
%scrnsize = get(gcf,'Position');
%scrnsize(4) = round(0.95*scrnsize(4));
%set(gcf,'Position',scrnsize)
scrnsize = [12    26   989   663];
figure('Position',scrnsize,...
	'Name','Recording Window', ...
	'NumberTitle','off', ...
	'HandleVisibility','callback',...
	'Tag','RecWindow');
set(gcf,'DefaultAxesPosition',[0.05,0.01,0.93,0.90])
for i = 1:64
	axh(i) = vertsubplot(16,4,i);
	tmpu = get(gca,'Units');
	set(gca,'Units','pixels');
	axpos = get(gca,'Position');
	npix(i) = axpos(3);
	set(gca,'Units',tmpu);
	set(gca,'UserData',npix(i));	% Store where I can get it

	set(gca,'Visible','off');
	ylabel(sprintf('%s %2d',num2name(i-1),i-1),'Visible','on','Rotation',0)
	set(gca,'YTick',[0],'YTickLabel','  ')
end
