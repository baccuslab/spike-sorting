function handles = makearraywindow (channels);
numch=size(channels,1);
%SETUP ARRAY CHANNEL PLOT
figure ('Name','Array','Position', [150 50 1050 750],'NumberTitle','off');%,'doublebuffer','on');
set (gcf,'CloseRequestFcn','')
%Plot each recorded channel
for chindx=1:numch
    subplot(ceil(sqrt(numch)), ceil(sqrt(numch)), chindx);
    title(sprintf('Ch %d', channels(chindx)));
	setappdata(gca,'mode','density');
	
	hch(chindx)=gca;
	set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8]);
end	


h1 = uicontrol('Parent',gcf, ...
	'Units','points', ...
	'Position',[900 10 65 25], ...
	'String','Quit', ...
	'Callback','deletewindow',...
	'Enable','on',...
	'Tag','Quit');


set(findobj(gcf,'Tag','cttime'),'String','0.3');
setappdata (gcf,'SortEnable','on');

%Handles for figure and all axes
handles.main=gcf;
handles.ch=hch;
setappdata (handles.main,'handles',handles);


