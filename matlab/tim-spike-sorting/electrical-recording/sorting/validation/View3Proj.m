function View3Proj(spikes,chan,filt)
% View3Proj(spikes,chan,filt)
% For both PFA & PCA, view all projections onto pairs of
% the first 3 coordinates
uchan = unique(chan);
for i = 1:length(uchan)
	chansp{i} = find(chan == uchan(i));
	nspike(i) = length(chansp{i});
end
fprintf('(channel,nspikes): ');
fprintf('(%d,%d) ',[uchan;nspike]);
fprintf('\n');
% Compute the parameters for each method
pcp = DoPrincompProj(spikes,3);
pfp = filt(:,1:3)'*spikes;
% Now organize the output
% Make multiple figure windows, with a max of maxchan channels/window
% Put the different sorting methods side-by-side
i = 0;
maxchan = 6;
while (i+maxchan <= length(uchan))
	PlotFigs(maxchan,uchan(i+1:i+maxchan),chansp(i+1:i+maxchan),pcp,'PCA');
	PlotFigs(maxchan,uchan(i+1:i+maxchan),chansp(i+1:i+maxchan),pfp,'PFA');
	i = i + maxchan;
end
if (i < length(uchan))
	PlotFigs(maxchan,uchan(i+1:length(uchan)),chansp(i+1:length(uchan)),pcp,'PCA');
	PlotFigs(maxchan,uchan(i+1:length(uchan)),chansp(i+1:length(uchan)),pfp,'PFA');
end
return



function PlotFigs(maxchan,channum,chansp,p,titlestr)
nfig = length(channum);
figure
set(gcf,'Position',[256    47   521   671]);
for i = 1:nfig
	axh(i,1) = subplot(maxchan,3,(i-1)*3+1);
	scatter(p(2,chansp{i}),p(1,chansp{i}),2,[0 0 1],'filled');
	axh(i,2) = subplot(maxchan,3,(i-1)*3+2);
	scatter(p(3,chansp{i}),p(1,chansp{i}),2,[0 0 1],'filled');
	axh(i,3) = subplot(maxchan,3,(i-1)*3+3);
	scatter(p(3,chansp{i}),p(2,chansp{i}),2,[0 0 1],'filled');
end
axes(axh(1,1));
title('1 vs 2');
axes(axh(1,2));
title('1 vs 3');
axes(axh(1,3));
title('2 vs 3');
for i = 1:nfig
	axes(axh(i,1));
	ylabel(sprintf('Channel %d',channum(i)));
end
suptitle(titlestr);
return
