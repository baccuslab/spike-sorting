function I = clipEnds(Istart,n,sniprange)
% I = clipEnds(Istart,n,sniprange)
% Eliminate spike times too close to endpoints
Ileft = find(Istart+sniprange(1) < 1);	% Throw out spikes too close to endpoint
Iright = find(Istart+sniprange(2) > n);
%Ibad = union(Istart(Ileft),Istart(Iright));
%I = setdiff(Istart,Ibad);
left = max(Ileft)+1;
if (isempty(Ileft))
	left = 1;
end;
right = min(Iright)-1;
if (isempty(Iright))
	right = size(Istart,2);
end;
I = Istart(left:right);
