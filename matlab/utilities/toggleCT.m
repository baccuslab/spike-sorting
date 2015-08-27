%Used to toggle selection of Crosstalk cross-correlations
function toggleCT (h)
	selected=getappdata(h,'CTselected');
	selected=~selected;
	if (selected)
		set(h,'Color',[1 0.8 0.8])
	else
		set(h,'Color',[0.8 1 1])
	end
	setappdata(h,'CTselected',selected);
