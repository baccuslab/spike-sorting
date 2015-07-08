function SortingPlots(spikesfilt,snipRand,peak,sv,wave,filt,h)
spiker = h.scalemult*spikesfilt/0.0147;
noiser = h.scalemult*snipRand/0.0147;
t = 1000*((1:size(spiker,1))-peak)/(h.scanrate);
figure
plot(t,spiker);
axsp = gca;
axis tight
ylim = get(axsp,'YLim');
xlabel('Time (ms)');
ylabel('Voltage (\muV)');
figure
plot(t,noiser);
axn = gca;
axis tight
set(axn,'YLim',ylim);
xlabel('Time (ms)');
ylabel('Voltage (\muV)');
figure
plot(sv(1:min([15 length(sv)])),'r-');	% Canvas import requires a line
hlines = findobj(gcf,'Type','line');
set(hlines,'MarkerSize',10);
xlabel('Eigenvalue #');
ylabel('SNR^{1/2}');
[fr,wr] = RealUnitsFilt(filt,wave,h);
figure
plot(t,fr)
axis tight
xlabel('Time (ms)');
ylabel('Filter value (\muV^{-1} ms^{-1})');
figure
plot(t,wr)
axis tight
xlabel('Time (ms)');
ylabel('Waveform value (\muV)');
