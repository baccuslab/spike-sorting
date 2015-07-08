function PeakHistAll(d)
% PeakHistAll(d)
% For generating peak histograms for multichannel data
figure
set(gcf,'Position',[44    56   808   661]);
nchan = size(d,1);
nrow = ceil(sqrt(nchan));
ncol = ceil(nchan/nrow);
for i = 1:nchan
	[n,x] = peakHist(d(i,:),0);
	subplot(nrow,ncol,i);
	bar(x,n);
	set(gca,'YScale','log');
	%axis tight
	ylabel(sprintf('SelChan %d',i));
end
suptitle('Histogram of 3-pt-max values for selected channels');
