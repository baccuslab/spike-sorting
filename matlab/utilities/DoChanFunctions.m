function DoChanFunctions(action,h)
if (nargin == 1)
	h = gcbf;
end
switch(action)
case 'SetCAxProp'
	set(h,'KeyPressFcn','DoChanFunctions KeyTrap');	 %This seems to get overwritten
	haxc = getappdata(h,'haxc');
	axcol = [0.6 0.6 0.6];
	set(haxc,'Tag','ClustAxes', ...
		'Box','off',...
		'XColor',axcol,'YColor',axcol,...
		'ButtonDownFcn','DoChanFunctions SelectCell',...
		'XTickMode','manual','XTick',[],...
		'YTickMode','manual','YTick',[]);
	% See if there is anything plotted in these axes
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
	channel = getappdata(h,'channel');
	[filters,subrange,sv,wave] = BFI(getappdata(h,'spikefiles'),getappdata(h,'noisefiles'),...
		nspikes,nnoise,channel,wvindx);
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
	channel = getappdata(h,'channel');
	sfiles = getappdata(h,'spikefiles');
	spikes = cell(nsel,1);
	for i = 1:nsel
		spikes{i} = LoadIndexSnippetsMF(sfiles,channel,wvindx(i,:));
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
	channel = getappdata(h,'channel');
	if (get(findobj(h,'Tag','DefaultFiltersBox'),'Value') == 1)
		filters = getappdata(h,'DefaultFilters');	% Use default filters
		subrange = getappdata(h,'DefaultSubrange');
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
	% Group the channel
	spikefiles = getappdata(h,'spikefiles');
	[tnew,indxnew] = GroupChannel(spikefiles,channel,...
		filters,subrange,blocksize,replclust+clustnumoffset-1,wvindx);
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
		DoChanFunctions('Unselect',h);
		DoChanFunctions('UpdateDisplay',h);
	end			% End of (~isempty(tnew))
	DoChanFunctions('SetCAxProp',h);
case 'UpdateDisplay'
	% Update the display
	haxc = getappdata(h,'haxc');
	t = getappdata(h,'t');
	scanrate = getappdata(h,'scanrate');
	hctext = getappdata(h,'hctext');
	clflindx = getappdata(h,'clflindx');
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
	spikefiles = getappdata(h,'spikefiles');
	channel = getappdata(h,'channel');
	dispnsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	actime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	for i = 1:min(nclust,7)
		axes(haxc(1,i));
		% First, the waveform display. Load a few waveforms from cluster
		for j = 1:nfiles
			nsubsnips(j) = length(clflindx{i,j});
		end
		range = BuildRangeMF(nsubsnips,[1 dispnsnips]);	% Load first n snippets
		viewindx = BuildIndexMF(range,clflindx(i,:));
		snips = LoadIndexSnippetsMF(spikefiles,channel,viewindx);
		%fprintf('i = %d, size(snips) = %d, %d\n',i,size(snips,1),size(snips,2));
		%viewindx{1}
		%viewindx{2}
		xlim([0 size(snips,1)]);
		ylim([min(min(snips)) max(max(snips))]);
		if (~isempty(snips))
			hold on
			plot(snips);
			hold off
		else
			cla
		end
		set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
		haxc(1,i) = gca;
		% Now the autocorrelation display.
		%   Get the spike times, in units of seconds
		tsecs = cell(nfiles);
		for j = 1:nfiles
			if (~isempty(t{j}(clflindx{i,j})))
				tsecs{j} = t{j}(clflindx{i,j})/scanrate(j);
			end
		end
		%  Calculate & plot the autocorrelation function.
		axes(haxc(2,i));
		%if (~isempty(tvec))
			set(gca,'Units','pixels');
			pos = get(gca,'Position');
			npix = pos(2);
			nbins = ceil(npix/2);
			nPerBin = AutoCorrRec(tsecs,actime,nbins);
			binwidth = actime/nbins;
			xc = linspace(binwidth/2,actime-binwidth/2,nbins);
			xlim([min(xc) max(xc)]);
			ylim([min(nPerBin) max(nPerBin)]);
			bar(xc,nPerBin,1,'k');
		%else
		%	cla
		%end
		set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
		haxc(2,i) = gca;
		% Update the text below each cluster plot
		params = getappdata(h,'params');
		clustnumoffset = params.ClustNumOffset;
		if (i == 1)
			set(hctext(1),'String',sprintf('Unassigned: %d',sum(nsubsnips)));
		else
			set(hctext(i),'String',sprintf('%d: %d',i+clustnumoffset-1,sum(nsubsnips)));
		end
	end
	% Clear any display on old axes
	for i = nclust+1:7
		axes(haxc(1,i))
		cla
		axes(haxc(2,i))
		cla
		set(hctext(i),'String',sprintf('%d: %d',i+clustnumoffset-1,0));
	end
	% Go back and set the axis limits on all waveform displays to be equal
	ymin = 10000;
	ymax = -10000;
	for i = 1:min(7,nclust)
		ylim = get(haxc(1,i),'YLim');
		if (ylim(1) < ymin)
			ymin = ylim(1);
		end
		if (ylim(2) > ymax)
			ymax = ylim(2);
		end
	end
	for i = 1:min(7,nclust)
		set(haxc(1,i),'YLim',[ymin ymax]);
	end
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
	DoChanFunctions('SetCAxProp',h);
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
	DoChanFunctions('Unselect',h);
	% Update display
	DoChanFunctions('UpdateDisplay',h);
case 'Delete'
	% Delete selected clusters
	selindx = GetSelClust(h);
	selindx = selindx(find(selindx > 1));	% Can't delete unassigned cluster
	clflindx = getappdata(h,'clflindx');
	clflindx(selindx,:) = [];
	nsnips = getappdata(h,'nsnips');
	clflindx(1,:) = RebuildUnassigned(clflindx,nsnips,h);
	setappdata(h,'clflindx',clflindx);
	DoChanFunctions('Unselect',h);
	DoChanFunctions('UpdateDisplay',h);
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
	DoChanFunctions('Unselect',h);
	DoChanFunctions('UpdateDisplay',h);
case 'Recon'
	clflindx = getappdata(h,'clflindx');
	spikefiles = getappdata(h,'spikefiles');
	channel = getappdata(h,'channel');
	[flindx,v] = listdlg('ListString',spikefiles,'SelectionMode','single','PromptString','Select a file:');
	if (~v)
		return;
	end
	[snip,tsnip,h] = LoadSnip(spikefiles{flindx},channel);
	ViewReconstruction(snip,tsnip,clflindx(:,flindx),h.sniprange,[1 h.nscans]);

case 'Crosstalk'
		nfiles=size(getappdata(h,'spikefiles'),2);
		t = getappdata(h,'t');
		% Get the waveforms in the selected clusters
		[selclust,wvindx] = GetSelClust(h);
		tsel=cell(1,nfiles);
		for fnum = 1:nfiles
			tsel{1,fnum} = t{fnum}(wvindx{fnum});
		end
		[ctchannels,idxrem]=crosscorrone(tsel,20,h);
		setappdata(h,'idxrem',idxrem);
		hmain=getappdata(h,'hmain');
		setappdata(hmain,'ctchannels',ctchannels);
		hctlist=getappdata(h,'hctlist');
		set(hctlist,'String',sprintf('cross talk: %s',num2str(ctchannels)));
case 'Multichannel'		
	set(h,'UserData','done');
	setappdata(h,'multisort',1);
		
case 'Cancel'
	delete(h);
case 'Done'
	% Fill parameters with current values
	params = getappdata(h,'params');
	params.dispsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	params.ACTime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	params.NSpikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	params.NNoise = str2num(get(findobj(h,'Tag','NumNoise'),'String'));
	params.BlockSize = str2num(get(findobj(h,'Tag','BlockSize'),'String'));
	setappdata(h,'params',params);
	% Signal other code using waitfor that we're done
	% The relevant data can be extracted from clflindx & t
	set(h,'UserData','done');
case 'KeyTrap'
	c = get(h,'CurrentCharacter');
	%fprintf('Key %s, val %d\n',c,double(c)); 
	if (double(c) == 8)	% Delete key
		DoChanFunctions('Delete',h);
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

function uas = RebuildUnassigned(assindx,nsnips,h)
% Re-compute the unassigned group as the difference
% between the total and the assigned data
% First get the union of all assigned data
nclust = size(assindx,1);
nfiles = size(assindx,2);
chindx=getappdata(h,'chindx');
alltimes=getappdata(h,'alltimes');
wvindx = cell(1,nfiles);
for fnum = 1:nfiles
	wvindx{fnum} = cat(2,assindx{2:nclust,fnum});
end
% Now the unassigned data
for fnum = 1:nfiles
	uas{fnum} = setdiff(alltimes{chindx}{fnum}(2,:),wvindx{fnum});
end
