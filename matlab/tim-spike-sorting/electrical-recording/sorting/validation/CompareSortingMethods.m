function CompareSortingMethods(spikespeak,spikesfilt,chan,IKeepFilt,filt)
% CompareSortingMethods(spikes,chan)
% Compare different spike sorting methods: peak/width,
% PFA, and PCA
% spikes contains the spike snippets
% chan contains the channel-of-origin for each snippet
% filt contains the filters for PFA

% First do general setup stuff
% Figure out how many channels we have and which spikes
% come from which channels
uchan = unique(chan(IKeepFilt));
for i = 1:length(uchan)
	chansp{i} = find(chan(IKeepFilt) == uchan(i));
	nspike(i) = length(chansp{i});
end
fprintf('(channel,nspikes): ');
fprintf('(%d,%d) ',[uchan;nspike]);
fprintf('\n');
% Infer the threshold used to extract spikes
[val,indx] = max(spikespeak(:,IKeepFilt));
Imax = median(indx);
thresh = min(spikespeak(Imax,IKeepFilt));
fprintf('thresh = %f\n',thresh);
% Compute the parameters for each method
[peak,width] = PeakWidth(spikespeak(:,IKeepFilt),thresh);
pcp = DoPrincompProj(spikesfilt,2);
pfp = filt(:,1:2)'*spikesfilt;
% Now organize the output
% Make multiple figure windows, with a max of maxchan channels/window
% Put the different sorting methods side-by-side
i = 0;
maxchan = min(6,length(uchan));
while (i+maxchan <= length(uchan))
	PlotFigs(maxchan,uchan(i+1:i+maxchan),chansp(i+1:i+maxchan),peak,width,pcp,pfp);
	i = i + maxchan;
end
if (i < length(uchan))
	PlotFigs(maxchan,uchan(i+1:length(uchan)),chansp(i+1:length(uchan)),peak,width,pcp,pfp);
end
return



function PlotFigs(maxchan,channum,chansp,peak,width,pcp,pfp)
nfig = length(channum);
figure
set(gcf,'Position',[256    47   521   671]);
for i = 1:nfig
	axh(i,1) = subplot(maxchan,3,(i-1)*3+1);
	scatter(width(chansp{i}),peak(chansp{i}),2,[0 0 1],'filled');
	%axis tight
	axh(i,2) = subplot(maxchan,3,(i-1)*3+2);
	scatter(pfp(2,chansp{i}),pfp(1,chansp{i}),2,[0 0 1],'filled');
	%axis tight
	axh(i,3) = subplot(maxchan,3,(i-1)*3+3);
	scatter(pcp(2,chansp{i}),pcp(1,chansp{i}),2,[0 0 1],'filled');
	%axis tight
end
axes(axh(1,1));
title('Peak/width');
axes(axh(1,2));
title('PFA');
axes(axh(1,3));
title('PCA');
for i = 1:nfig
	axes(axh(i,1));
	ylabel(sprintf('Channel %d',channum(i)));
end
return
