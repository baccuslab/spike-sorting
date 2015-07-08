function ClustSWCallback(action,hfig)
if (nargin == 1)
	hfig = gcbf;
end
switch(action)
case 'AutoCorr'
	selvec = getuprop(hfig,'selectflag');
	selclust = find(selvec);
	polygons = getuprop(hfig,'polygons');
	x = getuprop(hfig,'x');
	y = getuprop(hfig,'y');
	t = getuprop(hfig,'t');
	f = getuprop(hfig,'f');
	membership = ComputeMembership(x,y,polygons(selclust));
	indx = find(membership);
	for i = 1:length(t)
		findx = find(f(1,indx) == i);	% Find the subset in a given file
		tsub{i} = t{i}(f(2,indx(findx)));	% Pull out the times for this file
	end
	if (length(indx) > 0)
		AutoCorrFig(tsub,0.01,'s');
	else
		errordlg('Must select one or more clusters first');
	end
case 'Revert'
	%hax = findobj(hfig,'Tag','ClustAx');
	%axes(hax);
	%cla
	%set(gca,'Tag','ClustAx');
	setuprop(hfig,'polygons',getuprop(hfig,'polygons0'));
	clustnums = getuprop(hfig,'clustnums0');
	setuprop(hfig,'clustnums',clustnums);
	%setuprop(hfig,'hlines',[]);
	setuprop(hfig,'selectflag',zeros(size(clustnums)));
	if (strcmp(getuprop(hfig,'mode'),'density'))
		ClusterFunctions('DensityPlot',hfig);
	else
		ClusterFunctions('ScatterPlot',hfig);
	end
case 'Waveforms'
	spikefiles=getuprop(gcf,'spikefiles');
	ctfiles=getuprop(gcf,'ctfiles');
	channels=getuprop(gcf,'channels');
	snipindx=getuprop(gcf,'snipindx');
	multiindx=getuprop(gcf,'multiindx');
	f =getuprop(hfig,'f');
	wvfig = findobj(0,'Tag','WaveformSelectFig');
	if (isempty(wvfig) | ~ishandle(wvfig))
		wvfig = figure;
	end
	setuprop(wvfig,'ctfiles',ctfiles);
	setuprop(wvfig,'spikefiles',spikefiles);
	setuprop(wvfig,'channels',channels);
	setuprop(wvfig,'snipindx',snipindx);
	setuprop(wvfig,'multiindx',multiindx);
	%set(wvfig,'KeyPressFcn','');
	cla
	x = getuprop(hfig,'x');
	y = getuprop(hfig,'y');
	setuprop(wvfig,'x',x);
	setuprop(wvfig,'y',y);
	setuprop(wvfig,'f',f);
	plot (x,y,'r.','HitTest','off');
	set(gca,'ButtonDownFcn','ClustSWCallback ShowWaveform')
case 'ShowWaveform'
	xyloc = get(gca,'CurrentPoint');
	ploc = get(0,'PointerLocation');
	h = 100; w = 180;
	figure('Position',[ploc(1),ploc(2)-h-10,w,h],'Resize','off');
	udata = get(gcbo,'UserData');
	x = getuprop(hfig,'x');
	y = getuprop(hfig,'y');
	f = getuprop(hfig,'f');
	d1=x-xyloc(1,1);
	d2=y-xyloc(1,2);
	pdist=d1.*d1+d2.*d2;
	snidx=f(:,find (pdist==min(pdist)));
	ctfiles=getuprop(gcbf,'ctfiles');
	spikefiles=getuprop(gcbf,'spikefiles');
	channels=getuprop(gcbf,'channels');
	snipindx=getuprop(gcbf,'snipindx');
	multiindx=getuprop(gcbf,'multiindx');
	fnum=snidx(1);
	snip = MultiLoadIndexSnippetsMF(spikefiles(fnum),ctfiles(fnum),channels,{snipindx{fnum}(snidx(2))},multiindx(fnum));
	plot(snip);
case 'Clustmodebox'
	if (get(findobj(hfig,'Tag','clustmode'),'Value') == 1)
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoPolygon');
	else
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoBox');
	end
	getuprop(hfig,'hsort')
	get(findobj(hfig,'Tag','clustmode'),'Value')
	setuprop (getuprop(hfig,'hsort'),'clustmode',get(findobj(hfig,'Tag','clustmode'),'Value'));
otherwise
	error(['Do not recognize action ',action]);
end
