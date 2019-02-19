function handles = makearraywindow (channels, arraytype)
numch=length(channels);
%SETUP ARRAY CHANNEL PLOT
figure ('Name','Array','Position', [150 50 1050 750],'NumberTitle','off');%,'doublebuffer','on');
% set (gcf,'CloseRequestFcn','')

% number of white boxes in array window
if strcmp(arraytype, 'hidens')
    visiblechannels = numch;
    xsize = 1/13;
    ysize = 1/14;
else
    visiblechannels = 63;
    xsize = 1/11;
    ysize = 0.125;
end

%Plot box for all channels
for chan=0:visiblechannels
	pos=GetPosition(chan, arraytype);
	axes('position',[pos xsize ysize]);
	set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],...
	'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8]);
end

%Plot each recorded channel
for chindx=1:numch
	pos=GetPosition(channels(chindx), arraytype);
	axes('position',[pos xsize ysize]);
	hax=gca;
	setappdata(hax,'mode','density');
	
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


