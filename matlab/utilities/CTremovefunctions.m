function CTremovefunctions(action,h)
if (nargin == 1)
	h = gcbf;
end
switch(action)
case 'SetCAxProp'
	haxc = getappdata(h,'haxc');
	axcol = [0.6 0.6 0.6];
	set(haxc,'Tag','ClustAxes', ...
		'Box','off',...
		'XColor',axcol,'YColor',axcol,...
		'ButtonDownFcn','CTremovefunctions SelectPair',...
		'XTickMode','manual','XTick',[],...
		'YTickMode','manual','YTick',[]);
	% See if there is anything plotted in these axes
	len = size(haxc,1)*size(haxc,2);
	killMode = getappdata(h,'KillMode');
	for i = 1:len
		hc = get(haxc(i),'Children');
		if (length(hc) > 0 & ~killMode)
			set(haxc(i),'HitTest','on');
			set(hc,'HitTest','off');
		else
			set(haxc(i),'HitTest','off');
		end
	end
case 'SelectPair'
	haxc = getappdata(h,'haxc');
	% First turn off all other selections
	hsel = findobj(haxc,'Selected','on');
	set(hsel,'Selected','off');
	% Now find the companion axis to the callback axis
	[clicki,clickj] = find(haxc == gcbo);
	set(haxc(1:2,clickj),'Selected','on');	% Select them
	%set(findobj(h,'Tag','BuildFiltersButton'),'Enable','on');
	set(findobj(h,'Tag','ClusterButton'),'Enable','on');
case 'Unselect'
	haxc = getappdata(h,'haxc');
	% Turn off all selections
	hsel = findobj(haxc,'Selected','on');
	set(hsel,'Selected','off');
	%set(findobj(h,'Tag','BuildFiltersButton'),'Enable','off');
	set(findobj(h,'Tag','ClusterButton'),'Enable','off');
case 'Cluster'
	% Much of this code is stolen from GroupChannel
	% Could I unify this?
	% Determine which pair is selected
	plotselpair = GetSelPair(h);
	% Get peaks, times data
	peakx = getappdata(h,'plotpeakx');
	peaky = getappdata(h,'plotpeaky');
	plotpair = getappdata(h,'plotpair');
	plotindx = getappdata(h,'plotindx');
	time = getappdata(h,'time');	% This has all the timing data
	peak = getappdata(h,'peak');
	nfiles = size(time,2);
	channels = getappdata(h,'channels');
	% Get info on past clustering
	pairdef = getappdata(h,'pairdef');
	pairtime = getappdata(h,'pairtime');
	% Get the data from the edit boxes
	blocksize = str2num(get(findobj(h,'Tag','BlockSize'),'String'));
	tsimult = str2num(get(findobj(h,'Tag','TSimult'),'String'));
	tplot = str2num(get(findobj(h,'Tag','TPlot'),'String'));
	% Loop over blocks
	polygons = {};
	clustnums = [];
	useclnums = size	(pairdef,1)+1;	% Start at next cell #
	npts = length(peakx{plotselpair});
	nblocks = ceil(npts/blocksize);
	mode = 'scatter';
	selclust = {};
	for i = 1:nblocks
		range = [(i-1)*blocksize+1,min([i*blocksize,npts])];
		hfig = Cluster(peakx{plotselpair}(range(1):range(2)),peaky{plotselpair}(range(1):range(2)),polygons,clustnums);
		if (i < nblocks)
			set(findobj(gcf,'Tag','DoneButton'),'String','Next');
		end
		setappdata(hfig,'mode',mode);		% Use the same mode that finished with last time
		hslider = findobj(hfig,'Tag','Slider');
		slidermin = get(hslider,'Min');
		slidermax = get(hslider,'Max');
		if (i == 1)
			slidervalue = sqrt(slidermin*slidermax);
		end
		if (slidervalue < slidermin)
			slidervalue = slidermin;
		elseif (slidervalue > slidermax)
			slidervalue = slidermax;
		end
		set(hslider,'Value',slidervalue);
		setappdata(hfig,'ClusterLabels',useclnums);	% Set the sequence of cluster #s to print on screen
		ClusterFunctions('Replot',hfig);	% Plot in correct mode
		% Now wait for user input to finish
		waitfor(hfig,'UserData','done');
		if (~ishandle(hfig))
			warning('Operation cancelled by user');
			return
		end
		% Retrieve the information about the clusters
		clustnums = getappdata(hfig,'clustnums');
		polygons = getappdata(hfig,'polygons');
		x = getappdata(hfig,'x');
		y = getappdata(hfig,'y');
		mode = getappdata(hfig,'mode');
		slidervalue = get(hslider,'Value');
		close(hfig)
		% Determine which points fall in each polygon
		membership = ComputeMembership(x,y,polygons);
		% Sort out across clusters
		for j = 1:length(polygons)
			cindx = find(j == membership);
			if (length(selclust) >= j)
				selclust{j} = [selclust{j},cindx+range(1)-1];
			else
				selclust{j} = cindx+range(1)-1;
			end
		end
	end
	if (isempty(selclust))
		return;
	end
	% Sort clusters out across files
	fileident = getappdata(h,'plotf');
	for i = 1:length(selclust)
		for j = 1:nfiles
			findx = find(fileident{plotselpair}(1,selclust{i}) == j);
			selclustf{i,j} = fileident{plotselpair}(2,selclust{i}(findx));
		end
	end
	% Compute correlations of the selected cluster with all other electrodes
	tplot= str2num(get(findobj(h,'Tag','TPlot'),'String'));
	changed = 0;
	for i = 1:length(selclust)
		% Choose times of paired events from the one with
		% the largest average peak value
		avx = mean(peakx{plotselpair}(selclust{i}));
		avy = mean(peaky{plotselpair}(selclust{i}));
		if (avx > avy)
			bigindx = 1;
		else
			bigindx = 2;
		end
		smindx = 3-bigindx;
		bigchannum = plotpair(plotselpair,bigindx);
		smchannum = plotpair(plotselpair,smindx);
		for j = 1:nfiles
			thetime{j} = time{bigchannum,j}(plotindx{plotselpair}{j}(bigindx,selclustf{i,j}));
			smtime{j} = time{smchannum,j}(plotindx{plotselpair}{j}(smindx,selclustf{i,j}));
		end
		% Compute correlations with other electrodes
		therest = setdiff(1:size(time,1),plotpair(plotselpair,:));
		[cpdf,pairccindx,npb] = CrossCorrAllOne(time(therest,:),thetime,tplot);
		% Set up cross-corr GUI
		%    Compute cross-correlation of the selected cluster
		npbclust = CrossCorrRec(thetime,smtime,tplot,300);
		nbins = 2*ceil(sum(npbclust)^(1/2)/2) + 1;
		npbclust = rehist(npbclust,nbins);
		hctfig = CTGUI('Start',npbclust,peakx{plotselpair}(selclust{i}),peaky{plotselpair}(selclust{i}),npb,channels(therest(pairccindx)),cpdf,channels(plotpair(plotselpair,:)),tplot);
		% Display autocorrelation of this cell
		AutoCorrFig(thetime,0.1,'s');
		% Wait for user settings
		waitfor(hctfig,'UserData','done');
		if (ishandle(hctfig))	% if user didn't hit cancel
			changed = 1;
			% Read the choices & determine which snippets to kill
			hshapebox = findobj(hctfig,'Tag','ShapeSort');
			defining = 1 - get(hshapebox,'Value');
			for j = 1:nfiles
				killindx{smchannum,j} = plotindx{plotselpair}{j}(smindx,selclustf{i,j});
				if (defining)
					killindx{bigchannum,j} = plotindx{plotselpair}{j}(bigindx,selclustf{i,j});
				end
			end
			hctboxon = findobj(hctfig,'Tag','KillCT','Value',1);
			for k = 1:length(hctboxon)
				channum = get(hctboxon(k),'UserData');
				[tcc,tccindx] = CrossCorrRec(thetime,time(channum,:),tsimult);
				for k1 = 1:nfiles
					killindx{channum,k1} = tccindx{k1}(2,:);
				end
			end
			% Kill the cross-talk
			for j = 1:size(killindx,1)
				for k = 1:size(killindx,2)
					if (length(killindx{j,k} > 0))
						time{j,k}(killindx{j,k}) = [];
						peak{j,k}(killindx{j,k}) = [];
					end
				end
			end
			% "Save" the cell definition, if appropriate
			if (defining)
				pairdef(end+1,:) = plotpair(plotselpair,:);
				pairtime(end+1,:) = thetime;
			end
			close(hctfig);
		end
	end
	if (changed)
		% "Save" the new data in the figure
		setappdata(h,'time',time);
		setappdata(h,'peak',peak);
		setappdata(h,'pairdef',pairdef);
		setappdata(h,'pairtime',pairtime);
		% Write the cell definitions and remaining snippet times
		% to disk
		cdefname = getappdata(h,'CellDefFile');
		spikefiles = getappdata(h,'SpikeFiles');
		save(cdefname,'pairdef','pairtime','time','spikefiles','channels');
		% Recalculate
		CTremovefunctions('RecalculatePairs',h);
		CTremovefunctions('UpdateDisplay',h);
	end
case 'UpdateDisplay'
	% Determine the range and the prev/next button status
	showRange = getappdata(h,'ShowRange');
	hprevbutton = findobj(h,'Tag','PrevButton');
	hstartbutton = findobj(h,'Tag','StartButton');
	if (showRange(1) == 1)
		set(hprevbutton,'Enable','off');
		set(hstartbutton,'Enable','off');
	else
		set(hprevbutton,'Enable','on');
		set(hstartbutton,'Enable','on');
	end
	hnextbutton = findobj(h,'Tag','NextButton');
	npb = getappdata(h,'npb');
	if (showRange(2) >= length(npb))
		set(hnextbutton,'Enable','off');
	else
		set(hnextbutton,'Enable','on');
	end
	% Update page info
	hpagetext = findobj(h,'Tag','PageText');
	npages = ceil(length(npb)/16);
	pagenum = showRange(2)/16;
	set(hpagetext,'String',sprintf('%d/%d',pagenum,npages));
	% Calculate peaks data
	RecalculateRange(h,showRange);
	npb = getappdata(h,'plotnpb');	% Now just get the ones we're showing
	haxc = getappdata(h,'haxc');
	pair = getappdata(h,'plotpair');
	indx = getappdata(h,'plotindx');
	hctext = getappdata(h,'hctext');
	x = getappdata(h,'plotpeakx');
	y = getappdata(h,'plotpeaky');
	channel = getappdata(h,'channels');
	killMode = getappdata(h,'KillMode');
	if (killMode)
		ratio = str2num(get(findobj(h,'Tag','Ratio'),'String'));
		offset = str2num(get(findobj(h,'Tag','Offset'),'String'));
		hKillCB = getappdata(h,'hKillCB');
		killflag = getappdata(h,'KillPair');
	end
	tplot = str2num(get(findobj(h,'Tag','TPlot'),'String'));
	tsimult = str2num(get(findobj(h,'Tag','TSimult'),'String'));
	for i = 1:length(npb)
		% First the cross-correlation display
		axes(haxc(1,i));
		nbins = length(npb{i});
		binwidth = 2*tplot/nbins;
		xax = linspace(-tplot+binwidth/2,tplot-binwidth/2,nbins);
		bar(xax,npb{i},1,'k');
		ylim = get(gca,'YLim');
		line([tsimult tsimult],ylim,'LineStyle',':','Color','r');
		line(-[tsimult tsimult],ylim,'LineStyle',':','Color','r');
		set(gca,'XLim',[-tplot,tplot]);
		set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
		haxc(1,i) = gca;
		% Then the peak-vs-peak display
		axes(haxc(2,i));
		if (isempty(x{i}))
			cla
		else
			plot(x{i},y{i},'.k');
		end
		set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
		xlim = get(gca,'XLim'); set(gca,'XLim',[0 max([xlim(2),eps])]);
		ylim = get(gca,'YLim'); set(gca,'YLim',[0 max([ylim(2),eps])]);
		if (killMode)
			ulim = min([xlim(2),(ylim(2)+offset)*ratio]);
			line([offset*ratio,ulim],[0,ulim/ratio-offset],'Color','b','LineStyle',':');
			ulim = min([ylim(2),(xlim(2)+offset)*ratio]);
			line([0,ulim/ratio-offset],[offset*ratio,ulim],'Color','b','LineStyle',':');
		end
		haxc(2,i) = gca;
		% Now the text
		set(hctext(i),'String',sprintf('%d vs %d: %d',channel(pair(i,1)),channel(pair(i,2)),round(sum(npb{i}))));
		% Do the checkboxes, if in kill mode
		if (killMode)
			set(hKillCB(i),'Value',killflag(showRange(1)-1+i));
		end
	end
	% Clear any display on old axes
	for i = length(npb)+1:size(haxc,2)
		axes(haxc(1,i))
		cla
		axes(haxc(2,i))
		cla
		set(hctext(i),'String','');
	end
	% Reset the GUI properties
	CTremovefunctions('SetCAxProp',h);
case 'KillMode'
	% Set KillMode flag
	setappdata(h,'KillMode',1);
	% Unselect all pairs
	CTremovefunctions('Unselect',h);
	% Replace Cluster buttons & parameters with Kill button & parameters
	hbutton = findobj(h,'Tag','ClusterButton');
	set(hbutton,'String','Kill','Enable','on','Callback','CTremovefunctions Kill','Tag','KillButton');
	htext = findobj(h,'Tag','BlockSizeText');
	set(htext,'String','ratio','Tag','RatioText');
	hedit = findobj(h,'Tag','BlockSize');
	params = getappdata(h,'params');
	set(hedit,'Tag','Ratio','String',num2str(params.KillRatio),'Callback','CTremovefunctions EditKillRatio');
	% Insert the offset edit box
	h1 = uicontrol('HorizontalAlignment','left', ...
		'Position',[130 40 50 20], ...
		'String','offset', ...
		'Style','text', ...
		'Tag','OffsetText');
	h1 = uicontrol('BackgroundColor',[1 1 1], ...
		'Position',[190 43 61 21], ...
		'String',num2str(params.Offset), ...
		'HorizontalAlignment','right', ...
		'Style','edit', ...
		'Callback','CTremovefunctions UpdateDisplay',...
		'Tag','Offset');
	% Delete self
	delete(gcbo)
	% Set up data for checkboxes, and place them in the figure
	cpdf = getappdata(h,'cpdf');
	killpair = (cpdf > 5);		% Kill only those pairs with sizeable CT
	setappdata(h,'KillPair',killpair);
	hctext = getappdata(h,'hctext');
	for i = 1:length(hctext)
		pos = get(hctext(i),'Position');
		hkillflag(i) =  uicontrol('Position',pos-[-5 15 0 0], ...
					'String','Kill crosstalk', ...
					'Style','checkbox', ...
					'Value',0,...
					'UserData',i, ...
					'Tag','KillCT');
	end
	setappdata(h,'hKillCB',hkillflag);			
	CTremovefunctions('UpdateDisplay',h);
case 'Kill'
	tsimult = str2num(get(findobj(h,'Tag','TSimult'),'String'));
	ratio = str2num(get(findobj(h,'Tag','Ratio'),'String'));
	offset = str2num(get(findobj(h,'Tag','Offset'),'String'));
	time = getappdata(h,'time');
	peak = getappdata(h,'peak');
	pair = getappdata(h,'pair');
	npbAll = getappdata(h,'npb');
	channels = getappdata(h,'channels');
	killpair = getappdata(h,'KillPair');
	killpair = find(killpair);
	killindx = cell(size(time));
	for i = 1:length(killpair)
		c = pair(killpair(i),:);	% Channel indices to work with
		[tcc,indx] = CrossCorrRec(time(c(1),:),time(c(2),:),tsimult);
		for j = 1:length(indx)
			if (max(indx{j}(1,:)) > length(peak{c(1),j}))
				fprintf('i %d, j %d: max(indx) = %d, length(peak) = %d,length(time) = %d\n',i,j,max(indx{j}(1,:)),length(peak{c(1),j}),length(time{c(1),j}));
			end
			xtemp = peak{c(1),j}(indx{j}(1,:));
			ytemp = peak{c(2),j}(indx{j}(2,:));
			xkill = find((xtemp+offset)./(ytemp+eps) < 1/ratio);
			ykill = find((ytemp+offset)./(xtemp+eps) < 1/ratio);
			killindx{c(1),j}(indx{j}(1,xkill)) = 1;
			killindx{c(2),j}(indx{j}(2,ykill)) = 1;
		end
	end
	totkill = 0;
	totspikes = 0;
	for i = 1:size(killindx,1)
		for j = 1:size(killindx,2)
			indx = find(killindx{i,j});
			%fprintf('Killing %d entries from i,j = %d,%d.\n',length(indx),i,j);
			totkill = totkill+length(indx);
			totspikes = totspikes+length(time{i,j});
			if (~isempty(indx))
				time{i,j}(indx) = [];
				peak{i,j}(indx) = [];
			end
		end
	end
	fprintf('Killed a fraction %g of the total spikes on all channels\n',totkill/totspikes);
	setappdata(h,'time',time);
	setappdata(h,'peak',peak);
	CTremovefunctions('RecalculatePairs',h);
	% Reset check boxes
	cpdf = getappdata(h,'cpdf');
	killpair = (cpdf > 5);		% Kill only those pairs with sizeable CT
	setappdata(h,'KillPair',killpair);
	% Move range back to beginning
	setappdata(h,'ShowRange',[1 16]);
	CTremovefunctions('UpdateDisplay',h);
case 'EditKillRatio'
	hedit = findobj(h,'Tag','Ratio');
	ratio = str2num(get(hedit,'String'));
	if (ratio < 1)
		set(hedit,'String',num2str(1));
	end
	CTremovefunctions('UpdateDisplay',h);
case 'Prev'
	MoveRange(h,-16);
case 'Next'
	MoveRange(h,16);
case 'Start'
	showRange = getappdata(h,'ShowRange');
	MoveRange(h,-showRange(1)+1);
case 'RecalculatePairs'
	tplot = str2num(get(findobj(h,'Tag','TPlot'),'String'));
	time = getappdata(h,'time');
	fracspikes = getappdata(h,'fracspikes');
	for i = 1:size(time,1)
		for j = 1:size(time,2)
			subtime{i,j} = time{i,j}(1:ceil(fracspikes)*length(time{i,j}));
		end
	end
	[cpdf,pair,npb] = CrossCorrAll(subtime,tplot);
	setappdata(h,'pair',pair);
	setappdata(h,'npb',npb);
	setappdata(h,'cpdf',cpdf);
case 'Cancel'
	delete(h);
case 'Done'
	% Signal other code using waitfor that we're done
	% The relevant data can be extracted
	killMode = getappdata(h,'KillMode');
	if (killMode)
		pairdef = getappdata(h,'pairdef');
		pairtime = getappdata(h,'pairtime');
		time = getappdata(h,'time');
		cdefname = getappdata(h,'CellDefFile');
		spikefiles = getappdata(h,'SpikeFiles');
		channels = getappdata(h,'channels');
		save(cdefname,'pairdef','pairtime','time','spikefiles','channels');
	end
	set(h,'UserData','done');
	close(h);		% Comment this line out if this is being called from another GUI
case 'KeyTrap'
	c = get(h,'CurrentCharacter');
	%if (double(c) == 8)	% Delete key
	%	CTremovefunctions('Delete',h);
	%end
otherwise
	error(['Do not recognize action ',action]);
end

function RecalculateRange(h,range)
% Determine which events come within tsimult of each other,
% for the pairs of cell/channels specified by pair(:,range(1):range(2))
tsimult = str2num(get(findobj(h,'Tag','TSimult'),'String'));
time = getappdata(h,'time');
pair = getappdata(h,'pair');
npbAll = getappdata(h,'npb');
iend = min(range(2),size(pair,1));
for i = range(1):iend
	[tcc,indx] = CrossCorrRec(time(pair(i,1),:),time(pair(i,2),:),tsimult);
	j = i-range(1)+1;
	plotnpb{j} = npbAll{i};
	plotindx{j} = indx;
	plotpair(j,:) = pair(i,:);
end
setappdata(h,'plotnpb',plotnpb);
setappdata(h,'plotindx',plotindx);
setappdata(h,'plotpair',plotpair);
% Calculate the necessary info for peak-vs-peak plots
%clear time	% Try to make some room!
peak = getappdata(h,'peak');
%fprintf('length(plotnpb) = %d\n',length(plotnpb));
for i = 1:length(plotnpb)
	%fprintf('length(plotindx{%d}) = %d\n',i,length(plotindx{i}));
	for j = 1:length(plotindx{i})
		sz = size(plotindx{i}{j});
		%fprintf('size(plotindx{%d}{%d}) = %d %d\n',i,j,sz(1),sz(2));
		xtemp{j} = peak{plotpair(i,1),j}(plotindx{i}{j}(1,:));
		ytemp{j} = peak{plotpair(i,2),j}(plotindx{i}{j}(2,:));
		nentries = size(plotindx{i}{j},2);
		%fprintf('nentries = %d\n',nentries);
		ftemp{j} = [j*ones(1,nentries);1:nentries];
	end
	x{i} = cat(2,xtemp{:});
	y{i} = cat(2,ytemp{:});
	f{i} = cat(2,ftemp{:});
end
setappdata(h,'plotpeakx',x);
setappdata(h,'plotpeaky',y);
setappdata(h,'plotf',f);
return

function MoveRange(h,dr)
showRange = getappdata(h,'ShowRange');
killMode = getappdata(h,'KillMode');
if (killMode)		% Update killpair info from check boxes
	hkillcb = getappdata(h,'hKillCB');
	killpair = getappdata(h,'KillPair');
	val = get(hkillcb,'Value');
	for i = 1:length(val)
		killpair(i+showRange(1)-1) = val{i};
	end
	setappdata(h,'KillPair',killpair);
end
showRange = showRange + dr;
setappdata(h,'ShowRange',showRange);
CTremovefunctions('UpdateDisplay',h);
return

function plotselindx = GetSelPair(h)
haxc = getappdata(h,'haxc');
plotselindx = [];
for i = 1:size(haxc,2)
	if (strcmp(get(haxc(1,i),'Selected'),'on'))
		plotselindx(end+1) = i;
	end
end
return
