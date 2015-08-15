function averate=averagerate (t)
	%Returns average rate for a cell array containing spike times in seconds
	numspikes=0;
	interval=0;
	for f=1:size(t,2)
		if (size(t{f},2)>0)
			numspikes=numspikes+size(t{f},2);
			interval=interval+max(t{f})-min(t{f});
		end
	end
	if (or(isempty(interval),interval==0))
		averate=0;
	else
		averate=numspikes/interval;
	end
