function [px,py] = GetSelPolygon(action,color)
% [px,py] = GetSelPolygon(action,h)
% Set up & get a polygonal selection region
% For the first edge, the user holds and drags; if the distance
% is sufficiently short, the process is aborted. For future edges,
% the user clicks to set the vertex. A double click closes the polygon
% and returns the coordinates of the vertices.
% Users should only need to call with action = 'go'
%
% Note: overwrites the ButtonDownFcn for the axis
%
% GetSelPolygon('go') gets a polygon & returns the coords of the vertices
% GetSelPolygon('start') initiates the selection
% GetSelPolygon('firstmove') is called during the first edge
% GetSelPolygon('firstfinish') is called upon
% GetSelPolygon('continuing') is called during successive edges
% [px,py] = GetSelPolygon('finish') ends the process and returns
%    the coordinates of the polygon
if (nargin == 1)
	color = 'k';
end
switch action
case 'go'
	% Intercept keystrokes, so can delete polygon-in-progress
	keyfun = get(gcf,'KeyPressFcn');
	set(gcf,'KeyPressFcn','GetSelPolygon delete');
	GetSelPolygon('start');
	h = findobj(gca,'Tag','GSPline');
	set(h,'UserData',get(gca,'ButtonDownFcn'),'Color',color);
	waitfor(h,'UserData','done');
	if (ishandle(h))
		px = get(h,'XData');
		py = get(h,'YData');
		px(end+1) = px(1);	% Close the polygon
		py(end+1) = py(1);
		set(h,'XData',px,'YData',py);
		drawnow
		pause(0.1)
		delete(h);
	else
		px = [];
		py = [];
	end
	set(gcf,'KeyPressFcn',keyfun);	% Restore former state
case 'start'
	set(gcf,'WindowButtonMotionFcn','GetSelPolygon(''firstmove'')');
	set(gcf,'WindowButtonUpFcn','GetSelPolygon(''firstfinish'')');
	cpu = get(gca,'CurrentPoint');
	x = cpu(1,1); y = cpu(1,2);
	% Clear out old selections
	h = findobj(gcf,'Tag','GSPline');
	delete(h);
	h = line([x;x],[y;y],'EraseMode','xor','Color',color,'Tag','GSPline');	% The coords of this line will define the polygon
case 'firstmove'
	hline = findobj(gcbf,'Tag','GSPline');
	hax = get(hline,'Parent');
	cp = get(hax,'CurrentPoint');
	if (isempty(cp))
		return;		% Will this fix the mysterious rare bug?
	end
	x = StayInBounds(cp(1,1),get(hax,'XLim'));
	y = StayInBounds(cp(1,2),get(hax,'YLim'));
	xdata = get(hline,'XData');
	ydata = get(hline,'YData');
	xdata(end) = x;
	ydata(end) = y;
	set(hline,'XData',xdata);
	set(hline,'YData',ydata);
case 'firstfinish'
	set(gcbf,'WindowButtonMotionFcn','');
	set(gcbf,'WindowButtonUpFcn','');
	hline = findobj(gcbf,'Tag','GSPline');
	xdata = get(hline,'XData');
	ydata = get(hline,'YData');
	hax = get(hline,'Parent');
	fdx = abs(diff(xdata))/diff(get(hax,'XLim'));
	fdy = abs(diff(ydata))/diff(get(hax,'YLim'));
	if (fdx^2+fdy^2 < 0.05^2)
		set(hax,'ButtonDownFcn',get(hline,'UserData'));	% Restore original
		delete(hline);
	else
		set(hax,'ButtonDownFcn','GetSelPolygon(''continuing'')');
	end
case 'continuing'
	hline = findobj(gcbf,'Tag','GSPline');
	hax = get(hline,'Parent');
	cp = get(hax,'CurrentPoint');
	x = StayInBounds(cp(1,1),get(hax,'XLim'));
	y = StayInBounds(cp(1,2),get(hax,'YLim'));
	xdata = get(hline,'XData');
	ydata = get(hline,'YData');
	xdata(end+1) = x;
	ydata(end+1) = y;
	set(hline,'XData',xdata,'YData',ydata);
	selection_type = get(gcbf,'SelectionType');
	if (strcmp(selection_type,'extend')&length(xdata)>3)
		hline = findobj(gcbf,'Tag','GSPline');
		set(hax,'ButtonDownFcn',get(hline,'UserData'));	% Restore original
		set(hline,'UserData','done');
	end
case 'delete'
	hline = findobj(gcf,'Tag','GSPline');
	hax = get(hline,'Parent');
	set(hax,'ButtonDownFcn',get(hline,'UserData'));	% Restore original
	delete(hline);
otherwise
	error(['Do not recognize action ',action]);
end
return

function xout = StayInBounds(xin,lim)
xout = xin;
if (xout < lim(1))
	xout = lim(1);
elseif (xout > lim(2))
	xout = lim(2);
end
return
