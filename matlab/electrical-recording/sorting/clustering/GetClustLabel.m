function num = GetClustLabel(clnum,clusterlabels)
if (isempty(clusterlabels))
	num = clnum;
	return
end
if (clnum < length(clusterlabels))
	num = clusterlabels(clnum);
else
	num = clusterlabels(end)+(clnum-length(clusterlabels));
end	
