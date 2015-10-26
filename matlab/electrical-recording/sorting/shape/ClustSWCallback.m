function ClustSWCallback(action,hfig)
if (nargin == 1)
	hfig = gcbf;
end
switch(action)
case 'AutoCorr'
	selvec = getappdata(hfig,'selectflag');
	selclust = find(selvec);
	polygons = getappdata(hfig,'polygons');
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	t = getappdata(hfig,'t');
	f = getappdata(hfig,'f');
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
	setappdata(hfig,'polygons',getappdata(hfig,'polygons0'));
	clustnums = getappdata(hfig,'clustnums0');
	setappdata(hfig,'clustnums',clustnums);
	%setappdata(hfig,'hlines',[]);
	setappdata(hfig,'selectflag',zeros(size(clustnums)));
	if (strcmp(getappdata(hfig,'mode'),'density'))
		ClusterFunctions('DensityPlot',hfig);
	else
		ClusterFunctions('ScatterPlot',hfig);
	end
case 'Waveforms'
% 	spikefiles=getappdata(gcf,'spikefiles');
    snipfiles = getappdata(gcf, 'snipfiles');
	ctfiles=getappdata(gcf,'ctfiles');
	channels=getappdata(gcf,'channels');
	snipindx=getappdata(gcf,'snipindx');
	multiindx=getappdata(gcf,'multiindx');
	f =getappdata(hfig,'f');
	wvfig = findobj(0,'Tag','WaveformSelectFig');
	if (isempty(wvfig) | ~ishandle(wvfig))
		wvfig = figure;
	end
	setappdata(wvfig,'ctfiles',ctfiles);
% 	setappdata(wvfig,'spikefiles',spikefiles);
    setappdata(wvfig, 'snipfiles', snipfiles);
	setappdata(wvfig,'channels',channels);
	setappdata(wvfig,'snipindx',snipindx);
	setappdata(wvfig,'multiindx',multiindx);
	%set(wvfig,'KeyPressFcn','');
	cla
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	setappdata(wvfig,'x',x);
	setappdata(wvfig,'y',y);
	setappdata(wvfig,'f',f);
	plot (x,y,'r.','HitTest','off');
	set(gca,'ButtonDownFcn','ClustSWCallback ShowWaveform')
case 'ShowWaveform'
	xyloc = get(gca,'CurrentPoint');
	ploc = get(0,'PointerLocation');
	h = 100; w = 180;
	figure('Position',[ploc(1),ploc(2)-h-10,w,h],'Resize','off');
	udata = get(gcbo,'UserData');
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	f = getappdata(hfig,'f');
	d1=x-xyloc(1,1);
	d2=y-xyloc(1,2);
	pdist=d1.*d1+d2.*d2;
	snidx=f(:,find (pdist==min(pdist)));
	ctfiles=getappdata(gcbf,'ctfiles');
% 	spikefiles=getappdata(gcbf,'spikefiles');
    snipfiles = getappdata(gcbf, 'snipfiles');
	channels=getappdata(gcbf,'channels');
	snipindx=getappdata(gcbf,'snipindx');
	multiindx=getappdata(gcbf,'multiindx');
	fnum=snidx(1);
% 	snip = MultiLoadIndexSnippetsMF(spikefiles(fnum),ctfiles(fnum),channels,{snipindx{fnum}(snidx(2))},multiindx(fnum));
    snip = MultiLoadIndexSnippetsMF(snipfiles(fnum), 'spike', ...
        ctfiles(fnum), channels, {snipindx{fnum}(snidx(2))}, multiindx(fnum));
	plot(snip);
case 'Clustmodebox'
	if (get(findobj(hfig,'Tag','clustmode'),'Value') == 1)
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoPolygon');
	else
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoBox');
	end
	getappdata(hfig,'hsort')
	get(findobj(hfig,'Tag','clustmode'),'Value')
	setappdata (getappdata(hfig,'hsort'),'clustmode',get(findobj(hfig,'Tag','clustmode'),'Value'));
otherwise
	error(['Do not recognize action ',action]);
end
