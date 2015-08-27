function MultiCluster(hax,polygons,clustnums)
% Cluster: Draw polygons around clusters in a scatter plot
% fig = Cluster(x,y)
%	x,y are the coordinates of the points
%	fig is the handle of the figure
%  Check to see if the figure's UserData has been set to "done"
%	(using waitfor) to use the results from clustering.
%  The polygons are stored in the figure's user property named "polygons,"
%	and cluster membership may be computed using the function ComputeMembership
%
% fig = Cluster(x,y,polygons,clustnums)
%	This form allows you to start with an initial set of polygons & cluster #s.
%	If polygons is present but clustnums is absent, default cluster numbers
%	are assigned. The "Clear" button is replaced by a "Revert" button,
%	restoring the original state.
hfig=gcf;
xall=getappdata(hfig,'xall');
yall=getappdata(hfig,'yall');
axh=getappdata(hfig,'axh');
rectx=getappdata(hfig,'rectx');
recty=getappdata(hfig,'recty');
ax=find(gca==axh);
size(xall)
x=xall{ax};y=yall{ax};
hfig=gcf;
set(hax,'Tag','ClustAx');
setappdata(hfig,'ax',ax)
setappdata(hfig,'x',x);
setappdata(hfig,'y',y);

if (nargin < 2)
	polygons = {};
	clustnums = [];
end
if (nargin == 2)
	clustnums = 1:length(polygons);
end

if (nargin == 3)
	set(h1,'String','Revert','Callback','MultiClusterFunctions Revert');
	setappdata(hfig,'clustnums0',clustnums);
	setappdata(hfig,'polygons0',polygons);
end


xrange = max(x)-min(x);
yrange = max(y)-min(y);
range = min(xrange,yrange);
if (range< 1)
	range = 1;
end

h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[153 7 113 15], ...
	'String','Bin width', ...
	'Style','text', ...
	'Tag','BinWidthText');

setappdata(hfig,'x',x);
setappdata(hfig,'y',y);
setappdata(hfig,'clustnums',clustnums);
setappdata(hfig,'polygons',polygons);
setappdata(hfig,'hpolygons',[]);
setappdata(hfig,'hclustpts',[]);
setappdata(hfig,'selectflag',[]);
setappdata(hfig,'membership',zeros(size(x)));
setappdata(hfig,'SelCb','MultiClusterFunctions SelectCluster');
MultiClusterFunctions('ScatterPlot',hfig);
	
