function thresh = SetThresholds(d)
% thresh = SetThresholds(d)
% Mouse-driven method for setting thresholds
figure
nchan = size(d,1);
for i = 1:nchan
	[n,x] = peakHist(d(i,:),0);
	bar(x,n+1);
	set(gca,'YScale','log');
	xlabel('3-pt peak value   (in A/D units)');
	ylabel('#/bin');
	title(sprintf('Set thresholds for selected channel %d',i));
	[mx,my] = ginput(1);
	thresh(i) = mx;
end
close(gcf)
