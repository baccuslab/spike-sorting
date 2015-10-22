function AutoCorrFigCallback(action,cbo,hfig)
if (nargin < 2)
	cbo = gcbo;
	hfig = gcbf;
end
switch(action)
case 'replot'
	hedit = cbo;
	trange = str2num(get(hedit,'String'));
	t = getappdata(hfig,'t');
	hax = findobj(hfig,'Tag','ACAxes');
	set(hax,'Units','pixels');
	pos = get(hax,'Position');
	npix = pos(2);
	nbins = ceil(npix/2);
	n = AutoCorrRec(t,trange,nbins);
	binwidth = trange/nbins;
	x = linspace(binwidth/2,trange-binwidth/2,nbins);
	axes(hax);
	xlabelstr = get(get(gca,'XLabel'),'String');
	ylabelstr = get(get(gca,'YLabel'),'String');
	bar(x,n,'k');
	%shading flat
	set(gca,'Tag','ACAxes','XLim',[0 trange])
	xlabel(xlabelstr);
	ylabel(ylabelstr);
otherwise
	error(['Do not know how to do action ',action]);
end
