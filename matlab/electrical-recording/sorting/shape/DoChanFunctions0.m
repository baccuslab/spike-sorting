function DoChanFunctions(action,h)
if (nargin == 1)
	h = gcbf;
end
switch(action)
case 'SetCAxProp'
	set(h,'KeyPressFcn','DoChanFunctions KeyTrap');	 %This seems to get overwritten
	haxc = getuprop(h,'haxc');
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
case 'BuildFilters'
	% Get the numbers from the edit boxes
	nspikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	nnoise = str2num(get(findobj(h,'Tag','NumNoise'),'String'));
	% Get the waveforms in the selected clusters
	[selclust,wvindx] = GetSelClust(h);
	channel = getuprop(h,'channel');
	[filters,subrange,sv,wave] = BFI(getuprop(h,'spikefiles'),getuprop(h,'noisefiles'),...
		nspikes,nnoise,channel,wvindx);
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
	for i = 1:nfiles
		for j = 1:nsel
			wvindx{j,i} = clflindx{selclust(j),i};
		end
	end
	channel = getuprop(h,'channel');
	sfiles = getuprop(h,'spikefiles');
	spikes = cell(nsel,1);
	for i = 1:nsel
		spikes{i} = LoadIndexSnippetsMF(sfiles,'spike',channel,wvindx(i,:));
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
	channel = getuprop(h,'channel');
	if (get(findobj(h,'Tag','DefaultFiltersBox'),'Value') == 1)
		filters = getuprop(h,'DefaultFilters');	% Use default filters
		subrange = getuprop(h,'DefaultSubrange');
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
	% Group the channel
	spikefiles = getuprop(h,'spikefiles');
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
		nsnips = getuprop(h,'nsnips');
		newclflindx(1,:) = RebuildUnassigned(newclflindx,nsnips);
		% Store the new assignments
		setuprop(h,'clflindx',newclflindx);
		DoChanFunctions('Unselect',h);
		DoChanFunctions('UpdateDisplay',h);
	end			% End of (~isempty(tnew))
	DoChanFunctions('SetCAxProp',h);
case 'UpdateDisplay'
	% Update the display
	haxc = getuprop(h,'haxc');
	t = getuprop(h,'t');
	scanrate = getuprop(h,'scanrate');
	hctext = getuprop(h,'hctext');
	clflindx = getuprop(h,'clflindx');
	nclust = size(clflindx,1);
	nfiles = size(clflindx,2);
	spikefiles = getuprop(h,'spikefiles');
	channel = getuprop(h,'channel');
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
		snips = LoadIndexSnippetsMF(spikefiles,'spike',channel,viewindx);
		%fprintf('i = %d, size(snips) = %d, %d\n',i,size(snips,1),size(snips,2));
		%viewindx{1}
		%viewindx{2}
		if (~isempty(snips))
			plot(snips);
		else
			cla
		end
		set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
		axis tight
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
			bar(xc,nPerBin,1,'k');
			axis tight
			ylim = get(gca,'YLim');
			if (ylim(1) < 0)
				ylim(1) = 0;		% When AC plot is empty, make sure limits chosen OK
				set(gca,'YLim',ylim);
			end
		%else
		%	cla
		%end
		set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
		haxc(2,i) = gca;
		% Update the text below each cluster plot
		params = getuprop(h,'params');
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
	rectime = getuprop(h,'rectime');
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
		filters = getuprop(h,'DefaultFilters');
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
		filters = getuprop(h,'filters');
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
case 'Clear'
	% Delete current clusters and make all spikes unassigned
	nsnips = getuprop(h,'nsnips');
	range = [ones(1,length(nsnips));nsnips];
	indx = BuildIndexMF(range);
	setuprop(h,'clflindx',indx);
	% Unselect any selected clusters
	DoChanFunctions('Unselect',h);
	% Update display
	DoChanFunctions('UpdateDisplay',h);
case 'Delete'
	% Delete selected clusters
	selindx = GetSelClust(h);
	selindx = selindx(find(selindx > 1));	% Can't delete unassigned cluster
	clflindx = getuprop(h,'clflindx');
	clflindx(selindx,:) = [];
	nsnips = getuprop(h,'nsnips');
	clflindx(1,:) = RebuildUnassigned(clflindx,nsnips);
	setuprop(h,'clflindx',clflindx);
	DoChanFunctions('Unselect',h);
	DoChanFunctions('UpdateDisplay',h);
case 'Cancel'
	delete(h);
case 'Done'
	% Fill parameters with current values
	params = getuprop(h,'params');
	params.dispsnips = str2num(get(findobj(h,'Tag','DispNumSnips'),'String'));
	params.ACTime = str2num(get(findobj(h,'Tag','ACTime'),'String'));
	params.NSpikes = str2num(get(findobj(h,'Tag','NumSpikes'),'String'));
	params.NNoise = str2num(get(findobj(h,'Tag','NumNoise'),'String'));
	params.BlockSize = str2num(get(findobj(h,'Tag','BlockSize'),'String'));
	setuprop(h,'params',params);
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
haxc = getuprop(h,'haxc');
selindx = [];
for i = 1:size(haxc,2)
	if (strcmp(get(haxc(1,i),'Selected'),'on'))
		selindx(end+1) = i;
	end
end
if (nargout > 1)
	% Consolidate the snippets in the selected clusters into one unit
	clflindx = getuprop(h,'clflindx');
	nfiles = size(clflindx,2);
	wvindx = cell(1,nfiles);
	for i = 1:nfiles
		wvindx{i} = sort(cat(2,clflindx{selindx,i}));
	end
end
return

function uas = RebuildUnassigned(assindx,nsnips)
% Re-compute the unassigned group as the difference
% between the total and the assigned data
% First get the union of all assigned data
nclust = size(assindx,1);
nfiles = size(assindx,2);
wvindx = cell(1,nfiles);
nclust = size(assindx,1);
for i = 1:nfiles
	wvindx{i} = cat(2,assindx{2:nclust,i});
end
% Now the unassigned data
for i = 1:nfiles
	uas{i} = setdiff(1:nsnips(i),wvindx{i});
end
