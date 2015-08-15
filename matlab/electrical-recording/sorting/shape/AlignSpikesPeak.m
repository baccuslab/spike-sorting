function shiftspikes = AlignSpikesPeak(spikes)
% shiftspikes = AlignSpikesPeak(spikes)
% Do interpolation to align spike snippets on their peak
% The output shiftspikes has 2 fewer points/snippet than
% the input (one from each end)
nsamp = size(spikes,1);
[val,indx] = max(spikes);
Imax = median(indx);	% Find location of peak
%meanpeak = mean(spikes(Imax,:));
for i = 1:size(spikes,2)
	peaks = spikes(Imax-1:Imax+1,:);
end
dx = quadPeak(peaks);
shiftspikes = shift(spikes,-dx);
shiftspikes = shiftspikes(2:nsamp-1,:);


function peakI = quadPeak(y)
% peakI = quadPeak(y)
% Given a triplet of points y(-1),y(0),y(1) which
% bracket a maximum, do quadratic interpolation
% to find the x location of the maximum
if (size(y,1) ~= 3)
	error('Error: input must contain triplets!');
end
peakI = (y(1,:)-y(3,:))./(2 * (y(3,:)-2*y(2,:)+y(1,:)));
