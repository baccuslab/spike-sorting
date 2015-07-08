function figh = PlotResponses(stim,spike,totstim,stimlabels)
fighh = figure('Position',[256    40   651   678]);
width = 170;
hgap = 50;
height = 105;
vgap = 25;
across = 3;
down = 4;
% Set up axes
for i = 1:down
	for j = 1:across
		bottom = 500-(i-1)*(height+vgap);
		left = (j-1)*(width+hgap) + 25;
		vaxh((j-1)*down+i) = axes('Units','pixels',...
			'Position',[left bottom width,height]);
	end
end
staxh = axes('Units','pixels','Position',[40 20 580 50]);
% Plot the data
%   First the spike data
for i = 1:12
	nr(i) = length(spike{i});
end
maxr = max(nr);
maxtitlelen = 30;
for i = 1:12
	axes(vaxh(i));
	PlotValve(stim{i},spike{i},maxr);
	titlelen = min([maxtitlelen,length(stimlabels{i})]);
	title(stimlabels{i}(1:titlelen));
end
set(vaxh([4 8 12]),'XTickMode','auto');
for i = 4:4:12
	axes(vaxh(i));
	xlabel('Time (s)')
end
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

function PlotValve(stim,spike,stimy)
nrpts = length(stim);
co = get(gca,'ColorOrder');
hold on
for i = 1:nrpts
	tstart = stim{i}(2,1);
	hline = stairs(stim{i}(2,:)-tstart,stimy+1+stim{i}(1,:)/12.1); % Stimulus
	colindx = mod(i-1,size(co,1))+1;
	set(hline,'Color',co(colindx,:));
	nspikes = length(spike{i});
	y1 = (nrpts-i+1)*ones(1,nspikes);
	y = [y1+0.2;y1-0.2];
	x = [spike{i}-tstart;spike{i}-tstart];
	plot(x,y,'Color',co(colindx,:));
end
set(gca,'XLim',[0,stim{1}(2,end)-stim{1}(2,1)],'YLim',[0 stimy+2]);
set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
