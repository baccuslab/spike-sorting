function [p,w] = PeakWidth(spikes,thresh)
% [p,w] = PeakWidth(spikes,thresh)
% Peak-width sorting on a set of spike snippets

% First, find the location of maximum
[val,indx] = max(spikes);
Imax = median(indx);
% Now compute peaks and widths
goodSpikes = find(spikes(Imax,:)>=thresh);
p = spikes(Imax,goodSpikes);
for i = 1:length(goodSpikes)
	left = -1;
	while (Imax+left > 0 & spikes(Imax+left,goodSpikes(i)) >= thresh)
		left = left-1;
	end
	% interpolate the crossing time
	if (Imax+left > 0)
		y0 = spikes(Imax+left+1,goodSpikes(i));
		y1 = spikes(Imax+left,goodSpikes(i));
		%fprintf('y0 %f  y1 %f  oldleft %f',y0,y1,left);
		left = left + 1 - (y0 - thresh)/(y0 - y1);
		%fprintf('  newleft %f\n',left);
	end
	right = 1;
	while (Imax+right <= size(spikes,1) & spikes(Imax+right,goodSpikes(i)) >= thresh)
		right = right+1;
	end
		if (Imax+right <= size(spikes,1))
		y0 = spikes(Imax+right-1,goodSpikes(i));
		y1 = spikes(Imax+right,goodSpikes(i));
		%fprintf('y0 %f  y1 %f  oldright %f',y0,y1,right);
		right = right - 1 + (y0 - thresh)/(y0 - y1);
		%fprintf('  newright %f\n',right);
	end
	w(i) = right-left;
end
return
