function goodspikes = removeoutliers (spikes)
%Removes the 5% of spikes that are the greatest Euclidean distance
%away from the mean spike
	avgspike=mean(spikes')';
	for s=1:size(spikes,2)
		dist(s)=sqrt(sum((spikes(:,s)-avgspike).^2));
	end
	dist=[dist;1:size(dist,2)];
	dist=sortrows(dist')';
	goodspikes=spikes(:,dist(2,1:floor(size(dist,2)*0.95)));
	
