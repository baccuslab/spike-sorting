function ViewReconstruction(scanrange,datafname,channels,sptimes,hdr)
%scanrange: start and end of scans to be displayed
%datafname:data file name for one file
%channels:List of channels
%sptimes:List of spike times
%hdr:header containing info about snippet length and scanrate
%Display colors for 
colors={'b','g','r','c','m','y','b','g','r','c','m','y'};
if (nargin==5)
	%Set up window
	fview = figure('Position',[21   600   1100   400],'Visible','on','BackingStore','off');	% Don't show until done
	%Display color key for cells
	ncells=size(sptimes,1);
	axes('position',[max(0,0.5-(ncells+1)/30) 0  min(1,(ncells+1)/15) 0.05]);
	text (0,0.5,'Cell no.:','FontWeight','Bold','FontSize',12);
	for c=1:ncells
		line ([c/(ncells+1) c+0.5/(ncells+1)],[0.5 0.5],'Color',colors{c},'LineWidth',15);
		text ((c+0.35)/(ncells+1),0.35,num2str(c),'FontWeight','Bold','FontSize',12);
	end
	xlim ([0 1]);
	ylim([0 1]);
	set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],...
	'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8],'Color',[0.8 0.8 0.8]);%End of color key
	axes;
	tstart=min(1,floor(10*scanrange(1)/hdr.scanrate)/10);
	tend=floor(10*scanrange(2)/hdr.scanrate)/10;
	h1 = uicontrol('Parent',gcf, ...
	'Units','points', ...
	'HorizontalAlignment','left', ...
	'Position',[10 112 39 20], ...
	'String','tstart', ...
	'Style','text', ...
	'Tag','StaticText4');
	h1 = uicontrol('Parent',gcf, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'Position',[0 100 50 20], ...
	'String',num2str(tstart), ...
	'Style','edit', ...
	'Tag','tstart');
	h1 = uicontrol('Parent',gcf, ...
	'Units','points', ...
	'HorizontalAlignment','left', ...
	'Position',[13 62 39 20], ...
	'String','tend', ...
	'Style','text', ...
	'Tag','StaticText4');
	h1 = uicontrol('Parent',gcf, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'Position',[0 50 50 20], ...
	'String',num2str(tend), ...
	'Style','edit', ...
	'Tag','tend');
	%Display button calls this routine again, with no parameters
	h1 = uicontrol('Parent',gcf, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'Position',[0 20 50 20], ...
	'String','Display', ...
	'Callback','ViewReconstruction',...
	'Tag','Showbutton');
	%Parameters for subsequent calls are stored in figure
	setappdata (gcf,'datafname',datafname);
	setappdata (gcf,'channels',channels);
	setappdata (gcf,'sptimes',sptimes);
	setappdata (gcf,'hdr',hdr);
end
if  (nargin == 0)
	%Called with no parameters
	fview=gcf;
	%Retrieve parameters from figure
	datafname=getappdata (gcf,'datafname');
	channels=getappdata (gcf,'channels');
	sptimes=getappdata (gcf,'sptimes');
	hdr=getappdata (gcf,'hdr');
	scanrange = [str2num(get(findobj(gcf,'Tag','tstart'),'String')) str2num(get(findobj(gcf,'Tag','tend'),'String'))]*hdr.scanrate;
	%Check bounds for range of scans
	if (scanrange(1)<1)
		scanrange(1)=1;
		set(findobj(gcf,'Tag','tstart'),'String','0')
	end
	if (scanrange(2)<1)
		scanrange(2)=0.1*hdr.scanrate;
		set(findobj(gcf,'Tag','tend'),'String','0.1')
	end
end


%Load in full recording
% data=loadaibdata(datafname,channels,{scanrange(1)},[0 scanrange(2)-scanrange(1)]);
data = loadRawData(datafname, channels, {scanrange(1)}, ...
    [0, scanrange(2) - scanrange(1)]);
offset(1)=0;
for ch=2:size(channels,2)
	data{ch}=data{ch}-max(data{ch})+min(data{ch-1});
end
for ch=1:size(channels,2)
	plot (data{ch},'k'); hold on
end
axis tight
ncells=size(sptimes,1);
seltimesidx=cell(ncells,1);
timespnts=cell(ncells,1);
%Get and display points during spikes
for c=1:size(sptimes,1)%Loop over cells
	seltimes{c}=sptimes{c}(find(and(sptimes{c}>=scanrange(1),sptimes{c}<=scanrange(2))))';
	clear timessel
	if (size(seltimes{c},2)>0)
		timessel(hdr.sniprange(2)-hdr.sniprange(1)+1,size(seltimes{c},2))=0;
		for t=hdr.sniprange(1):hdr.sniprange(2)
			timessel(t-hdr.sniprange(1)+1,:)=seltimes{c}+t-scanrange(1);
		end
		for ch=1:size(channels,2)%Show spikes for each channel
			spsel=data{ch}(timessel);
			plot(timessel,spsel,colors{c},'LineWidth',2);
		end
	end
end
set(gca,'YTickLabel',{'0','1'},'ytick',[0 1]);
hold off
ylabel('Voltage (V)');
xlabel('Time (scan #)');
if (nargin==0)
	slidewin=getappdata (fview,'slidewin');
	delete(slidewin);
end
slidewin=SliderWindow(gca,[21 60 1100 180]); %Show sliderwindow to zoom into data
set(fview,'Visible','on');
setappdata (fview,'slidewin',slidewin);
