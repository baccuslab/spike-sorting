function DoMultiChanFunctions(action,h)
if (nargin == 1)
	h = gcbf;
end  
handles=getuprop (h,'handles');
g=getuprop(handles.main,'g');
if (g.pwflag)
	global proj,sptimes
end
switch(action)
case 'SetCAxProp'
	set(h,'KeyPressFcn','DoMultiChanFunctions KeyTrap');	 %This seems to get overwritten
	haxc = getuprop(h,'haxc');
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
	haxc = getuprop(h,'haxc');
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
	haxc = getuprop(h,'haxc');
	%selection_type = get(h,'SelectionType');
	%if (~strcmp(selection_type,'extend'))
	% Turn off all other selections if not shift-clicking
	hsel = findobj(haxc,'Selected','on');
	set(hsel,'Selected','off');
	%end
	set(findobj(h,'Tag','BuildFiltersButton'),'Enable','off');
	set(findobj(h,'Tag','DiscrimFiltersButton'),'Enable','off');
	set(findobj(h,'Tag','ClusterButton'),'Enable','off');
case 'SortSubset'
	[selclust,wvindx] = GetSelClust(h);
	if (isempty (selclust))
		g.subsetnum=str2num(get(findobj(h,'Tag','NumSortSnips'),'String'));
		setuprop(handles.main,'g',g);
		clflindx=getsubset (getuprop(h,'clflindxall'),g.subsetnum);
		setuprop (h,'clflindx',clflindx);
		setuprop(h,'clflindxsub',clflindx);
		updatearr(1:3,2:7)=-1;
		updatearr(1:3,1)=0;
	else
		clflindx=getuprop (h,'clflindx');
		clflindxnew=cell(size(selclust,2)+1,size(clflindx,2));
		clflindxnew(1,:)={[]};
		clflindxnew(2:end,:)=clflindx(selclust,:);
		setuprop (h,'clflindx',clflindxnew);
		clflindxsub=cell(1,size(g.spikefiles,2));
		for fnum = 1:size(g.spikefiles,2)
			clflindxsub{fnum} = sort(cat(2,clflindxnew{2:end,fnum}));
		end
		setuprop(h,'clflindxsub',clflindxsub);
		updatearr(1:3,size(selclust,2)+2:7)=-1;
		updatearr(1:3,1+size(selclust,2)+1)=0;
	end
	setuprop (h,'updatearr',updatearr);
	setuprop (h,'Sortstatus',0);
	set(findobj(h,'Tag','SortSubset'),'BackgroundColor',[1 0.5 0.5]);
	set(findobj(h,'Tag','SortAll'),'BackgroundColor',[0.8 0.8 0.8]);	
	DoMultiChanFunctions('UpdateDisplay',h);	
case 'SortAll'
	setuprop (h,'clflindx',getuprop(h,'clflindxall'));
	set(findobj(h,'Tag','SortSubset'),'BackgroundColor',[0.8 0.8 0.8]);
	set(findobj(h,'Tag','SortAll'),'BackgroundColor',[1 0.5 0.5]);
	updatearr(1:3,2:7)=-1;
	updatearr(1:3,1)=0;
	setuprop (h,'updatearr',updatearr);
	setuprop (h,'Sortstatus',1);
	setuprop (h,'Storestatus',1); %Set store status to off. (Set on, then toggle).
	DoMultiChanFunctions('Storeinmem');
	DoMultiChanFunctions('UpdateDisplay',h);	
case 'Storeinmem'
	storestatus=getuprop (h,'Storestatus');
	if (storestatus==0)
		setuprop (h,'Storestatus',1);
		set(findobj(h,'Tag','Storeinmem'),'BackgroundColor',[1 0.5 0.5]);
		sortchannels = getuprop(h,'sortchannels');
		clflindx=getuprop (h,'clflindx');
		spindx=getuprop(h,'spindx');
		if (getuprop(h,'Sortstatus'))
			wvindx=getuprop (h,'clflindxall');
		else
			wvindx=getuprop (h,'clflindxsub');
		end
		[storedsnips,header]  = MultiLoadIndexCTMF(g.spikefiles,g.ctfiles,sortchannels,wvindx,spindx);
		setuprop (h,'storedsnips',storedsnips); clear storedsnips
		setuprop (h,'storedindx',wvindx); clear wvindx
		hdr = ReadSnipHeader(g.spikefiles{1});
		setuprop (h,'storedsniprange',hdr.sniprange);
	else
		setuprop (h,'Storestatus',0);
		set(findobj(h,'Tag','Storeinmem'),'BackgroundColor',[0.8 0.8 0.8]);
		clruprop (h,'storedsnips');
		clruprop (h,'storedindx');
		clruprop (h,'storedsniprange');
	end

case 'BuildFilters'
	% Get the numbers from the edit boxes
	nspikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	nnoise = str2num(get(findobj(h,'Tag','NumNoise'),'String'));
	% Get the waveforms in the selected clusters
	[selclust,wvindx] = GetSelClust(h);
	hmain=getuprop(h,'hmain');
	sortchannels = getuprop(h,'sortchannels');
	spindx=getuprop(h,'spindx');
	[filters,subrange,sv,wave] = multiBFI(g.spikefiles,g.ctfiles,g.noisefiles,...
	nspikes,nnoise,sortchannels,wvindx,spindx,h); 
	setuprop (gcf,'wavehold',wave);
	if (length(filters) == 0)
		return;
	end
	setuprop(h,'filters',filters);
	setuprop(h,'subrange',subrange);
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
	clflindx = getuprop(h,'clflindx');
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
	sortchannels = getuprop(h,'sortchannels');
	spindx=getuprop(h,'spindx');
	spikes = cell(nsel,1);
	for i = 1:nsel
		spikes{i} = MultiLoadIndexSnippetsMF(g.spikefiles,g.ctfiles,sortchannels,wvindx(i,:),spindx,h);
	end
	[filt,lambda] = MaxSep(spikes);
	sv = sqrt(lambda);
	filters = filt(:,1:2);
	ifilt = inv(filt);
	wave = ifilt(1:2,:)';
	setuprop(h,'filters',filters);
	subrange = [1 size(spikes{1},1)];
	setuprop(h,'subrange',subrange);
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
	sortchannels = getuprop(h,'sortchannels');
	chindices=getuprop(h,'chindices');
	snipsize=getuprop (h,'snipsize');
	if (get(findobj(h,'Tag','DefaultFiltersBox'),'Value') == 1)
		basefilter = g.deffilters{chindices(1)};	% Use default filters
		filters=zeros(size(basefilter,1)+(length(sortchannels)-1)*snipsize,size(basefilter,2));
		for ch=0:(length(sortchannels)-1)
			filters((ch*snipsize+1):(ch*snipsize+size(basefilter,1)),:)=basefilter;
		end
		subrange=g.subrange;
		subrange(2)=subrange(1)+size(filters,1)-1;
	else
		filters = getuprop(h,'filters');			% Use built filters
		subrange = getuprop(h,'subrange');
	end
	% Get the blocksize from the edit box
	blocksize = str2num(get(findobj(h,'Tag','BlockSize'),'String'));
	% Get the waveforms in the selected clusters
	[selclust,wvindx] = GetSelClust(h);	
	replclust = selclust(find(selclust>1));	% Don't replace the unassigned channel
	clflindx = getuprop(h,'clflindx');	
	replclust(end+1) = size(clflindx,1)+1;	% After replacing, append more clusters
	nfiles = length(wvindx);
	% Offset the cluster # labels appropriately
	params = getuprop(h,'params');
	clustnumoffset = params.ClustNumOffset;
	% Group the channels
	spindx=getuprop(h,'spindx');
	sptimes=getuprop(h,'t');
	if (and(get(findobj(h,'Tag','DefaultFiltersBox'),'Value') == 1,length(chindices)==1))
		[tnew,indxnew] = GroupDefaultProj(g,sortchannels,chindices,...
		blocksize,replclust+clustnumoffset-1,wvindx,spindx,sptimes,h);
	else
		[tnew,indxnew] = GroupMultiChannel(g,sortchannels,...
		filters,subrange,blocksize,replclust+clustnumoffset-1,wvindx,spindx,sptimes,h);
	end
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
		updatearr(1:3,1)=0;
		updatearr(1:3,2:7)=-1;
		for i = 1:size(indxnew,1)
			for j = 1:nfiles
				newclflindx{replclust(i),j} = wvindx{j}(indxnew{i,j});
			end
			updatearr(1:3,replclust(i))=0;
		end
		if (length(replclust)-1 > size(indxnew,1))
			% Trash any clusters that got eliminated
			elim = replclust(size(indxnew,1)+1:end-1); % eliminate if selected more than returned
			newclflindx(elim,:) = [];
			updatearr(1:3,elim)=0;
		end
		if (getuprop(h,'Sortstatus'))
			newclflindx(1,:) = RebuildUnassigned(getuprop(h,'clflindxall'),newclflindx);
		else
			newclflindx(1,:) = RebuildUnassigned(getuprop(h,'clflindxsub'),newclflindx);
		end
		% Store the new assignments
		setuprop(h,'clflindx',newclflindx);
		setuprop(h,'updatearr',updatearr);
		DoMultiChanFunctions('Unselect',h);
		DoMultiChanFunctions('UpdateDisplay',h);
		set(findobj(h,'Tag','DoneButton'),'Enable','off');
	end			% End of (~isempty(tnew))
	DoMultiChanFunctions('SetCAxProp',h);
case 'MultiCluster'
	% Get the waveforms in the selected clusters
	[selclust,selindx] = GetSelClust(h);
	setuprop (h,'selclust',selclust)
	setuprop (h,'selindx',selindx);
	sortchannels = getuprop(h,'sortchannels');
	% Group the channels
	set(findobj(h,'Tag','DoneButton'),'Enable','off');
	mgroup (h,g,sortchannels,selindx);
case 'NumSnips'
	clflindx = getuprop(h,'clflindx');
	nclust = size(clflindx,1);
	clear clflindx
	updatearr(1,1:nclust)=0;
	updatearr(1,nclust+1:7)=-1;
	updatearr([2 3],1:7)=-1;
	setuprop (h,'updatearr',updatearr);
	DoMultiChanFunctions('UpdateDisplay',h);
case 'AutoCorrTime'	
	clflindx = getuprop(h,'clflindx');
	nclust = size(clflindx,1);
	clear clflindx
	updatearr(2,1:nclust)=0;
	updatearr(2,nclust+1:7)=-1;
	updatearr([1 3],1:7)=-1;
	setuprop (h,'updatearr',updatearr);
	actime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	if (actime>0)
		DoMultiChanFunctions('UpdateDisplay',h);
	end
case 'UpdateDisplay'
	% Update the cluster display windows
	haxc = getuprop(h,'haxc');
	hctext = getuprop(h,'hctext');
	params = getuprop(h,'params');
	clflindx = getuprop(h,'clflindx');
	sortchannels = getuprop(h,'sortchannels');
	spindx=getuprop(h,'spindx');
	t = getuprop(h,'t');
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
	dispnsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	actime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	display=getuprop(h,'display');
	updatearr=getuprop (h,'updatearr');
	%Updatearr (cluster,plot) array of updating instructions encoded as follows:
	%-1:Leave cluster unchanged
	%0:recalculate cluster
	%n>=1:transfer from cluster n
	%Plots={1,2,3}:1:snippets 2:autocorr 3:amplitude histogram
	if (dispnsnips~=0) loadnsnips=dispnsnips; else loadnsnips=100; end
	tsecs = cell(1,nfiles); %   Spike times, in units of seconds
	for c=1:min(nclust,7)
		numsnips=0;
		for f=1:nfiles
			numsnips=numsnips+length(clflindx{c,f});
		end
		if (updatearr(1,c)>=0) %Snippet plot is flagged for updating
			if (updatearr(1,c)==0) %Load example snippets
				if (get(findobj(h,'Tag','dispsnipsbox'),'Value'))
					subindx=getsubset (clflindx(c,:),loadnsnips);					
				else
					for fn=1:nfiles %Only show snips from one file, for speed
						snum(fn)=size(clflindx{c,fn},2);
					end
					flist=find(snum==max(snum));flist=flist(1);%Choose file with the most snips for each cluster
					subindx=cell(1,nfiles);
					subindx(flist)=getsubset (clflindx(c,flist),loadnsnips);		
				end
				display.snips{c} = MultiLoadIndexSnippetsMF(g.spikefiles,g.ctfiles,sortchannels,subindx,spindx,h);
				%subindx=getsubset (clflindx(c,:),loadnsnips);
				% display.snips{c} = MultiLoadIndexSnippetsMF(g.spikefiles,g.ctfiles,sortchannels,subindx,spindx,h);
			else %Updatearr(1,c)>0 ,transfer clusters to different number,
				%as occurs during cluster deletion
				display.snips{c}=display.snips{updatearr(1,c)};
			end
			%plot snippets
			axes(haxc(1,c));
			if (~isempty(display.snips{c}))
				if (dispnsnips==0)
					plot(mean(display.snips{c}(:,1:min(size(display.snips{c},2),200)),2));
				else
					plot(display.snips{c}(:,1:min(size(display.snips{c},2),dispnsnips)));
				end
			
			else
				cla %no snips, clear axis
			end
			set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[])
		end
		if (updatearr(2,c)>=0) %Autocorr plot is flagged for updating
			if (and(numsnips>0,updatearr(2,c)==0)) %Recalculate autocorr
				for j = 1:nfiles
					tsecs{j}=[];
					if (~isempty(t{j}(clflindx{c,j})))
						tsecs{j} = t{j}(clflindx{c,j})/g.scanrate;
					end
				end
				if (or(and(g.pwflag ,length(tsecs{1})>0) , size(display.snips{c},2)>0)) 
					nbins = 50;
					binwidth = actime/nbins;
					display.corr.x{c} = linspace(binwidth/2,actime-binwidth/2,nbins);
					display.corr.n{c}= AutoCorrRec(tsecs,actime,nbins);
				end
			elseif (updatearr(2,c)>0)
				%Updatearr(c)>0 ,transfer clusters to different number,
				%as occurs during cluster deletion
				display.corr.n{c}=display.corr.n{updatearr(2,c)};
				display.corr.x{c}=display.corr.x{updatearr(2,c)};
			end	
			%plot autocorrelation
			axes(haxc(2,c));
			if (and(numsnips>0,size(display.corr.n{c},2)>0))
				bar(display.corr.x{c},display.corr.n{c},'k');
			else
				cla
			end
			set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[])			
		end
		if (updatearr(3,c)>=0) %Amplitude histogram is flagged for updating
			%Note: If amp hist. is flagged, snippets (plot 1) is flagged,
			%because the snippets are loaded only once for the two plots.
			if (updatearr(3,c)==0) 
				%Calculate amplitude histogram
				if (~g.pwflag)
					amp=max(display.snips{c})-min(display.snips{c});
				else
					amp=proj{sortchannels(1)}(2,clflindx{c,1});
				end
				[display.hist.n{c},display.hist.x{c}] = hist(amp,0:0.3:10);
			else
				%Updatearr(c)>0 ,transfer clusters to different number,
				%as occurs during cluster deletion
				display.hist.n{c}=display.hist.n{updatearr(3,c)};
				display.hist.x{c}=display.hist.x{updatearr(3,c)};
			end
			%plot amplitude histogram
			axes(haxc(3,c));
			bar(display.hist.x{c},display.hist.n{c},'k');
			set(gca,'yScale','log');
			set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[])			
		end	
		%Write number of snippets below plots
		clustnumoffset = params.ClustNumOffset;
		if (c == 1)
			set(hctext(1),'String',sprintf('Unassigned: %d',numsnips));
		else
			set(hctext(c),'String',sprintf('%d: %d',c+clustnumoffset-1,numsnips));
		end
	end
	%Get Axis limts
	snipmin=99999;snipmax=-99999;amphistymax=0;amphistxmin=99999;amphistxmax=-99999;snipsize=0;
	for c=1:min(7,nclust)
		snipsize=max([snipsize size(display.snips{c},1)]);
		snipmax=max([snipmax max(max(display.snips{c}))]);
		snipmin=min([snipmin min(min(display.snips{c}))]);
		amphistymax=max([amphistymax max(display.hist.n{c})]);
		amphistxmin=min([amphistxmin min(display.hist.x{c})]);
		amphistxmax=max([amphistxmax max(display.hist.x{c})]);
	end
	%Set Axis limits
	for c=1:min(7,nclust);
		set(haxc(1,c),'XLim',[0 snipsize],'YLim',[snipmin snipmax]);
		set(haxc(2,c),'Xlim',[0 actime]);
		set(haxc(3,c),'XLim',[amphistxmin amphistxmax],'YLim',[0 amphistymax]);
	end
	% Clear any display on old axes
	for c= nclust+1:7
		axes(haxc(1,c))
		cla
		axes(haxc(2,c))
		cla
		axes(haxc(3,c))
		cla
		set(hctext(c),'String',sprintf('%d: %d',c+clustnumoffset-1,0));
	end
	% Update the rate/clust,file graph
	rectime = getuprop(h,'rectime');
	for c = 1:nclust
		for f = 1:nfiles
			nsubsnips(c,f) = length(clflindx{c,f})/rectime(f);
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
	setuprop(h,'display',display);
	updatearr(:,:)=-1;
	setuprop (h,'updatearr',updatearr);
	DoMultiChanFunctions('SetCAxProp',h);
	
case 'DefFiltBox'
	chindices=getuprop(h,'chindices');
	if (get(findobj(h,'Tag','DefaultFiltersBox'),'Value') == 1)
		% Turn off the axes for filter construction, and plot
		% the default filters
		svaxall = findobj(findobj(h,'Tag','SVAxes'));	% Get axes & all children
		set(svaxall,'Visible','off');
		wvaxall = findobj(findobj(h,'Tag','WaveAxes'));
		set(wvaxall,'Visible','off');
		axes(findobj(h,'Tag','FiltAxes'));
		filters = g.deffilters{chindices(1)};
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
		filters = g.deffilters{chindices(1)};
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
case 'dispsnipsbox'
	updatearr([1,3],1:7)=0;
	updatearr(2,1:7)=-1;
	setuprop(h,'updatearr',updatearr);
	DoMultiChanFunctions('UpdateDisplay',h);
case 'CrossCorr'
	t = getuprop(h,'t');
	clflindx = getuprop(h,'clflindx');
	tmax = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	params = getuprop(h,'params');
	clustnumoffset = params.ClustNumOffset;
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
	tsecs = cell(nclust,nfiles);
	for i = 1:nclust
		for j = 1:nfiles
			if (~isempty(t{j}(clflindx{i,j})))
				tsecs{i,j} = t{j}(clflindx{i,j})/g.scanrate;
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
	newclflindx=cell(size(g.spikefiles,2));
	clflindx=getuprop (h,'clflindx');
	for fnum = 1:size(g.spikefiles,2)
		newclflindx{fnum} = sort(cat(2,clflindx{1:end,fnum}));
	end
	setuprop (gcf,'clflindx',newclflindx);
	updatearr(1:3,1)=0;
	updatearr(1:3,2:7)=-1;
	setuprop (h,'updatearr',updatearr);
	% Unselect any selected clusters
	DoMultiChanFunctions('Unselect',h);
	% Update display
	DoMultiChanFunctions('UpdateDisplay',h);
case 'Delete'
	%Get clusters
	selindx = GetSelClust(h);
	selindx = selindx(find(selindx > 1));	% Can't delete unassigned cluster
	clflindx = getuprop(h,'clflindx');
	%make update array used by Updatedisplay
	remclusts=setdiff(1:size(clflindx,1),selindx);
	remclusts=remclusts(find(remclusts<=7));
	updatearr(1:3,1:size(remclusts,2))=[remclusts;remclusts;remclusts];
	updatearr(1:3,1)=0;
	updatearr(1:3,size(remclusts,2)+1:min(7,size(clflindx,1)))=0;
	updatearr(1:3,size(clflindx,1):7)=-1;
	% Delete selected clusters
	newclflindx=clflindx;
	newclflindx(selindx,:) =[];
	nsnips = getuprop(h,'nsnips');
	if (getuprop(h,'Sortstatus'))
		newclflindx(1,:) = RebuildUnassigned(getuprop(h,'clflindxall'),newclflindx);
	else
		newclflindx(1,:) = RebuildUnassigned(getuprop(h,'clflindxsub'),newclflindx);
	end
	setuprop(h,'clflindx',newclflindx);
	setuprop (h,'updatearr',updatearr);
	DoMultiChanFunctions('Unselect',h);
	DoMultiChanFunctions('UpdateDisplay',h);
case 'Join'
	selindx = GetSelClust(h);
	selindx = selindx(find(selindx > 1));	% Can't delete unassigned cluster
	if (length(selindx) < 2)
		return
	end
	clflindx = getuprop(h,'clflindx');
	nclust = size(clflindx,1);
	nfile = size(clflindx,2);
	%make update array used by Updatedisplay
	remclusts=setdiff(1:nclust,selindx(2:end));
	remclusts=remclusts(find(remclusts<=7));
	updatearr(1:3,1:size(remclusts,2))=[remclusts;remclusts;remclusts];
	updatearr(1:3,selindx(1))=0;
	updatearr(1:3,size(remclusts,2)+1:min(7,nclust))=0;
	updatearr(1:3,nclust:7)=-1;
	for j = 1:nfile
		clflindx{selindx(1),j} = sort( cat(2,clflindx{selindx,j}) );
	end
	clflindx(selindx(2:end),:) = [];
	setuprop(h,'clflindx',clflindx);
	setuprop (h,'updatearr',updatearr);
	DoMultiChanFunctions('Unselect',h);
	DoMultiChanFunctions('UpdateDisplay',h);
case 'Recon'
	spindx=getuprop (h,'spindx');
	clflindx = getuprop(h,'clflindx');
	sortchannels = getuprop(h,'sortchannels');
	[flindx,v] = listdlg('ListString',g.spikefiles,'SelectionMode','single','PromptString','Select a file:');
	if (~v)
		return;
	end
	snips=cell(size(clflindx,1),1);
	sptimes=cell(size(clflindx,1),1);
	for c=1:size(clflindx,1)
		if (size(clflindx{c,flindx},2)>0)
			[snips{c},sptimes{c}] = LoadIndexSnip(g.spikefiles{flindx},sortchannels(1),spindx{flindx}(clflindx{c,flindx}));
		end
	end
	[time,hdr]=LoadSnipTimes(g.spikefiles{flindx},sortchannels(1),1);
	%ViewReconstruction(sortchannels,snip,tsnip,clflindx(:,flindx),h.sniprange,[1 h.nscans]);
	ViewReconstruction([1 50000],g.ctfiles(flindx),sortchannels,sptimes,hdr);
case 'Crosstalk'
	t = getuprop(h,'t');
	nfiles=size(g.spikefiles,2);
	[selclust,wvindx] = GetSelClust(h); 	%indices in the selected clusters
	clflindx=getuprop (h,'clflindx');
	%Get times for subset
	nclust=size (selclust,2);
	tsel=cell(nclust,nfiles);				
	for cl=1:nclust
		subindx=getsubset (clflindx(selclust(cl),:),30*nfiles);	%Changed  SAB 10/13/08, Change to smaller  number if too slow
		for fnum = 1:size(g.spikefiles,2)
			tsel{cl,fnum} = t{fnum}(subindx{fnum});
		end
	end
	%Open Crosstalk window if not already open
	if (~ishandle(handles.ctwin))		
		handles.ctwin=crosstalkwindow (h,g);
		setuprop (h,'handles',handles);
	else
		figure (handles.ctwin); %Bring ctwin to front
	end
	crosstalkfunctions ('calculate',tsel,handles.ctwin); %Show crosstalk for the selected times
	
case 'Cancel'
	cancelbutton=questdlg ('Really quit sorting this channel?','','yes','no','no');
	switch cancelbutton,
	case 'yes'
		set(findobj(handles.main,'Tag','Quit'),'Enable','on'); %Enable main window quit button  
		setuprop (handles.main,'SortEnable','on');%Enable channel sorting in main window
		delete(h); 
		if (ishandle(handles.ctwin))
			delete (handles.ctwin);
		end
	end %switch
case 'Done'
	% Get variables
	%If sorting only a subset of spikes, check if user really wants to finish
	sortstatus=getuprop(h,'Sortstatus');
	if (~sortstatus)
		donebutton=questdlg ('You have sorted only a subset of spikes: really finish?','','yes','no','no');
		switch donebutton,
		case 'no'
			return
		end %switch
	end
	newclindx = getuprop(h,'clflindx');
	spindx=getuprop(h,'spindx');
	t = getuprop(h,'t');
	sortchidx=getuprop(h,'chindices');sortchidx=sortchidx(1);
	outfile=getuprop (handles.main,'outfile');
	nchans=size(g.channels,2);
	nnewclusts = size(newclindx,1)-1;
	if (nnewclusts == 0 ) return ; end
	nfiles = size(newclindx,2);
	nprevclusts=size(g.chanclust{sortchidx},1);
	sortchannels=getuprop(h,'sortchannels');
	if (g.samplesorting)
		ctchannels=setdiff(3:63,sortchannels(1));
	else
		ctchannels=getuprop(h,'ctchannels');
	end
	ctindices=find(ismember(g.channels,ctchannels));
	set (handles.ch(1),'Units','Pixels');
	pos=get(handles.ch(1),'Position');
	nx=floor(pos(3));ny=floor(pos(4));
	%Put previous clusters into tclust
	oldclusts= g.chanclust{sortchidx};
	newclusts=cell(nnewclusts,nfiles);
	fileclust=cell(1,nfiles);	%fileclust appends all clusters for removal from times	
	for fnum = 1:nfiles
		for clnum = 2:nnewclusts+1	% Don't save the unassigned channel
			newclusts{clnum-1,fnum}=t{fnum}(newclindx{clnum,fnum});
			fileclust{fnum}=[fileclust{fnum} newclindx{clnum,fnum}];				%append clusters to fileclust
		end
	end
	if (~isempty (oldclusts))
		g.chanclust{sortchidx} = cat(1,oldclusts,newclusts);
	else
		g.chanclust{sortchidx} = newclusts;
	end
	if (length (ctchannels)>0)
		[tmpremCT,tmpremidx] = removecrosstalk(g,newclusts,ctchannels,h);
	else
		tmpremCT=[];
	end

	%Save removed crosstalk 
	if (length(tmpremCT)>0)
		for c = 1:length(ctchannels)
			for fnum = 1:nfiles
				if (size(tmpremCT{c}{fnum},2)>0)
					ch=ctindices(c);
					g.removedCT{ch,fnum}=[g.removedCT{ch,fnum} tmpremCT{c}{fnum}(1,:)];%append new crosstalk times
				end
			end
		end
	end
	%Remove spikes from array plot
	remidx=cell(length(ctchannels)+1,nfiles);
	for clust=2:nnewclusts+1
		for fnum = 1:nfiles
			if (size(newclindx{clust,fnum},2)>0)
				remidx{1,fnum}=spindx{fnum}(1,newclindx{clust,fnum});
			end
		end
	end
	%Remove crosstalk from array plot
	if (length(tmpremCT)>0)
		for c = 1:length(ctchannels)
			for fnum = 1:nfiles
				if (size(tmpremCT{c}{fnum},2)>0)
					ch=ctindices(c);
					[alltimes{fnum},hdr]=loadsniptimes(g.spikefiles{fnum},ch);
					alltimes{fnum}=[alltimes{fnum}';1:length(alltimes{fnum})];
					remidx{c+1,fnum}=tmpremidx{c}{fnum};
				end
			end
		end
	end
	remidxlist=[sortchidx ctindices];
	proj=loadprojindexed('proj.bin',remidxlist,nchans,nfiles,remidx);
	[xc,yc,nspikes]=Hist2dcalc(proj,nx,ny,g.rectx(remidxlist,:),g.recty(remidxlist,:)); 
	for ch=1:length (remidxlist)
		g.nspikes{remidxlist(ch)}=g.nspikes{remidxlist(ch)}-nspikes{ch};
		g.nspikes{remidxlist(ch)}(find(g.nspikes{remidxlist(ch)}<0))=0;
	end
	% Make a file copy after each channel
	% (in case something goes wrong);
	if g.pwflag
		save(g.outfile,'g');
	else
		save(g.outfile,'g');
	end
	% Go on to the next cell #s on the next channel
	set(handles.main,'UserData',''); 
	setuprop (handles.main,'g',g);
	arrayplot (g.channels,handles.ch,g.xc,g.yc,g.nspikes)
	set(findobj(handles.main,'Tag','Quit'),'Enable','on'); %Enable main window quit button  
	setuprop (handles.main,'SortEnable','on');%Enable channel sorting in main window
	delete(h); 
case 'KeyTrap'
	c = get(h,'CurrentCharacter');
	%fprintf('Key %s, val %d\n',c,double(c)); 
	if (double(c) == 8)	% Delete key
		DoMultiChanFunctions('Delete',h);
	end
otherwise
	error(['Do not recognize action ',action]);
end

function [selclusts,wvindx] = GetSelClust(h)
% Get the selected clusters, and consolidate into one big cluster
haxc = getuprop(h,'haxc');
selclusts = [];
for i = 1:size(haxc,2)
	if (strcmp(get(haxc(1,i),'Selected'),'on'))
		selclusts(end+1) = i;
	end
end
if (nargout > 1)
	% Consolidate the snippets in the selected clusters into one unit
	clflindx = getuprop(h,'clflindx');
	nfiles = size(clflindx,2);
	wvindx = cell(1,nfiles);
	for i = 1:nfiles
		wvindx{i} = sort(cat(2,clflindx{selclusts,i}));
	end
end
return
