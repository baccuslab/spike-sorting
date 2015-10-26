function DoMultiChanFunctions(action,h)
if (nargin == 1)
	h = gcbf;
end
pwflag=getappdata(h,'pwflag');
if (pwflag)
	global proj,times
end
switch(action)
case 'SetCAxProp'
	set(h,'KeyPressFcn','DoMultiChanFunctions KeyTrap');	 %This seems to get overwritten
	haxc = getappdata(h,'haxc');
	axcol = [0.6 0.6 0.6];
	set(haxc,'Tag','ClustAxes', ...
	'Box','off',...
	'XColor',axcol,'YColor',axcol,...
	'ButtonDownFcn','DoMultiChanFunctions SelectCell',...
	'XTickMode','manual','XTick',[],...
	'YTickMode','manual','YTick',[]);
	%See if there is anything plotted in these axes
	len = size(haxc,1)*size(haxc,2);
	for i = 1:len
		hc = get(haxc(i),'Children');
		if (length(hc) > 0)
			set(haxc(i),'HitTest','on');
			set(hc,'HitTest','off');
		else
			set(haxc(i),'HitTest','off');
		end
	end
case 'SelectCell'
	haxc = getappdata(h,'haxc');
	selection_type = get(h,'SelectionType');
	if (~strcmp(selection_type,'extend'))
		% First turn off all other selections if not shift-clicking
		hsel = findobj(haxc,'Selected','on');
		set(hsel,'Selected','off');
	end
	% Now find the companion axis to the callback axis
	[clicki,clickj] = find(haxc == gcbo);
	set(haxc(1:2,clickj),'Selected','on');	% Select them
	set(findobj(h,'Tag','BuildFiltersButton'),'Enable','on');
	set(findobj(h,'Tag','ClusterButton'),'Enable','on');
	% If there are at least 2 selected, can also build discrim filters
	hsel = findobj(haxc,'Selected','on');
	if (length(hsel)/2 > 1)
		set(findobj(h,'Tag','DiscrimFiltersButton'),'Enable','on');
	else
		set(findobj(h,'Tag','DiscrimFiltersButton'),'Enable','off');
	end
case 'Unselect'
	haxc = getappdata(h,'haxc');
	%selection_type = get(h,'SelectionType');
	%if (~strcmp(selection_type,'extend'))
	% Turn off all other selections if not shift-clicking
	hsel = findobj(haxc,'Selected','on');
	set(hsel,'Selected','off');
	%end
	set(findobj(h,'Tag','BuildFiltersButton'),'Enable','off');
	set(findobj(h,'Tag','DiscrimFiltersButton'),'Enable','off');
	set(findobj(h,'Tag','ClusterButton'),'Enable','off');
case 'BuildFilters'
	% Get the numbers from the edit boxes
	nspikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	nnoise = str2num(get(findobj(h,'Tag','NumNoise'),'String'));
	% Get the waveforms in the selected clusters
	[selclust,wvindx] = GetSelClust(h);
	hmain=getappdata(h,'hmain');
	g=getappdata(hmain,'g');
	channels = getappdata(h,'channels');
	multiindx=getappdata(h,'multiindx');
% 	noisefiles=getappdata(h,'noisefiles');
% 	[filters,subrange,sv,wave] = multiBFI(getappdata(h,'spikefiles'),noisefiles,...
%         nspikes,nnoise,channels,wvindx,multiindx);
    [filters, subrange, sv, wave] = multiBFI(g.snipfiles, g.ctfiles, ...
        nspikes, nnoise, channels, wvindx, multiindx);
	if (length(filters) == 0)
		return;
	end
	setappdata(h,'filters',filters);
	setappdata(h,'subrange',subrange);
	% Do the plotting
	axes(findobj(h,'Tag','SVAxes'));
	hlines = plot(sv(1:min([15 length(sv)])),'r.');
	set(hlines,'MarkerSize',10);
	ylabel('Singular values');
	set(gca,'Tag','SVAxes');
	axes(findobj(h,'Tag','WaveAxes'));
	plot(wave);
	ylabel('Waveforms');
	set(gca,'XLim',[1 size(wave,1)]);
	set(gca,'Tag','WaveAxes');
	axes(findobj(h,'Tag','FiltAxes'));
	plot(filters);
	ylabel('Filters');
	set(gca,'XLim',[1 size(filters,1)]);
	set(gca,'Tag','FiltAxes');
	set(findobj(h,'Tag','ClusterButton'),'Enable','on');
	set(findobj(h,'Tag','DefaultFiltersBox'),'Value',0);
case 'DiscrimFilters'
	% Get the numbers from the edit boxes
	nspikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	% Get the waveforms in the selected clusters
	selclust = GetSelClust(h);
	clflindx = getappdata(h,'clflindx');
	nfiles = size(clflindx,2);
	nsel = length(selclust);
	wvindx = cell(nsel,nfiles);
	numspm = zeros(nsel,nfiles);
	for i = 1:nfiles
		for j = 1:nsel
			numspm(j,i) = length(clflindx{selclust(j),i});
		end
	end
	if (nfiles > 1)
		numsp = sum(numspm');
	else
		numsp = numspm';
	end
	for j = 1:nsel
		frac = min(1,nspikes/numsp(j));
		for i = 1:nfiles
			wvindx{j,i} = clflindx{selclust(j),i}(1:ceil(frac*numspm(j,i)));
			%wvindx{j,i} = clflindx{selclust(j),i};
		end
	end
	channels = getappdata(h,'channels');
	multiindx=getappdata(h,'multiindx');
% 	spikefiles = getappdata(h,'spikefiles');
    snipfiles = getappdata(h, 'snipfiles');
	spikes = cell(nsel,1);
	for i = 1:nsel
% 		spikes{i} = MultiLoadIndexSnippetsMF(spikefiles,channels,wvindx(i,:),multiindx);
        spikes{i} = MultiLoadIndexSnippetsMF(snipfiles, 'spike', ...
            channels, wvindx(i, :), multiindx);
	end
	[filt,lambda] = MaxSep(spikes);
	sv = sqrt(lambda);
	filters = filt(:,1:2);
	ifilt = inv(filt);
	wave = ifilt(1:2,:)';
	setappdata(h,'filters',filters);
	subrange = [1 size(spikes{1},1)];
	setappdata(h,'subrange',subrange);
	% Do the plotting
	axes(findobj(h,'Tag','SVAxes'));
	hlines = plot(sv(1:min([15 length(sv)])),'r.');
	set(hlines,'MarkerSize',10);
	ylabel('Singular values');
	set(gca,'Tag','SVAxes');
	axes(findobj(h,'Tag','WaveAxes'));
	plot(wave);
	ylabel('Waveforms');
	set(gca,'XLim',[1 size(wave,1)]);
	set(gca,'Tag','WaveAxes');
	axes(findobj(h,'Tag','FiltAxes'));
	plot(filters);
	ylabel('Filters');
	set(gca,'XLim',[1 size(filters,1)]);
	set(gca,'Tag','FiltAxes');
	set(findobj(h,'Tag','ClusterButton'),'Enable','on');
	set(findobj(h,'Tag','DefaultFiltersBox'),'Value',0);
case 'Cluster'
	% Note:		clusters #s run from 1 to # of clusters on this channel
	%			cluster labels (what the user actually sees) are cluster#s + clustnumoffset
	% Offsetting the cluster labels allows multi-channel sorting to give unique numbers to each cell
	% Also note: everything is done by snippet index #, the times are not used
	channels = getappdata(h,'channels');
	if (get(findobj(h,'Tag','DefaultFiltersBox'),'Value') == 1)
		basefilter = getappdata(h,'DefaultFilters');	% Use default filters
		snipsize=getappdata(h,'snipsize');
		basesubrange = getappdata(h,'DefaultSubrange');
		filters=zeros(size(basefilter,1)+(length(channels)-1)*snipsize,size(basefilter,2));
		for ch=0:(length(channels)-1)
			filters((ch*snipsize+1):(ch*snipsize+size(basefilter,1)),:)=basefilter;
		end
		subrange=basesubrange;
		subrange(2)=subrange(1)+size(filters,1)-1;
	else
		filters = getappdata(h,'filters');			% Use built filters
		subrange = getappdata(h,'subrange');
	end
	% Get the blocksize from the edit box
	blocksize = str2num(get(findobj(h,'Tag','BlockSize'),'String'));
	% Get the waveforms in the selected clusters
	[selclust,wvindx] = GetSelClust(h);
	replclust = selclust(find(selclust>1));	% Don't replace the unassigned channel
	clflindx = getappdata(h,'clflindx');
	replclust(end+1) = size(clflindx,1)+1;	% After replacing, append more clusters
	nfiles = length(wvindx);
	% Offset the cluster # labels appropriately
	params = getappdata(h,'params');
	clustnumoffset = params.ClustNumOffset;
	% Group the channels
	spikefiles = getappdata(h,'spikefiles');
	multiindx=getappdata(h,'multiindx');
	multitimes=getappdata(h,'t');
	[tnew,indxnew] = GroupMultiChannel(spikefiles,channels,...
	filters,subrange,blocksize,replclust+clustnumoffset-1,wvindx,multiindx,multitimes);
	if (~isempty(tnew))	% If the user didn't hit cancel...
		% Determine the cluster #s of the newly-created clusters
		% Make replclust at least as long as # of new clusters
		% (it's OK if it's longer)
		while (size(indxnew,1) > length(replclust))
			replclust(end+1) = replclust(end)+1;
		end
		% Replace the old assignments with the new, and append
		% any new clusters
		newclflindx = clflindx;	% Not strictly necessary, but useful for debugging
		for i = 1:size(indxnew,1)
			for j = 1:nfiles
				newclflindx{replclust(i),j} = wvindx{j}(indxnew{i,j});
			end
		end
		if (length(replclust)-1 > size(indxnew,1))
			% Trash any clusters that got eliminated
			elim = replclust(size(indxnew,1)+1:end-1); % eliminate if selected more than returned
			newclflindx(elim,:) = [];
		end
		nsnips = getappdata(h,'nsnips');
		newclflindx(1,:) = RebuildUnassigned(newclflindx,nsnips,h);
		% Store the new assignments
		setappdata(h,'clflindx',newclflindx);
		DoMultiChanFunctions('Unselect',h);
		DoMultiChanFunctions('UpdateDisplay',h);
		set(findobj(h,'Tag','DoneButton'),'Enable','off');
	end			% End of (~isempty(tnew))
	DoMultiChanFunctions('SetCAxProp',h);
case 'MultiCluster'
	% Get the waveforms in the selected clusters
	[selclust,selindx] = GetSelClust(h);
	setappdata (h,'selclust',selclust)
	setappdata (h,'selindx',selindx);
	hmain=getappdata (h,'hmain');
	% Group the channels
	set(findobj(h,'Tag','DoneButton'),'Enable','off');
	mgroup (h,selindx);
	
	%STEVE TEMP PROC
case 'Sep'
	t = getappdata(h,'t');
	scanrate = getappdata(h,'scanrate');
	clflindx = getappdata(h,'clflindx');
	[selindx,wvindx] = GetSelClust(h);
	selindx
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
% 	spikefiles = getappdata(h,'spikefiles');
    snipfiles = getappdata(h, 'snipfiles');
	channels = getappdata(h,'channels');
	multiindx=getappdata(h,'multiindx');
	dispnsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	actime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	closetime=0.0025;
	%   Get the spike times, in units of seconds
	tsecs = cell(1,nfiles);
	for j = 1:nfiles
		if (~isempty(t{j}(clflindx{selindx,j})))
			tsecs{j} = t{j}(clflindx{selindx,j})/scanrate(j);
		end
	end
	tsecs
	closeindx=cell(1,nfiles);
	for i = 1:nfiles
		nclosesp=1;
		%First spike in each file is a special case
		if  (tsecs{i}(2)-tsecs{i}(1)<=closetime) 
			closeindx{i}(1)=wvindx{i}(1);
			nclosesp=2;
		end
		for j = 2:(size(tsecs{i},2)-1)
			if  (tsecs{i}(j)-tsecs{i}(j-1)<=closetime) 
				closeindx{i}(nclosesp)=wvindx{i}(j);
				nclosesp=nclosesp+1;
			else
				if  (tsecs{i}(j+1)-tsecs{i}(j)<=closetime) 
					closeindx{i}(nclosesp)=wvindx{i}(j);
					nclosesp=nclosesp+1;
				end
			end
		end
		%Last spike in each file is a special case
		if  (tsecs{i}(j+1)-tsecs{i}(j)<=closetime) 
			closeindx{i}(nclosesp)=wvindx{i}(j+1);
			nclosesp=nclosesp+1;
		end
	
	end
	% Determine the cluster #s of the newly-created clusters
	% Make replclust at least as long as # of new clusters
	% (it's OK if it's longer)
	%figure
	%spikes = MultiLoadIndexSnippetsMF(spikefiles,channels,closeindx,multiindx);
	%numsp=size(spikes,2);
	%for s=1:numsp
	%	subplot(ceil(sqrt(numsp)),ceil(sqrt(numsp)),s)
	%	plot (spikes(:,s))
	%	axis off
	%end
	% Get the numbers from the edit boxes
	closeindx
	nspikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	nnoise = str2num(get(findobj(h,'Tag','NumNoise'),'String'));
	% Get the waveforms
% 	[filters,subrange,sv,wave] = multiBFI(getappdata(h,'spikefiles'),getappdata(h,'noisefiles'),...
%         nspikes,nnoise,channels,closeindx,multiindx);
    % BN: Not sure why the old version used noisefiles
    [filters, subrange, sv, wave] = multiBFI(snipfiles, getappdata(h, 'ctfiles'), ... 
        nspikes, nnoise, channels, closeindx, multiindx);
	if (length(filters) == 0)
		return;
	end
	setappdata(h,'filters',filters);
	setappdata(h,'subrange',subrange);
	% Do the plotting
	axes(findobj(h,'Tag','SVAxes'));
	hlines = plot(sv(1:min([15 length(sv)])),'r.');
	set(hlines,'MarkerSize',10);
	ylabel('Singular values');
	set(gca,'Tag','SVAxes');
	axes(findobj(h,'Tag','WaveAxes'));
	plot(wave);
	ylabel('Waveforms');
	set(gca,'XLim',[1 size(wave,1)]);
	set(gca,'Tag','WaveAxes');
	axes(findobj(h,'Tag','FiltAxes'));
	plot(filters);
	ylabel('Filters');
	set(gca,'XLim',[1 size(filters,1)]);
	set(gca,'Tag','FiltAxes');
	set(findobj(h,'Tag','ClusterButton'),'Enable','on');
	set(findobj(h,'Tag','DefaultFiltersBox'),'Value',0);
case 'UpdateDisplay'
	tic
	% Update the display
	haxc = getappdata(h,'haxc');
	t = getappdata(h,'t');
	scanrate = getappdata(h,'scanrate');
	hctext = getappdata(h,'hctext');
	clflindx = getappdata(h,'clflindx');
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
% 	spikefiles = getappdata(h,'spikefiles');
    snipfiles = getappdata(h, 'snipfiles');
	channels = getappdata(h,'channels');
	multiindx=getappdata(h,'multiindx');
	dispnsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	actime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	% Peak histogram
	if (~pwflag)
		for i = 1:min(nclust,7)
			for f=1:length(snipfiles)
				loadindx{f} = clflindx{i,f}(1:min(500,length(clflindx{i,f})));
			end
% 			snips{i} = MultiLoadIndexSnippetsMF(spikefiles,channels(1),loadindx,multiindx);
            snips{i} = MultiLoadIndexSnippetsMF(snipfiles, 'spike', ...
                channels(1), loadindx, multiindx);
			amp{i}=max(snips{i})-min(snips{i});
		end	
	else
		for i=1:min(nclust,7)
			amp{i}=proj{channels(1)}(2,clflindx{i,1});
		end
	end
	toc
	5

	xmin = 10000;ymin=xmin;xmax = -10000;ymax=xmax;
	for i = 1:min(7,nclust)
		[n{i},x{i}] = hist(amp{i},30);
		if (min(amp{i}) < xmin)
			xmin = min(amp{i}) ;
		end
		if (max(amp{i}) > xmax)
			xmax = max(amp{i}) ;
		end
		if (min(n{i}) < ymin)
			ymin = min(n{i}) ;
		end
		if (max(n{i}) > ymax)
			ymax = max(n{i}) ;
		end
	end
	toc
	6
	for i = 1:min(7,nclust)
		axes(haxc(3,i));
		bar(x{i},n{i},'k');
		set(gca,'yScale','log');
		set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[])
		xlim([xmin xmax]);ylim([ymin ymax]);
	end
	
	if  (~pwflag)
		% Load snippet waveforms
		%snips=cell(1,min(nclust,7));
		nsubsnips=zeros(nclust);
		for i = 1:min(nclust,7)
			for f=1:length(snipfiles)
		%		if (dispnsnips==0)
		%			loadindx{f} = clflindx{i,f}(1:min(200,length(clflindx{i,f})));
		%		else
		%			loadindx{f} = clflindx{i,f}(1:min(dispnsnips,length(clflindx{i,f})));
		%		end
				nsubsnips(i)=nsubsnips(i)+length(clflindx{i,f});
			end
		%	snips{i} = MultiLoadIndexSnippetsMF(spikefiles,channels,loadindx,multiindx);
		end	
		toc
		1
		
		% Set the axis limits on all waveform displays to be equal
		ymin = 10000;
		ymax = -10000;
		for i = 1:min(7,nclust)
			if (min(min(snips{i})) < ymin)
				ymin = min(min(snips{i})) ;
			end
			if (max(max(snips{i})) > ymax)
				ymax = max(max(snips{i}));
			end
		end
		toc
		2
		
		for i = 1:min(7,nclust)
			axes(haxc(1,i));
			if (~isempty(snips{i}))
				if (dispnsnips==0)
					plot(mean(snips{i}(:,1:min(size(snips{i},2),200)),2));
				else
					plot(snips{i}(:,1:end));
				end
			
			else
				cla
			end
			len=size(snips{1},1);
			set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[],...
			'YLim',[ymin ymax],'XLim',[0 len]);
			hold on
			xline=[len/length(channels),len/length(channels)];
			for  ch=1:(length(channels)-1)
				plot(xline*ch-1, [ymin ymax],'w',xline*ch, [ymin ymax],'w',xline*ch+1, [ymin ymax],'w');
				plot(xline*ch, [ymin ymax],'k:')
			end
			hold off
		end
		toc
		3
		
	else
		%Peak-sorting (pwflag==1)
		snips=cell(1,min(nclust,7));
		xmax=-10000;
		ymin = 10000;
		ymax = -10000;
		for ch = 1:size(channels,2)
			if  ( size(proj{ch},2)>0 & (min(proj{channels(ch)}(2,:))< ymin))
				ymin = min(proj{channels(ch)}(2,:)) ;
			end
			if  (size(proj{ch},2)>0 & max(proj{channels(ch)}(2,:)) > ymax)
				ymax = max(proj{channels(ch)}(2,:));
			end
		end
		wsize=dispnsnips;
		for i = 1:min(nclust,7)
			snips{i}=[];
			axes(haxc(1,i));
			if (size(clflindx{i,1},2)>0)
				for ch=1:size(channels,2)
					snidx=find(multiindx{1}(ch,clflindx{i,1}(1:min(5000,length(clflindx{i,1}))))>0);
					snips1ch=proj{channels(ch)}(:,multiindx{1}(ch,clflindx{i,1}(snidx)));
					snips1ch(1,:)=snips1ch(1,:)+wsize*(ch-1);
					snips{i} = [snips{i} snips1ch];
				end
			end
		end
		for i = 1:min(nclust,7)
			axes(haxc(1,i));
			if (size(clflindx{i,1},2)>0)
				plot(snips{i}(1,:),snips{i}(2,:),'.');
				xlim([0 wsize*size(channels,2)]);
				len=wsize*size(channels,2);
				set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[],...
				'YLim',[ymin ymax]);
				hold on
				xline=[len/length(channels),len/length(channels)];
				for  ch=1:(length(channels)-1)
					plot(xline*ch-1, [ymin ymax],'w',xline*ch, [ymin ymax],'w',xline*ch+1, [ymin ymax],'w');
					plot(xline*ch, [ymin ymax],'k:')
				end
			else
				cla
			end
			hold off
			nsubsnips(i)=length(clflindx{i,1});
		end	
	end

	% Autocorrelation display.
	tsecs = cell(min(7,nclust),nfiles); %   Spike times, in units of seconds
	%  Calculate & plot the autocorrelation function.
	for i = 1:min(7,nclust)
		for j = 1:nfiles
			tsecs{i,j}=[];
			if (~isempty(t{j}(clflindx{i,j})))
				tsecs{i,j} = t{j}(clflindx{i,j})/scanrate(j);
			end
		end
		axes(haxc(2,i));
		if (or(and(pwflag ,length(tsecs{i,1})>0) , size(snips{i},2)>0)) 
			set(gca,'Units','pixels');							
			pos = get(gca,'Position');
			npix = pos(2);
			nbins = ceil(npix/2);
			nPerBin = AutoCorrRec(tsecs(i,:),actime,nbins);
			binwidth = actime/nbins;
			xc = linspace(binwidth/2,actime-binwidth/2,nbins);
			bar(xc,nPerBin,1,'k');
			set(gca,'XTickMode','manual','XTick',[],'YTickMode',...
			'manual','YTick',[],'Xlim',[min(xc) max(xc)]);
			if (max(nPerBin)>min(nPerBin))
				set(gca,'Ylim',[0 max(nPerBin)]);
			end
		else
			cla
		end
		%Update the text below each cluster plot
		params = getappdata(h,'params');
		clustnumoffset = params.ClustNumOffset;
		if (i == 1)
			set(hctext(1),'String',sprintf('Unassigned: %d',nsubsnips(i)));
		else
			set(hctext(i),'String',sprintf('%d: %d',i+clustnumoffset-1,nsubsnips(i)));
		end
	end
	toc
	4
	% Clear any display on old axes
	for i = nclust+1:7
		axes(haxc(1,i))
		cla
		axes(haxc(2,i))
		cla
		axes(haxc(3,i))
		cla
		set(hctext(i),'String',sprintf('%d: %d',i+clustnumoffset-1,0));
	end
	clear nsubsnips
	% Update the rate/clust,file graph
	rectime = getappdata(h,'rectime');
	for i = 1:nclust
		for j = 1:nfiles
			nsubsnips(i,j) = length(clflindx{i,j})/rectime(j);
		end
	end
	axes(findobj(h,'Tag','SpikesPerFile'))
	semilogy(nsubsnips');
	set(gca,'Tag','SpikesPerFile');
	ylabel('rate/file');
	xlabel('file number');
	if (nfiles > 1)
		set(gca,'XLim',[1 nfiles]);
	else
		set(gca,'XLim',[0 2]);
	end
	% Reset the GUI properties
	DoMultiChanFunctions('SetCAxProp',h);
	toc
	8	
case 'DefFiltBox'
	if (get(findobj(h,'Tag','DefaultFiltersBox'),'Value') == 1)
		% Turn off the axes for filter construction, and plot
		% the default filters
		svaxall = findobj(findobj(h,'Tag','SVAxes'));	% Get axes & all children
		set(svaxall,'Visible','off');
		wvaxall = findobj(findobj(h,'Tag','WaveAxes'));
		set(wvaxall,'Visible','off');
		axes(findobj(h,'Tag','FiltAxes'));
		filters = getappdata(h,'DefaultFilters');
		plot(filters);
		ylabel('Filters');
		set(gca,'XLim',[1 size(filters,1)]);
		set(gca,'Tag','FiltAxes');
		% Turn on Cluster button if a group is selected
		selindx = GetSelClust(h);
		if (length(selindx) > 0)
			set(findobj(h,'Tag','ClusterButton'),'Enable','on');
		end
	else	
		% Turn on the axes for filter construction, and plot
		% the built filters
		set(findobj(findobj(h,'Tag','SVAxes')),'Visible','on');
		set(findobj(findobj(h,'Tag','WaveAxes')),'Visible','on');
		axes(findobj(h,'Tag','FiltAxes'));
		filters = getappdata(h,'filters');
		if (~isempty(filters))
			plot(filters);
			ylabel('Filters');
			set(gca,'XLim',[1 size(filters,1)]);
		else
			cla
			set(findobj(h,'Tag','ClusterButton'),'Enable','off');
		end
		set(gca,'Tag','FiltAxes');
	end
case 'CrossCorr'
	t = getappdata(h,'t');
	scanrate = getappdata(h,'scanrate');
	clflindx = getappdata(h,'clflindx');
	tmax = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	params = getappdata(h,'params');
	clustnumoffset = params.ClustNumOffset;
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
	tsecs = cell(nclust,nfiles);
	for i = 1:nclust
		for j = 1:nfiles
			if (~isempty(t{j}(clflindx{i,j})))
				tsecs{i,j} = t{j}(clflindx{i,j})/scanrate(j);
			end
		end
	end
	[cpdf,pair,npb] = CrossCorrAll(tsecs,tmax);
	iend = min(25,length(cpdf));
	figure
	set(gcf,'Renderermode','manual','Renderer','zbuffer');
	maxsp = ceil(sqrt(iend));
	for i = 1:iend
		subplot(maxsp,maxsp,i);
		nbins = length(npb{i});
		binwidth = 2*tmax/nbins;
		xax = linspace(-tmax+binwidth/2,tmax-binwidth/2,nbins);
		bar(xax,npb{i},1,'b');
		set(gca,'XLim',[-tmax,tmax]);
		for j = 1:2
			if (pair(i,j) == 1)
				ctext{j} = 'U';
			else
				ctext{j} = sprintf('%d',pair(i,j)+clustnumoffset-1);
			end
		end
		title(sprintf('%s and %s',ctext{1},ctext{2}))
	end

case 'Clear'
	% Delete current clusters and make all spikes unassigned
	nsnips = getappdata(h,'nsnips');
	range = [ones(1,length(nsnips));nsnips];
	indx = BuildIndexMF(range);
	setappdata(h,'clflindx',indx);
	% Unselect any selected clusters
	DoMultiChanFunctions('Unselect',h);
	% Update display
	DoMultiChanFunctions('UpdateDisplay',h);
case 'Delete'
	% Delete selected clusters
	selindx = GetSelClust(h);
	selindx = selindx(find(selindx > 1));	% Can't delete unassigned cluster
	clflindx = getappdata(h,'clflindx');
	upd=1:size(clflindx,1);			%update vector, used by Updatedisplay
	upd=setdiff(upd,selindx);
	clflindx(selindx,:) = [];
	nsnips = getappdata(h,'nsnips');
	clflindx(1,:) = RebuildUnassigned(clflindx,nsnips,h);
	setappdata(h,'clflindx',clflindx);
	setappdata (h,'updatevector',upd);
	DoMultiChanFunctions('Unselect',h);
	DoMultiChanFunctions('UpdateDisplay',h);
case 'Join'
	selindx = GetSelClust(h);
	selindx = selindx(find(selindx > 1));	% Can't delete unassigned cluster
	if (length(selindx) < 2)
		return
	end
	clflindx = getappdata(h,'clflindx');
	nclust = size(clflindx,1);
	nfile = size(clflindx,2);
	for j = 1:nfile
		clflindx{selindx(1),j} = sort( cat(2,clflindx{selindx,j}) );
	end
	clflindx(selindx(2:end),:) = [];
	setappdata(h,'clflindx',clflindx);
	DoMultiChanFunctions('Unselect',h);
	DoMultiChanFunctions('UpdateDisplay',h);
case 'Recon'
	%Not yet implemented for multichannel sorting
	clflindx = getappdata(h,'clflindx');
	spikefiles = getappdata(h,'spikefiles');
	channels = getappdata(h,'channels')
	[flindx,v] = listdlg('ListString',spikefiles,'SelectionMode','single','PromptString','Select a file:');
	if (~v)
		return;
	end
	[snip,tsnip,h] = LoadSnip(spikefiles{flindx},channels(1));
	%h.sniprange=[5 25];
	ViewReconstruction(snip,tsnip,clflindx(:,flindx),h.sniprange,[1 h.nscans]);
	
case 'Crosstalk'
	nfiles=getappdata(h,'nfiles');
	t = getappdata(h,'t');
	% Get the waveforms in the selected clusters
	[selclust,wvindx] = GetSelClust(h);
	tsel=cell(1,nfiles);
	for fnum = 1:nfiles
		tsel{1,fnum} = t{fnum}(wvindx{fnum});
	end
	[ctchannels,idxrem]=crosstalk(tsel,20,h);
	setappdata(h,'plotidxrem',idxrem);
	hmain=getappdata(h,'hmain');
	setappdata(h,'ctchannels',ctchannels);
	hctlist=getappdata(h,'hctlist');
	set(hctlist,'String',sprintf('cross talk: %s',num2str(ctchannels)));
	set(findobj(h,'Tag','DoneButton'),'Enable','on');
case 'Cancel'
	cancelbutton=questdlg ('Really quit sorting this channel?','','yes','no','no');
	switch cancelbutton,
		case 'yes'
			hmain=getappdata (h,'hmain');
			set(findobj(hmain,'Tag','SortButton'),'Enable','on'); %Enable main window sort button  
			delete(h); 
	end %switch
case 'Done'
	% Fill parameters with current values
	params = getappdata(h,'params');
	%params.dispsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	%params.ACTime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	%params.NSpikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	%params.NNoise = str2num(get(findobj(h,'Tag','NumNoise'),'String'));
	%params.BlockSize = str2num(get(findobj(h,'Tag','BlockSize'),'String'));
	setappdata(h,'params',params);
	% The relevant data can be extracted from clflindx & t
	hcancel = findobj(gcf,'Tag','CancelButton');
	set(hcancel,'String','Quit');
	% Convert the index-based storage into spike times
	channels =getappdata (h,'channels');
	spikefiles=getappdata (h,'spikefiles');
	noisefiles=getappdata (h,'noisefiles');
	subrange=getappdata(h,'DefaultSubrange');
	scanrate==getappdata (h,'scanrate');
	tmpindx = getappdata(h,'clflindx');
	t = getappdata(h,'t');
	params = getappdata(h,'params');
	scanrate = getappdata(h,'scanrate');	
	k=getappdata(h,'chindices'); k= k(1);
	hmain=getappdata (h,'hmain');
	ctchannels=getappdata(hmain,'ctchannels');
	chanclust=getappdata(hmain,'chanclust');
	outfile=getappdata (hmain,'outfile');
	removedCT=getappdata (hmain,'removedCT');
	plottimes=getappdata(hmain,'plottimes');
	hcc=getappdata(h,'hcc');
	deffilters=getappdata (hmain,'deffilters');
	allchannels=getappdata (hmain,'allchannels');
	nclust = size(tmpindx,1);
	nfiles = size(tmpindx,2);
	nprevclusts=size(chanclust{k},1);
	tclust = cell(nprevclusts+nclust-1,nfiles);
	ctindices=find(ismember(allchannels,ctchannels));
	%Put previous clusters into tclust
	for i = 1:nprevclusts	
		for j = 1:nfiles
			tclust{i,j} = chanclust{k}{i,j};
		end
	end
	fileclust=cell(1,nfiles);	%fileclust appends all clusters for removal from times	
	for fnum = 1:nfiles
		for clust = 2:nclust	% Don't save the unassigned channel
			tclust{nprevclusts+clust-1,fnum} = t{fnum}(tmpindx{clust,fnum});	%Put new clusters into tclust
			fileclust{fnum}=[fileclust{fnum} tmpindx{clust,fnum}];				%append clusters to fileclust
		end
		%times{k}{fnum}=times{k}{fnum}(:,setdiff(1:size(times{k}{fnum},2),fileclust{fnum}));	%Remove appended clusters from times
	end
	chanclust{k} = tclust;
	tmpremCT = removecrosstalk(tclust,ctchannels,h);
	%Remove crosstalk
	if (length(tmpremCT)>0)
		for c = 1:length(ctchannels)
			for fnum = 1:nfiles
				if (size(tmpremCT{c}{fnum},2)>0)
					ch=ctindices(c);
					removedCT{ch,fnum}=[removedCT{ch,fnum} tmpremCT{c}{fnum}(1,:)];%append new crosstalk times
					%times{ch}{fnum}=times{ch}{fnum}(:,setdiff(1:size(times{ch}{fnum},2),tmpidxremCT{ch}{fnum}));%remove crosstalk
					[placeholder,newindx]=setdiff(plottimes{ch}{fnum}(2,:),tmpremCT{c}{fnum}(2,:));
					plottimes{ch}{fnum}=plottimes{ch}{fnum}(:,newindx);%remove crosstalk
				end
			end
		end
	end
	% Make a file copy after each channel
	% (in case something goes wrong);
	channels=allchannels;
	if pwflag
		save(outfile,'chanclust','removedCT','scanrate','channels');
	else
		save(outfile,'chanclust','removedCT','scanrate','spikefiles','noisefiles','deffilters','subrange','channels');
	end
	% Go on to the next cell #s on the next channel
	params.ClustNumOffset = params.ClustNumOffset+nclust-1;
	set(hmain,'UserData',''); 
	setappdata (hmain,'removedCT',removedCT);
	setappdata (hmain,'chanclust',chanclust);
	setappdata(hmain,'plottimes',plottimes);
	makeArrayplot (hmain)
	set(findobj(hmain,'Tag','SortButton'),'Enable','on');
	close(h)
	
	
	
case 'KeyTrap'
	c = get(h,'CurrentCharacter');
	%fprintf('Key %s, val %d\n',c,double(c)); 
	if (double(c) == 8)	% Delete key
		DoMultiChanFunctions('Delete',h);
	end
otherwise
	error(['Do not recognize action ',action]);
end

function [selindx,wvindx] = GetSelClust(h)
% Get the selected clusters, and consolidate into one big cluster
haxc = getappdata(h,'haxc');
selindx = [];
for i = 1:size(haxc,2)
	if (strcmp(get(haxc(1,i),'Selected'),'on'))
		selindx(end+1) = i;
	end
end
if (nargout > 1)
	% Consolidate the snippets in the selected clusters into one unit
	clflindx = getappdata(h,'clflindx');
	nfiles = size(clflindx,2);
	wvindx = cell(1,nfiles);
	for i = 1:nfiles
		wvindx{i} = sort(cat(2,clflindx{selindx,i}));
	end
end
return

function snips=loaddisplaysnips (nclust)
	snips=cell(1,min(nclust,7));
	nsubsnips=zeros(nclust);
	for i = 1:min(nclust,7)
		for f=1:length(spikefiles)
			if (dispnsnips==0)
				loadindx{f} = clflindx{i,f}(1:min(200,length(clflindx{i,f})));
			else
				loadindx{f} = clflindx{i,f}(1:min(dispnsnips,length(clflindx{i,f})));
			end
			nsubsnips(i)=nsubsnips(i)+length(clflindx{i,f});
		end
		snips{i} = MultiLoadIndexSnippetsMF(spikefiles,channels,loadindx,multiindx);
	end	
