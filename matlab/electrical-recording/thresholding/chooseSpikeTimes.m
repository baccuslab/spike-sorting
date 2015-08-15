function I = chooseSpikeTimes(d,thresh,sniprange)
% I = chooseSpikeTimes(d,thresh,sniprange)
% From a channel d, find the indices for the peak of spikes
% A spike is defined as a 3-pt max greater than thresh
% which does not occur too close to the endpoints
% (too close being defined by sniprange)
% sniprange is a 2 element vector giving left & right coords
% relative to max (e.g., [-20 40])
dp1 = [0 d(1:size(d,2)-1)];	% Right-shifted d
dm1 = [d(2:size(d,2)) 0];	% Left-shifted d
Istart = find(d > thresh & d > dp1 & d >= dm1);
I = clipEnds(Istart,size(d,2),sniprange);
