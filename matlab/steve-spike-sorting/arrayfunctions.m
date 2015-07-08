function arrayfunctions (action,h)
	if (nargin < 2)
		h = gcbf;
	end
	hch = getuprop(h,'hch');
	channels=getuprop(h,'channels');
	% Now find the companion axis to the callback axis
	[placeholder,chsel] = find(hch == gcbo);
	chsel
	setuprop (h,'curchan',chsel);
