function arrayfunctions (action,h)
	if (nargin < 2)
		h = gcbf;
	end
	hch = getappdata(h,'hch');
	channels=getappdata(h,'channels');
	% Now find the companion axis to the callback axis
	[~,chsel] = find(hch == gcbo);
	chsel
	setappdata (h,'curchan',chsel);
