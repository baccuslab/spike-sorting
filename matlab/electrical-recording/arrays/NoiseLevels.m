function NoiseLevels(toffset)
% NoiseLevels(toffset)
% Compute rms noise & power spectra for multichannel records
% toffset is the time offset to move into the file (default 0)
[file,path] = uigetfile('*.bin','Select raw data file');
tmax = 2;		% Time in seconds to load
if (nargin == 0)
	toffset = 0;
end
[d,h] = load64([path,file],[toffset,toffset+tmax]);
n = std(d');
figure
subplot(2,1,1)
plot(h.channels,n,'*')
axis tight
xlabel('Channel #');
ylabel('RMS signal (\muV)');
title(h.usrhdr');
subplot(2,1,2);
nsort = sort(n);
frac = (1:length(nsort))/length(nsort);
plot(nsort,frac)
xlabel('RMS signal (\muV)');
ylabel('Fraction');
% Power spectrum of the channel with median rms noise
[sn,indx] = sort(n);
repchan = indx(length(n)/2);
figure
subplot(2,1,1)
t = (0:size(d,2)-1)/h.scanrate;
plot(t,d(repchan,:));
axis tight
ylabel('Voltage (µV)');
xlabel('Time (s)');
title(sprintf('Signal on channel %d',h.channels(repchan)));
subplot(2,1,2);
psd(d(repchan,:),2048,h.scanrate);
set(gca,'XScale','log');
xlabel('Frequency (Hz)');
% Find out if user want to do the correlation calculation
% (takes some time)
ButtonName = questdlg('Do you want to calculate cross-channel correlations?');
switch ButtonName
	case 'Yes'
	% Plot correlations between channels
	figure
	[ac,cc] = DoCorr(d);
	imagesc(cc)
	axis square
	colormap(1-gray);
	set(gca,'YDir','normal');
	title('Cross-correlations between channels');
	xlabel('Channel INDEX #');
	ylabel('Channel INDEX #');
end %switch
