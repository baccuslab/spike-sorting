function XZoomAll(fig)
% XZoomAll(fig)
% Set up zoom data for multiple-axis zooming, and call mzoom xon
% When you zoom on one axis, all the others in the plot follow
% if fig is empty, works on the current figure
if (nargin == 0)
   fig=get(0,'currentfigure');
   if isempty(fig), return, end
end
allAxes = findobj(get(fig,'Children'),'flat','type','axes');
for i = 1:length(allAxes)
	lim(1,:) = [get(allAxes(i),'xlim'),get(allAxes(i),'ylim')];
	if (i < length(allAxes))
		h = allAxes(i+1);
	else
		h = allAxes(1);
	end
	lim(2,:) = [h h 0 0];
	set(get(allAxes(i),'ZLabel'),'UserData',lim);
	set(allAxes(i),'YLimMode','manual');
end
mzoom xon
