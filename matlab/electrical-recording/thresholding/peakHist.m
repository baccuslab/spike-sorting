function [n,x] = peakHist(d,thresh)
% [n,x] = peakHist(d,thresh)
% Plot the histogram of the peak values in d
% Vertical axis is logarithmic
Ip = chooseSpikeTimes(d,thresh,[0 0]);
nbins = length(Ip)^(1/3);
[n,x] = hist(d(Ip),nbins);
if (nargout > 0)
	return
end
bar(x,log(n+1));
ylabel('Log(number/bin)');
s = sprintf('%d total peaks',length(Ip));
title(s);
