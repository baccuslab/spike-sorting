function SliderWindowCB(action,hfig)
if (nargin < 2)
	hfig = gcbf;
end
switch(action)
case 'PlotTop'
	hselrect = findobj(hfig,'Tag','HSelRect');
	xd = get(hselrect,'XData');
	yd = get(hselrect,'YData');
	xlim = [min(xd) max(xd)];
	ylim = [min(yd) max(yd)];
	haxupd = getappdata(hfig,'UpdAx');
	set(haxupd,'XLim',xlim);
	set(haxupd(1),'YLim',ylim);	% Only adjust y scaling on the chosen axis
% The next 3 allow dragging the viewing rectangle
case 'Slide'
	set(hfig,'WindowButtonMotionFcn','SliderWindowCB Move');
	set(hfig,'WindowButtonUpFcn','SliderWindowCB Stop');
case 'Move'
	currPt = get(gca,'CurrentPoint');
	hrect = findobj(hfig,'Tag','HSelRect');
	xd = get(hrect,'XData');
	xlimrect = [min(xd) max(xd)];
	% Make sure stay in bounds
	xlimabs = get(gca,'XLim');
	width = min(xlimrect(2)-xlimrect(1),xlimabs(2)-xlimabs(1));
	x = max(currPt(1,1),xlimabs(1));
	x = min(x,xlimabs(2)-width);
	xd = [0 width width 0 0] + x;
	set(hrect,'XData',xd);
	seltype = get(hfig,'SelectionType');
	if (~strcmp(seltype,'extend'))
		yd = get(hrect,'YData');
		ylimrect = [min(yd) max(yd)];
		% Make sure stay in bounds
		ylimabs = get(gca,'YLim');
		height = min(ylimrect(2)-ylimrect(1),ylimabs(2)-ylimabs(1));
		y = max(currPt(1,2),ylimabs(1));
		y = min(y,ylimabs(2)-height);
		yd = [0 0 height height 0] + y;
		set(hrect,'YData',yd);
	end
case 'Stop'
	set(hfig,'WindowButtonMotionFcn','');
	set(hfig,'WindowButtonUpFcn','');
	SliderWindowCB('PlotTop',hfig);
case 'Select'
	hselrect = findobj(hfig,'Tag','HSelRect');
	theRect = GetSelRect;
	xlim = get(gca,'XLim');
	theRect(1) = max(theRect(1),xlim(1));
	theRect(3) = min(theRect(3),xlim(2)-theRect(1));
	xd = [0 theRect(3) theRect(3) 0 0] + theRect(1);
	set(hselrect,'XData',xd);
	seltype = get(hfig,'SelectionType');
	if (~strcmp(seltype,'extend'))
		ylim = get(gca,'YLim');
		theRect(2) = max(theRect(2),ylim(1));
		theRect(4) = min(theRect(4),ylim(2)-theRect(2));
		yd = [0 0 theRect(4) theRect(4) 0] + theRect(2);
		set(hselrect,'YData',yd);
	end
	SliderWindowCB('PlotTop',hfig);
end
	
