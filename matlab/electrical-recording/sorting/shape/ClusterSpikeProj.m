function fig = ClusterSpikeProj(x,y,t,clustnums,polygons)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

hfig = Cluster(x,y);
h1 = uicontrol('Parent',hfig, ...
	'Units','points', ...
	'Position',[412 338 76 30], ...
	'String','AutoCorr',...
	'Callback','ClustSPCallback AutoCorr',...
	'Tag','AutoCorrButton');
setappdata(hfig,'t',t);
if (nargin == 5)
	% Co-opt the "Clear" function and turn it into a "Revert" function
	h = findobj(hfig,'Tag','ClearButton');
	set(h,'String','Revert','Callback','ClustSPCallback Revert');
	setappdata(hfig,'clustnums0',clustnums);
	setappdata(hfig,'polygons0',polygons);
	ClustSPCallback('Revert',hfig);
end
if nargout > 0, fig = hfig; end
