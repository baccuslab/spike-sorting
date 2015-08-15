function [dims,hax] = CalcSubplotDims(n,xstring,ystring)
% dims = CalcSubplotDims(n)
% Given that we want to have n plots, calculate how best to arrange them on the
% figure window.
%
% If you want global axis labels, use
% [dims,hxlabel,hylabel] = CalcSubplotDims(n)
% and set the String property of the output handles.
figpos = [256   334   512   384];	% Default value
dimx = ceil(sqrt(n));
dimy = ceil(n/dimx);
dims = [dimx,dimy];
if (nargin > 1)
	hxlabel = xlabel(xstring);
	hylabel = ylabel(ystring);
	hax = gca;
	set(hax,'HandleVisibility','off','Visible','off','Color','none');
	set([hxlabel hylabel],'HandleVisibility','on','Visible','on','FontSize',14);
end
