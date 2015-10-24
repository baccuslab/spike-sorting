function ClusterFunctions(action,hfig)
global selWidth unselWidth
selWidth = 2;
unselWidth = 0.5;
mstyle = 's';
msize = 2;
if (nargin < 2)
	hfig = gcbf;
end
hmembership = findobj(hfig,'Tag','memberline');
delete(hmembership);
% Notes:
%	Figure contains a number of user properties with the following names:
%		clustnums:	the # assigned to each cluster (0 if unoccupied, otherwise identity)
%		polygons:	a cell array containing the vertices of all polygons
%		hlines:		handles to graphical repres. of polygons
%		x,y:		all data points
%		selectflag:	0 or 1 for each cluster
%		mode:		"density" or "scatter" plot
%		SelCb:		cluster selection callback string
%    polygons are coded by (usually) invisible lines in plots, with Tag=polygon
switch(action)
case 'DoPolygon'
	hax = gcbo;
	%mode = getappdata(hfig,'mode');
	% Prevent resizing of plot during polygon drawing
	xlm = get(hax,'XLimMode'); ylm = get(hax,'YLimMode');
	set(hax,'XLimMode','manual'); set(hax,'YLimMode','manual');
	% Tasks:
	%   Determine whether to replace the selected cluster,
	%     or start a new cluster.
	selection_type = get(hfig,'SelectionType');
	replace = 0;
	if (strcmp(selection_type,'alt'))
		replace = 1;
	end
	% Make sure only one cluster is selected if replacing
	selvec = getappdata(hfig,'selectflag');
	selclust = find(selvec);
	if (isempty(selclust) && replace == 1)
		errordlg('Must select a cluster to replace it','SelectionError','modal');
		return
	end
	if (length(selclust) > 1 && replace == 1)
		errordlg('Can only replace 1 cluster','SelectionError','modal');
		return;
	end
	% Load up on necessary data
	polygons = getappdata(hfig,'polygons');
	% If replacing, delete the old cluster
	if (replace == 1)
		oldpolygon = polygons{selclust};	% Remember it, in case user cancels during drawing
		DeleteClusts(hfig);
	end
	% Reset all selections 
	if (~replace)
		Unselect(hfig,selclust);
	end
	%   Disable cluster selection callbacks, so don't select while
	%   in the middle of forming a polygon
	DisableClusterSelCb(hfig);
	% Determine the new cluster number
	clustnums = getappdata(hfig,'clustnums');
	if (replace)
		clustnum = selclust;
	else
		clustnum = GetNextClust(clustnums);
	end
	%   Get selection polygon
% 	[pvx,pvy] = GetSelPolygon('go',GetClustCol(clustnum));
    [pvx, pvy] = GetNewPolygon(GetClustCol(clustnum));
	if (isempty(pvx) && replace == 1)
		pvx = oldpolygon.x;
		pvy = oldpolygon.y;
	end
	if (~isempty(pvx))
		%   Assign cluster number to selected points, and
		%   record polygon information and clustered pts
		polygons{clustnum}.x = pvx;
		polygons{clustnum}.y = pvy;
		setappdata(hfig,'polygons',polygons);
		clustnums(clustnum) = clustnum;
		setappdata(hfig,'clustnums',clustnums);
		% Plot the new polygon in an appropriate color
		PlotPolygons(hfig);
		% Leave this new cluster selected
		Select(hfig,clustnum);
	end
	if (ishandle(hfig))	% User might have hit cancel during polygon drawing
		%   Re-enable cluster selection callbacks
		EnableClusterSelCb(hfig);
		set(hax,'XLimMode',xlm); set(hax,'YLimMode',ylm);	% Restore previous state
	end
case 'DoBox'
	hax = gcbo;
	%mode = getappdata(hfig,'mode');
	% Prevent resizing of plot during polygon drawing
	xlm = get(hax,'XLimMode'); ylm = get(hax,'YLimMode');
	set(hax,'XLimMode','manual'); set(hax,'YLimMode','manual');
	% Tasks:
	%   Determine whether to replace the selected cluster,
	%     or start a new cluster.
	selection_type = get(hfig,'SelectionType');
	replace = 0;
	if (strcmp(selection_type,'alt'))
		replace = 1;
	end
	% Make sure only one cluster is selected if replacing
	selvec = getappdata(hfig,'selectflag');
	selclust = find(selvec);
	if (isempty(selclust) && replace == 1)
		errordlg('Must select a cluster to replace it','SelectionError','modal');
		return
	end
	if (length(selclust) > 1 && replace == 1)
		errordlg('Can only replace 1 cluster','SelectionError','modal');
		return;
	end
	% Load up on necessary data
	polygons = getappdata(hfig,'polygons');
	% If replacing, delete the old cluster
	if (replace == 1)
		oldpolygon = polygons{selclust};	% Remember it, in case user cancels during drawing
		DeleteClusts(hfig);
	end
	% Reset all selections 
	if (~replace)
		Unselect(hfig,selclust);
	end
	%   Disable cluster selection callbacks, so don't select while
	%   in the middle of forming a polygon
	DisableClusterSelCb(hfig);
	% Determine the new cluster number
	clustnums = getappdata(hfig,'clustnums');
	if (replace)
		clustnum = selclust;
	else
		clustnum = GetNextClust(clustnums);
	end
	%   Get selection box
	pos=get(gca,'Position');
	xl=get(gca,'xlim');
	xs=xl(2)-xl(1);
	yl=get(gca,'ylim');
	ys=yl(2)-yl(1);
	c=rbbox;
	corx(1)=xl(1)+(c(1)-pos(1))*xs/pos(3); %Box corners
	cory(1)=yl(1)+(c(2)-pos(2))*ys/pos(4);
	corx(2)=corx(1)+c(3)*xs/pos(3);
	cory(2)=cory(1)+c(4)*ys/pos(4);
	pvx(1)=corx(1);pvy(1)=cory(1);%Box as polygon
	pvx(2)=corx(1);pvy(2)=cory(2);
	pvx(3)=corx(2);pvy(3)=cory(2);
	pvx(4)=corx(2);pvy(4)=cory(1);
	pvx(5)=pvx(1);pvy(5)=pvy(1);
	polygons{clustnum}.x = pvx;
	polygons{clustnum}.y = pvy;
	%   Assign cluster number to selected points, and
	%   record polygon information and clustered pts
	polygons{clustnum}.x = pvx;
	polygons{clustnum}.y = pvy;
	setappdata(hfig,'polygons',polygons);
	clustnums(clustnum) = clustnum;
	setappdata(hfig,'clustnums',clustnums);
	% Plot the new polygon in an appropriate color
	PlotPolygons(hfig);
	% Leave this new cluster selected
	Select(hfig,clustnum);
	
	if (ishandle(hfig))	% User might have hit cancel during polygon drawing
		%   Re-enable cluster selection callbacks
		EnableClusterSelCb(hfig);
		set(hax,'XLimMode',xlm); set(hax,'YLimMode',ylm);	% Restore previous state		
	end
	
case 'SelectCluster'
	hclustline = gcbo;
	hax = get(hclustline,'Parent');
	selection_type = get(hfig,'SelectionType');
	append = 0;
	if (strcmp(selection_type,'extend'))
		append = 1;
	end
	% If not appending, de-select old selected cluster(s)
	if (~append)
		selvec = getappdata(hfig,'selectflag');
		selclust = find(selvec);
		Unselect(hfig,selclust);
	end
	% Select new cluster
	hlines = getappdata(hfig,'hlines');
	clustnum = find(hlines == hclustline);	% Figure out the corresponding cluster number
	Select(hfig,clustnum);
case 'ScatterPlot'
	hax = findobj(hfig,'Tag','ClustAx');
	axes(hax);
	setappdata(hfig,'mode','scatter');
	% First plot all the points
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	h = plot(x,y,'Color','k','LineStyle','none','Marker','.','MarkerSize',6,'HitTest','off');
	%set(h,'Color','k','LineStyle','none','Marker','.','MarkerSize',6,'HitTest','off');
	axis tight
	% Add a whitespace border
	[xl,yl] = addborder (xlim,ylim);
	xlim(xl); ylim(yl);
	if (get(findobj(hfig,'Tag','clustmode'),'Value') == 1)
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoPolygon');
	else
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoBox');
	end
	PlotPolygons(hfig);
	% Set button & slider states
	hbutton = findobj(hfig,'Tag','ScatDensButton');
	set(hbutton,'String','Density','Callback','ClusterFunctions DensityPlot');
	hslider = findobj(hfig,'Tag','Slider');
	set(hslider,'Visible','off');
	htext = findobj(hfig,'Tag','BinWidthText');
	set(htext,'Visible','off');
	hbutton = findobj(hfig,'Tag','ShowClustsButton');
	set(hbutton,'Visible','on');
case 'DensityPlot'
	hax = findobj(hfig,'Tag','ClustAx');
	axes(hax);
	setappdata(hfig,'mode','density');
	% Determine bin sizes
	hslider = findobj(hfig,'Tag','Slider');
	%STEVE 01/19/01 Added /10 because the bins were too big
	binsize = exp(get(hslider,'Value'))/10;
	rectx = get(hax,'XLim'); recty = get(hax,'YLim');
	nx = max(2,round((rectx(2)-rectx(1))/binsize));
	ny = max(2,round((recty(2)-recty(1))/binsize));
	% Generate & plot histogram
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	[n,xc,yc] = hist2d(x,y,[rectx recty],nx,ny);
	himage = imagesc(xc,yc,log(n+1)');
	set(gca,'YDir','normal');
	colormap(1-gray);
	axis([rectx recty]);
	set(himage,'HitTest','off');
	if (get(findobj(hfig,'Tag','clustmode'),'Value') == 1)
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoPolygon');
	else
		set(gca,'Tag','ClustAx','ButtonDownFcn','ClusterFunctions DoBox');
	end
	% Draw polygons
	PlotPolygons(hfig);
	% Set button states
	hbutton = findobj(hfig,'Tag','ScatDensButton');
	set(hbutton,'String','Scatter','Callback','ClusterFunctions ScatterPlot');
	set(hslider,'Visible','on');
	htext = findobj(hfig,'Tag','BinWidthText');
	set(htext,'Visible','on');
	hbutton = findobj(hfig,'Tag','ShowClustsButton');
	set(hbutton,'Visible','off');
case 'Replot'
	mode = getappdata(hfig,'mode');
	if (strcmp(mode,'scatter'))
		ClusterFunctions('ScatterPlot',hfig);
	else
		ClusterFunctions('DensityPlot',hfig);
	end
case 'ShowMembership'
	mode = getappdata(hfig,'mode');
	hax = findobj(hfig,'Tag','ClustAx');
	if (strcmp(mode,'density'))
		ClusterFunctions('ScatterPlot',hfig);
	end
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	polygons = getappdata(hfig,'polygons');
	indxs = ClusterMembers(ComputeMembership(x,y,polygons));
	for i = 1:length(indxs)
		clustcol = GetClustCol(i);
		line(x(indxs{i}),y(indxs{i}),'Marker','.','LineStyle','none','MarkerSize',12,'Color',clustcol,'Tag','memberline');
	end
case 'Clear'
	setappdata(hfig,'polygons',{});
	setappdata(hfig,'clustnums',[]);
	setappdata(hfig,'hlines',[]);
	setappdata(hfig,'selectflag',[]);
	if (strcmp(getappdata(hfig,'mode'),'density'))
		ClusterFunctions('DensityPlot',hfig);
	else
		ClusterFunctions('ScatterPlot',hfig);
	end
case 'Revert'
	setappdata(hfig,'polygons',getappdata(hfig,'polygons0'));
	clustnums = getappdata(hfig,'clustnums0');
	setappdata(hfig,'clustnums',clustnums);
	setappdata(hfig,'selectflag',zeros(size(clustnums)));
	if (strcmp(getappdata(hfig,'mode'),'density'))
		ClusterFunctions('DensityPlot',hfig);
	else
		ClusterFunctions('ScatterPlot',hfig);
	end
case 'Cancel'
	delete(hfig);
case 'Done'
	set(hfig,'UserData','done');
case 'KeyTrap'
	c = get(hfig,'CurrentCharacter');
	if (double(c) == 8)
		DeleteClusts(hfig);
	end
otherwise
	error(['Do not recognize action ',action]);
end
return

function Select(hfig,clustnum)
global selWidth
selvec = getappdata(hfig,'selectflag');
if (nargin < 2)
	clustnum = find(selvec);	% Will update graphical display for selected clusters
end
selvec(clustnum) = 1;
setappdata(hfig,'selectflag',selvec);
hlines = getappdata(hfig,'hlines');
hlines = hlines(clustnum);
set(hlines,'LineWidth',selWidth);
return

function Unselect(hfig,clustnum)
global unselWidth
selvec = getappdata(hfig,'selectflag');
if (nargin < 2)
	clustnum = find(selvec);	% Will unselect all clusters
end
selvec(clustnum) = 0;
setappdata(hfig,'selectflag',selvec);
hlines = getappdata(hfig,'hlines');
hlines = hlines(clustnum);
set(hlines,'LineWidth',unselWidth);
return

function DisableClusterSelCb(hfig)
hlines = getappdata(hfig,'hlines');
indx = ishandle(hlines);
set(hlines(indx),'ButtonDownFcn','');
set(hlines(indx),'HitTest','off');
return

function EnableClusterSelCb(hfig)
hlines = getappdata(hfig,'hlines');
SelCb = getappdata(hfig,'SelCb');
indx = ishandle(hlines);
set(hlines(indx),'ButtonDownFcn',SelCb);
set(hlines(indx),'HitTest','on');
return

function DeleteClusts(hfig)
selvec = getappdata(hfig,'selectflag');
selclust = find(selvec);
selvec(selclust) = 0;
setappdata(hfig,'selectflag',selvec);
clustnums = getappdata(hfig,'clustnums');
clustnums(selclust) = [];
setappdata(hfig,'clustnums',clustnums);
polygons = getappdata(hfig,'polygons');
for i = 1:length(selclust)
	polygons{selclust(i)} = [];
end
setappdata(hfig,'polygons',polygons);
hlines = getappdata(hfig,'hlines');
delete(hlines(selclust));
PlotPolygons(hfig);
return

% This version of GetNextClust fills in gaps for deleted clusters
%function clustnum = GetNextClust(clustnums)
%nznums = find(clustnums);
%maxn = max(nznums);
%if (isempty(maxn))
%	maxn = 0;
%end
%avail = setdiff(1:maxn,nznums);
%if (isempty(avail))
%	clustnum = maxn+1;
%else
%	clustnum = min(avail);
%end
%return

%function clustnum = GetNextClust(clustnums)
%firstclnum = getappdata(gcf,'firstclnum');
%if (isempty(firstclnum))
%	firstclnum = 1;
%end
%clustnum = length(clustnums)+firstclnum;

function clustnum = GetNextClust(clustnums)
clustnum = length(clustnums)+1;
return

function PlotPolygons(hfig)
clustnums = getappdata(hfig,'clustnums');
clustlabels = getappdata(hfig,'ClusterLabels');
polygons = getappdata(hfig,'polygons');
SelCb = getappdata(hfig,'SelCb');
hlines = getappdata(hfig,'hlines');
isnr = find(hlines);
ish = ishandle(hlines(isnr));
delete(hlines(isnr(ish)));
hlines = zeros(size(clustnums));
txth = findobj(hfig,'Type','text');
delete(txth);			% Get rid of cluster # markers
for i = 1:length(clustnums)
	if (clustnums(i) > 0)
		hlines(i) = line(polygons{clustnums(i)}.x,polygons{clustnums(i)}.y, ...
            'Color',GetClustCol(clustnums(i)),'ButtonDownFcn',SelCb);
		text(polygons{clustnums(i)}.x(1),polygons{clustnums(i)}.y(1), ...
            num2str(GetClustLabel(clustnums(i),clustlabels)));
	end
end
setappdata(hfig,'hlines',hlines);
Select(hfig)

function clustcol = GetClustCol(clustnum)
%co = get(hax,'ColorOrder');
co = [0 0 1;0 0.65 0;1 0 0;0 0.75 0.75; 0.75 0 0.75; 0.7 0.7 0;0.5 0.5 0.5];
clustcol = co(mod(clustnum-1,size(co,1))+1,:);
return

function clustmembers = ClusterMembers(membership)
maxnum = max(membership);
clustmembers = cell(maxnum);
for i = 1:maxnum
	clustmembers{i} = find(membership == i);
end
