function theRect = GetSelRect
% theRect = GetSelRect
% Get a selection rectangle (via a mouse-dragged
%    rubberband) in axis coordinates
% theRect = [left bottom width height]
point1 = get(gca,'CurrentPoint');
finalRect = rbbox;
point2 = get(gca,'CurrentPoint');
point1 = point1(1,1:2);
point2 = point2(1,1:2);
p1 = min(point1,point2);
offset = abs(point1-point2);
theRect = [p1 offset];
