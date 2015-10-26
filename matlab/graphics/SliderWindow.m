function hfig=SliderWindow(hax,pos)
% SliderWindow: create a window for interactive zooming
% SliderWindow(hax,pos)
%	If hax is a scalar, then dragging a selection rectangle results in
%		both x- and y-zooming. Shift-dragging the rectangle results in
%		only the x axis zooming.
%	If hax is a vector, then only x-zooming is enabled, but all axes
%		zoom simultaneously. The slider window shows hax(1)
%
%	The selection rectangle itself can be dragged; again, shift-clicking
%		allows only x-translation.
%
%	pos is an optional position for the new figure window
%
%	The "Zoom In" button takes the portion of the slider window that
%		is inside the selection rectangle and expands it to fill the
%		whole window. "Zoom Out" reverts to the full axis.
if (nargin < 2)
	pos = [16   306   988   110];
end
hfig = figure('Position',pos,...
	'ButtonDownFcn','SliderWindowCB Select',...
	'Visible','off',...
	'BackingStore','off',...
	'HandleVisibility','callback');
hnewax = axes('Parent',hfig,'Position',[0.05 0.11 0.8 0.78]);
% For optimal performance, one has to be careful about the order
% in which the objects appear in the list of children of the slider axes.
% Otherwise graphs that take a long time to draw can get drawn twice!
% The strategy: make the selection box the first of the children, and
% then add on the children of the 
hc = get(hax(1),'Children');	% Get all children
hc=hc(end:-1:1);
lims = get(hax(1),{'XLim','YLim'});
xlim = lims{1}; ylim = lims{2};
% Set & plot the selection rectangle
selrectx = [xlim(1) xlim(2)/20 xlim(2)/20 xlim(1) xlim(1)];
selrecty = [ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];
hselrect = line(selrectx,selrecty,'LineStyle',':','Color','k',...
	'ButtonDownFcn','SliderWindowCB Slide',...
	'Tag','HSelRect',...
	'Parent',hnewax);
% Remember which axes to update
setappdata(hfig,'UpdAx',hax);
setappdata(hfig,'FullXLim',xlim);
setappdata(hfig,'FullYLim',ylim);
% Now copy all the children of the original axis to the new one
hcnew = copyobj(hc,hnewax);
set([hcnew;hnewax],'HitTest','off');
set(hnewax,'XLim',xlim,'YLim',ylim);
% Put in the push buttons
hb1 = uicontrol(hfig,'Style','PushButton','String','Zoom In',...
	'units','normalized','Position',[0.89 0.6 0.07 0.29],...
	'Callback','SliderWindowCB ZoomIn');
hb2 = uicontrol(hfig,'Style','PushButton','String','Zoom Out',...
	'units','normalized','Position',[0.89 0.11 0.07 0.29],...
	'Callback','SliderWindowCB ZoomOut');
set(hfig,'Visible','on');
