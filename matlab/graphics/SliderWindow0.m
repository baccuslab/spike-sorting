function SliderWindow(hax,pos)
if (nargin < 2)
	pos = [16   306   988   110];
end
hfig = figure('Position',pos,...
	'ButtonDownFcn','SliderWindowCB Select',...
	'HandleVisibility','callback');
hnewax = copyobj(hax(1),hfig);
set(hnewax,'Position',[0.05 0.11 0.9 0.78]);
%axes(hnewax)
hc = findobj(hnewax);	% Get all children
set(hc,'HitTest','off');
xlim = get(hnewax,'XLim');
ylim = get(hnewax,'YLim');
% Set & plot the selection rectangle
selrectx = [xlim(1) xlim(2) xlim(2) xlim(1) xlim(1)];
selrecty = [ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];
hselrect = line(selrectx,selrecty,'LineStyle',':','Color','k',...
	'ButtonDownFcn','SliderWindowCB Slide',...
	'Tag','HSelRect',...
	'Parent',hnewax,...
	'EraseMode','xor');
% Remember which axes to update
setappdata(hfig,'UpdAx',hax);
