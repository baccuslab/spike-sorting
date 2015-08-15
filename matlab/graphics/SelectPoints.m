function I = SelectPoints(p,pH,C)
% I = SelectPoints(p,pH,C)
% Use the mouse to select points on a scatterplot
%    via a rectangular rubberband
% I contains the indices of the selected points
% p is the n-by-2 matrix of point coordinates
% pH is the list of handles to the points
% C contains a color vector for coloring the
%    selected points
theRect = GetSelRect;
Itempx = find(p(:,1) > theRect(1) & p(:,1) < theRect(1)+theRect(3));
Itempy = find(p(:,2) > theRect(2) & p(:,2) < theRect(2)+theRect(4));
I = intersect(Itempx,Itempy);
set(pH(I),'EdgeColor',C,'MarkerFaceColor',C);
