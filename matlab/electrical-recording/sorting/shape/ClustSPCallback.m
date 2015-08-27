function ClustSPCallback(action,hfig)
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
	membership = ComputeMembership(x,y,polygons(selclust));
	indx = find(membership);
	AutoCorrFig(t(indx),0.05,'s');
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
otherwise
	error(['Do not recognize action ',action]);
end
