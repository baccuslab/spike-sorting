function handles = makearraywindow(channels, array_type, x_coordinates, y_coordinates);
%function handles = makearraywindow(channels, array_type, x_coordinates, y_coordinates);
% Creates the initial window with each channel and its default
% 2D projections
%
% Modified 2015-09-22 by Lane McIntosh
%   - added array_type argument and changed loop to call
%   getPosition
%
if nargin < 3
    x_coordinates = [];
    y_coordinates = [];
end


numch=length(channels);
%SETUP ARRAY CHANNEL PLOT
figure('Name','Array','Position', [150 50 1050 750],'NumberTitle','off');%,'doublebuffer','on');
set(gcf,'CloseRequestFcn','')
%Plot each recorded channel

for chindx=1:numch
    if strcmp(array_type, 'hidens')
        pos = GetPosition(chindx, array_type, numch, x_coordinates, y_coordinates);
        axes('position',[pos 1/15 1/20]);
    else
        pos = GetPosition(chindx, array_type, numch);
        axes('position',[pos 1/11 0.125]);
    end
    %set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],...
    %'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8]);
    %hax=gca;

    %subplot(ceil(sqrt(numch)), ceil(sqrt(numch)), chindx);
    %title(sprintf('Ch %d', channels(chindx)));
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


