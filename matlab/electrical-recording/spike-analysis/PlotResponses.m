function PlotResponses(stim,spike,stimlabels)
% PlotResponses
% PlotResponses(stim,spike,stimlabels)
nstim = length(stim);
if (length(spike) ~= nstim | length(stimlabels) ~= nstim)
	error('All three inputs must have the same length!');
end
newplot
nsp = min([5,ceil(sqrt(nstim))]);
nstim = min([nstim,nsp*nsp]);
% Plot the data
%   First the spike data
for i = 1:nstim
	nr(i) = length(spike{i});	% The number of repeats
end
maxr = max(nr);					% The max # of repeats
maxtitlelen = 30;
for i = 1:nstim
	vaxh(i) = subplot(nsp,nsp,i);
	PlotValve(stim{i},spike{i},maxr);
	titlelen = min([maxtitlelen,length(stimlabels{i})]);
	h = title(stimlabels{i}(1:titlelen));
	set(h,'Tag','ValveContents');
end
lastrow = floor((nstim-1)/nsp)*nsp+1;	% subplot index of 1st one on last row
set(vaxh(lastrow:nstim),'XTickMode','auto');
for i = lastrow:nstim
	axes(vaxh(i));
	xlabel('Time (s)')
end
return
%   Then the total stimulus graph 
axes(staxh);
stairs(totstim(2,:),totstim(1,:));
set(gca,'TickDir','out');
indxnz = find(totstim(1,:) > 0);
xt = totstim(2,indxnz);
yt = 12*ones(size(indxnz));
valvestr = num2str(totstim(1,indxnz)','%3d');
text(xt,yt,valvestr);
axis([0 totstim(2,end) 0 14]);
box off
xlabel('Time (s)');
%set(htitle,'Interpreter','none');	% Turn off TeX interpretation

