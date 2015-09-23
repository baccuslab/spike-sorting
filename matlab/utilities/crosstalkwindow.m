function cthandle = crosstalkwindow(hsort,g)
%function cthandle = crosstalkwindow(hsort,g)
%
% Function to display crosstalk window for sorting or removing crosstalk.
%
%snipsize=[-6 20]; %do we want [-10 25] for high dens array?
numch=size(g.channels,1);
%open figure
figure ('Name','Crosstalk','Position', [300 50 750 750]);%,'doublebuffer','on');
%Create axis for each channel
for chan= 0:63
    if strcmp(g.array, 'hidens')
        pos = GetPosition(chan, g.array, numch, g.x_coordinates, g.y_coordinates);
    else
        pos = GetPosition(chan, g.array, numch);
    end
 	axes('position',[pos 0.11 0.11]);
 	set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8]);
end
%for chindx=1:numch
%    subplot(ceil(sqrt(numch)), ceil(sqrt(numch)), chindx);
%    title(sprintf('Ch %d', g.channels(chindx)));
% 	axes('position',[pos 0.11 0.11]);
%	hcc(chindx)=gca;	
%end
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[30 40 100 29], ...
'String','Show all', ...
'Callback','crosstalkfunctions showall',...
'Tag','');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[30 5 100 29], ...
'String','Show mean', ...
'Callback','crosstalkfunctions showmean',...
'Tag','');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[650 40 122 29], ...
'String','Sort crosstalk', ...
'Callback','crosstalkfunctions sortcrosstalk',...
'Tag','');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[650 5 122 29], ...
'String','Mark for removal', ...
'Callback','crosstalkfunctions remove',...
'Tag','');

%Handles for figure and all axes
handles=getappdata (hsort,'handles');
handles.cc=hcc;
handles.sort=hsort;
setappdata (gcf,'g',g);
setappdata (gcf,'handles',handles);
cthandle=gcf;



