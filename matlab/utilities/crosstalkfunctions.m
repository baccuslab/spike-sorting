function crosstalkfunctions (action,sptimes,h)
% crosstalkfunctions: function to calculate, show, and sort crosstalk.
%
% INPUT:
%   action      - ?
%   sptimes     - array of spike times
%   h           - ?
%
% (C) 2015 The Baccus Lab
%
% History:
% ?? - Steve Baccus
%   - wrote it
%
% 2015-08-26 - Lane McIntosh
%   - updating to use HDFIO functions instead of loadaibdata
%
if (nargin < 1)
	action='CTselect';
end
if (nargin < 3)
	h = gcbf;
end
g=getappdata (h,'g');
handles = getappdata(h,'handles');
switch(action)
case 'calculate'
	snips.size=g.sniprange;
	snips.data=cell(size(sptimes,1),size(g.allchannels,1));
	snipmax=0;snipmin=0;
	for cl=1:size(sptimes,1)
		%Get file with most spikes
		for f=1:size(sptimes,2)
			nspikes(f)=size(sptimes{cl,f},2);
		end
		lf=find(nspikes==max(nspikes));lf=lf(1);

        % new loadRawData command takes the beginning of the snip and the length
        snip_start_offset = snips.size(1);
        snip_length = abs(snips.size(2) - snips.size(1)) + 1;
        % call loadRawData(filename, channels, idx, len)
        % turn sptimes to be a vector so you can add the offset to it
        sptimes_tmp = sptimes(cl,lf);
        sptimes_vec = [sptimes_tmp{:}];
        ctfiles = g.ctfiles(lf);
        snips.data(cl,:)=loadRawData(ctfiles, g.allchannels, sptimes_vec+snip_start_offset, snip_length);
	end
	for chindx=1:size(g.channels,1)
        %snipdata = cell2mat(snips.data{chindx});
        snipmax = max(max(snips.data{chindx}(:), snipmax));
        snipmin = min(min(snips.data{chindx}(:), snipmin));
		%snipmax=max(max(max(snips.data{chindx})),snipmax);
		%snipmin=min(min(min(snips.data{chindx})),snipmin);
	end
	snips.lim=[snipmin snipmax];
	setappdata (h,'snips',snips);
	crosstalkfunctions ('showmean',sptimes,h);
case 'CTselect'
	[placeholder,chsel] = find(handles.cc == gcbo);
	selected=getappdata(handles.cc(chsel),'CTselected');
	selected=~selected;
	if (selected)
		set(handles.cc(chsel),'Color',[1 0.8 0.8])
	else
		set(handles.cc(chsel),'Color',[1 1 1])
	end
	setappdata(handles.cc(chsel),'CTselected',selected);
	selarr=zeros(1,length(g.channels));
	for ch=1:length(g.channels)
		if (getappdata(handles.cc(ch),'CTselected'))
			selarr(ch)=1;
		end
	end
	sellist=g.channels(find(selarr));
	setappdata (gcf,'sellist',sellist);
case 'showall'
	sortchannels=getappdata(handles.sort,'sortchannels');
	snips=getappdata (gcf,'snips');
	sellist=getappdata (gcf,'sellist');
	for chindx=2:size(g.channels,1)
		for cl=1:size(snips.data,1);	
			axes(handles.cc(chindx));
			if (size(snips.data{cl,chindx},2)>0)
				plot(snips.data{cl,chindx}',getcolor(cl))
				hold on
			else
				cla
			end
			set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8]);
			if (sortchannels(1)~=g.channels(chindx))
				set(gca,'ButtonDownFcn','crosstalkfunctions');
				if (isempty(sellist))
					setappdata(gca,'CTselected',0);
				elseif (isempty(find(sellist==g.channels(chindx))))
					setappdata(gca,'CTselected',0);
				else
					set(gca,'Color',[1 0.8 0.8])
					setappdata(gca,'CTselected',1);
				end
			else
				setappdata(gca,'CTselected',0);
				set(gca,'Color',[0.8 0.8 1])
			end
		end
		xlim([-2 (snips.size(2)-snips.size(1)+2)]);
		vx=xlim;
		%ylim([snips.lim(1)-1 snips.lim(2)+1]);
		vy=ylim;
		text(vx(1)+(vx(2)-vx(1))/20,vy(2)-(vy(2)-vy(1))/10,num2str(g.allchannels(chindx)));	
		hold off
	end
case 'showmean'	
	sortchannels=getappdata(handles.sort,'sortchannels');
	snips=getappdata (gcf,'snips');
	sellist=getappdata (gcf,'sellist');
	for chindx=2:size(g.channels,1)
		for cl=1:size(snips.data,1);	
			axes(handles.cc(chindx));
			if (size(snips.data{cl,chindx},2)>0)
				plot(mean(snips.data{cl,chindx}),getcolor(cl))
				hold on
			else
				cla
			end
			set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8]);
			if (sortchannels(1)~=g.channels(chindx))
				set(gca,'ButtonDownFcn','crosstalkfunctions');
				if (isempty(sellist))
					setappdata(gca,'CTselected',0);
				elseif (isempty(find(sellist==g.channels(chindx))))
					setappdata(gca,'CTselected',0);
				else
					set(gca,'Color',[1 0.8 0.8])
					setappdata(gca,'CTselected',1);
				end
			else
				setappdata(gca,'CTselected',0);
				set(gca,'Color',[0.8 0.8 1])
			end
		end
		xlim([-2 (snips.size(2)-snips.size(1)+2)]);
		vx=xlim;
		%ylim([snips.lim(1)-1 snips.lim(2)+1]);
		vy=ylim;
		text(vx(1)+(vx(2)-vx(1))/20,vy(2)-(vy(2)-vy(1))/10,num2str(g.allchannels(chindx)));		
		hold off
	end
case 'sortcrosstalk'
	sellist=getappdata(h,'sellist');
	sortchannels=getappdata(handles.sort,'sortchannels');
	sortchannels=[sortchannels(1); sellist];
	h1 = uicontrol('Parent',handles.sort, ...
	'Units','points', ...
	'Position',[400 570 300 16], ...
	'String',sprintf('Channels %s',num2str(sortchannels)), ...
	'Style','text', ...
	'Tag','ChannelNumberText');
	for ch=1:size(sortchannels,2)
		chindices(ch)=find(sortchannels(ch)==g.channels);
	end
	setappdata(handles.sort,'sortchannels',sortchannels);
	setappdata(handles.sort,'chindices',chindices);
	updatearr(1,1:7)=0;
	updatearr(2:3,1:7)=-1;
	setappdata (handles.sort,'updatearr',updatearr);
	storestatus=getappdata (handles.sort,'Storestatus');
	if (storestatus==1)
		DoMultiChanFunctions('Storeinmem',handles.sort);
	end
	DoMultiChanFunctions('DefFiltBox',handles.sort);
	DoMultiChanFunctions('UpdateDisplay',handles.sort);
	
case 'remove'
	sellist=getappdata(h,'sellist');
	setappdata (handles.sort,'ctchannels',sellist);
	hctlist=getappdata(handles.sort,'hctlist');
	if (ishandle(hctlist))
		set(hctlist,'String',sprintf(['Remove cross talk on: ' ...
            repmat(['%d '], [1 length(sellist)])], sellist));
	end
	set(findobj(handles.sort,'Tag','DoneButton'),'Enable','on');
otherwise
	error(['Do not recognize action ',action]);
end

function color=getcolor(num)
colors={'b','g','r','c','m','y','k','b','g','r','c','m','y','k'};
color=colors{num};	
