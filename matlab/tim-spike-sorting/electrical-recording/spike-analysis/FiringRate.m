function [to,rateo] = FiringRate(spikes,cellnum,width)
% [t,rate] = FiringRate(spikes,cellnum,width)
% Compute the smoothed firing rate as a function of time
% for the cell array of spike times "spikes"
% Smooths by a gaussian of width "width"
%allspikes = cat(spikes{:}.T{cellnum});
allspikes = [];
for i = 1:length(spikes)
	allspikes(end+1:end+length(spikes{i}.T{cellnum})) = spikes{i}.T{cellnum};
end
toSecs = 50e-6;
[t,rate] = kerndens(allspikes,width/toSecs);
% Normalize so integral is # spikes/trial
% and return value in Hertz
rate = length(allspikes)/length(spikes)*rate/toSecs;
% Set to time is in secs
t = t*toSecs;
if (nargout == 0)
	PlotRate(toSecs*spikes{1}.evT,spikes{1}.evP,t,rate,sprintf('Cell %d, smoothing width %2.2fs',cellnum,width));
else
	to = t;
	rateo = rate;
end
