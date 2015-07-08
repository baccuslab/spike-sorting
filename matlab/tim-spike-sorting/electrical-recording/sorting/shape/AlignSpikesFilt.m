function [shiftspikes,Ikeep] = AlignSpikesFilt(spikes,filt)
%  [shiftspikes,Ikeep] = AlignSpikesFilt(spikes,filt)
% Align spike snippets on the peak of their filtered values
% Use interpolation to shift by fractions of a sample interval
% The output shiftspikes has the same # of points/snippet as
% the filter
% When the filtered spike does not have a maximum within the
% interval uncontaminated by boundary effects, we throw
% that snippet out; Ikeep is the index in spikes of the snippets
% that survive in shiftspikes
n = size(spikes,1);		% # of points in snippet
nspikes = size(spikes,2);
m = length(filt);
if (n +2 < m)
	error('Spike snippets must have at least  2 more points than the filter.');
end
nfp = n-m+1;
% Filter the spikes
for i = 1:nfp
	fspike(i,:) = filt'*spikes(i:m+i-1,:);
end
%figure
%plot(fspike)
%fprintf('size(fspike) = %d\n',size(fspike));
% Find the location of maxima, first to the nearest sample pt
[fmax,Imaxg] = max(fspike);
% Find the common max point
imaxmed = median(Imaxg);
% Now search outwards from this common point until a 3-pt max is found
for j = 1:nspikes
	inow = imaxmed;
	while ( (inow > 1 & inow < nfp) & ~(fspike(inow,j) >= fspike(inow-1,j) & fspike(inow,j) > fspike(inow+1,j)))
		if (fspike(inow+1,j) < fspike(inow-1,j))
			inow = inow-1;
		else
			inow = inow+1;
		end
	end
	Imax(j) = inow;
end
% Keep only those that have interior maxima
Ikeep = find(Imax ~= 1 & Imax ~= nfp);
Imax = Imax(Ikeep);
% Now compute fractional shift
for i = 1:length(Ikeep)
	peaks(:,i) = fspike(Imax(i)-1:Imax(i)+1,Ikeep(i));
end
dx = quadPeak(peaks);
% Shift the spikes
shiftspikes0 = shift(spikes(:,Ikeep),-dx);
for i = 1:length(Ikeep)
	shiftspikes(:,i) = shiftspikes0(Imax(i):Imax(i)+m-1,i);
end
fprintf('AlignSpikesFilt: had to throw out %d snippets during alignment\n',size(spikes,2)-length(Ikeep));
return

function peakI = quadPeak(y)
% peakI = quadPeak(y)
% Given a triplet of points y(-1),y(0),y(1) which
% bracket a maximum, do quadratic interpolation
% to find the x location of the maximum
if (size(y,1) ~= 3)
	error('Error: input must contain triplets!');
end
peakI = (y(1,:)-y(3,:))./(2 * (y(3,:)-2*y(2,:)+y(1,:)));
