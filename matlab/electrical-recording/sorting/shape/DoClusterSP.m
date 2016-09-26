function polygons = DoClusterSP(x,y,t)
hfig = ClusterSpikeProj(x,y,t);
waitfor(hfig,'UserData','done');
polygons = {};
if (ishandle(hfig))
	polygons = getappdata(hfig,'polygons');
	close(hfig)
end
