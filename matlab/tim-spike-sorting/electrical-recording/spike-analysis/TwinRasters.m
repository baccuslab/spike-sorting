function TwinRasters(stimA,stimB,rastA,rastB,toffset)
blank = zeros(2,2);
blank = {blank,blank};
stim = [stimA,blank,stimB];
blank = cell(1,2);
spike = [rastA,blank,rastB];
PlotValve(stim,spike,length(spike),toffset);
line(get(gca,'XLim'),[1 1]*length(rastA)+1.5,'Color','k');

function PlotValve(stim,spike,stimy,toffset)
nrpts = length(stim);
co = get(gca,'ColorOrder');
hold on
for i = 1:nrpts
	tstart = stim{i}(2,1);
	hline = stairs(stim{i}(2,:)-tstart+toffset,stimy+1+0.9*ceil(stim{i}(1,:)/12)); % Stimulus
	set(hline,'Tag','Stim','Color','r');
	colindx = mod(i-1,size(co,1))+1;
	%if (length(stim{i}(2,:) < 3))
	%	ton = 0;
	%else
	%	ton = stim{i}(2,3)-stim{i}(2,2);
	%end
	% These next line is specific for one expt! Change this!
	%colindx = round(log2(ton))+3;
	colindx = 1;
	%set(hline,'Color',co(colindx,:));
	nspikes = length(spike{i});
	y1 = (nrpts-i+1)*ones(1,nspikes);
	y = [y1+0.2;y1-0.2];
	x = [spike{i}-tstart;spike{i}-tstart];
	plot(x+toffset,y,'Color',co(colindx,:));
end
set(gca,'XLim',[toffset,stim{1}(2,end)-stim{1}(2,1)+toffset],'YLim',[0 stimy+2]);
set(gca,'YTick',[]);
