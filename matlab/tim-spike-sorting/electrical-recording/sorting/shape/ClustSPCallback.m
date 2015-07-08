function ClustSPCallback(action,hfig)
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
	membership = ComputeMembership(x,y,polygons(selclust));
	indx = find(membership);
	AutoCorrFig(t(indx),0.05,'s');
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
otherwise
	error(['Do not recognize action ',action]);
end
