function timesout=removetimes (timesin,chanclust,removedCT,chindices)
	timesout=timesin;
	for ch=1:size(chindices,2)
		for clust=1:size(chanclust{chindices(ch)},1)
			for fnum=1:size(chanclust{chindices(ch)},2)
				%indexes are for the remaining spikes
				if (size(timesout{ch}{fnum},1)>0)
					[placeholder,indexes]=setdiff(timesout{ch}{fnum}(1,:),chanclust{chindices(ch)}{clust,fnum});%Remove previous clusters
					timesout{ch}{fnum}=timesout{ch}{fnum}(:,indexes);
				end
			end
		end
	end
	for ch=1:size(chindices,2)
		for fnum=1:size(timesin{1},2)
			if (size(timesout{ch}{fnum},1)>0 & ~isempty(removedCT{chindices(ch)}))
				[placeholder,indexes]=setdiff(timesout{ch}{fnum}(1,:),removedCT{chindices(ch),fnum});%Remove crosstalk
				timesout{ch}{fnum}=timesout{ch}{fnum}(:,indexes);
			end
		end	
	end
