function PlotCellFast0(record,cellnum,width,stimtxt)
% PlotCellFast0(record,cellnum,width,stimtxt)
% Like PlotCellFast, except doesn't plot 0 bin on autocorrelation function
fig = figure('Position',[ 54   337   856   383]);
col1w = 0.6;
col1l = 0.05;
col2l = col1l+col1w+0.05;
col2w = 0.95 - col2l;
trange = GetRecTimeRange(record);
hs = axes('Position',[col1l,0.85,col1w,0.07]);
PlotStimNum(record,trange,hs)
hrates = axes('Position',[col1l,0.4,col1w,0.4]);
[t,rates] = PlotMultiRate(record,cellnum,width,trange,hrates);
hmedrate = axes('Position',[col1l,0.1,col1w,0.25]);
medr = median(rates,2);
plot(t,medr)
yrange = [0 max([1;medr])];
axis([trange yrange]);
ylabel('Median rate (Hz)');
axes(hmedrate)
xlabel('Time (s)')
axes(hs)
title(['Cell ' num2str(cellnum)])
nspikes = zeros(1,length(record));
for i = 1:length(record)
	nspikes(i) = length(record{i}.T{cellnum});
end
ntot = sum(nspikes);
% Autocorrelation
hac = axes('Position',[col2l,0.7,col2w,0.22]);
toSecs = 50e-6;
nbins = max([1 ceil(ntot^(2/3))]);
tottime = 0.1;
binwidth = tottime/nbins;
nac = zeros(1,nbins);
for i = 1:length(record)
	nactemp = AutoCorr(record{i}.T{cellnum},tottime/toSecs,nbins);
	nac = nac+nactemp;
end
xac = 1000*linspace(binwidth/2,tottime-binwidth/2,nbins);
%[xac;nac]
%nac(1) = 0;
if (sum(nac) > 0)
	bar(xac,nac,1,'k');
	set(gca,'XLim',[0 tottime]);
	xlabel('Time (ms)');
	axis([0 tottime*1000 0 max(nac)]);
	ylabel('#/bin')
	title('Autocorrelation')
end
% Number of spikes/repeat
hns = axes('Position',[col2l,0.4,col2w,0.22]);
axis manual
hold on
xrange = [0 max(2,length(record))];
yrange = [0 max([1 nspikes])];
axis([xrange yrange]);
plot(nspikes)
hold off
xlabel('Repeat #')
ylabel('# of spikes')
hstim = axes('Position',[col2l,0.03,col2w,0.30]);
bkgndcol = get(fig,'Color');
set(hstim,'XColor',bkgndcol,'YColor',bkgndcol,'Color',bkgndcol);
% Value contents
if (nargin == 4)
	xt = zeros(1,length(stimtxt));
	yt = 1:length(stimtxt);
	axis([0 1 0 length(stimtxt)]);
	set(hstim,'YDir','Reverse');
	text(xt,yt,stimtxt)
end
