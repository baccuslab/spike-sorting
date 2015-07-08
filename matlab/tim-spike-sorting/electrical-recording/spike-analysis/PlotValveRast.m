function PlotValveRast(stim,spike,stimy)
% PlotValveRast: stimulus timing and raster plot
% PlotValveRast(stim,spike,stimy)
% 	stim & spike are of the format CollectResponses/UnifyResponses
%	stimy (optional) is the # of repeats to make room for (allows matching
%		between valves when # of repeats isn't always the same)
nrpts = length(stim);
if (nargin < 3)
	stimy = nrpts;
end
co = get(gca,'ColorOrder');
hold on
for i = 1:nrpts
	tstart = stim{i}(2,1);
	hline = stairs(stim{i}(2,:)-tstart,stimy+1+stim{i}(1,:)/12.1); % Stimulus
	set(hline,'Tag','Stim');
	colindx = mod(i-1,size(co,1))+1;
	if (length(stim{i}(2,:) < 3))
		ton = 0;
	else
		ton = stim{i}(2,3)-stim{i}(2,2);
	end
	% These next line is specific for one expt! Change this!
	%colindx = round(log2(ton))+2;
	colindx = 1;
	set(hline,'Color',co(colindx,:));
	nspikes = length(spike{i});
	y1 = (nrpts-i+1)*ones(1,nspikes);
	y = [y1+0.2;y1-0.2];
	x = [spike{i}-tstart;spike{i}-tstart];
	plot(x,y,'Color',co(colindx,:));
end
set(gca,'XLim',[0,stim{1}(2,end)-stim{1}(2,1)],'YLim',[0 stimy+2]);
set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
