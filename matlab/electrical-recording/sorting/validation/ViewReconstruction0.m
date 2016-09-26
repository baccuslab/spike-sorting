function ViewReconstruction(snips,tsnips,tclust,sniprange,trange)
% This is not currently working!
% Need to think about how general to make it
fview = figure('Position',[21   475   961   231]);%,...
fslide = figure('Position',[21 341 961 100]);
%figure('Position',[21 341 961 400]);%,...
%	'Renderer','zbuffer');%,...
%	'HandleVisibility','callback');
%axz = axes('Units','normalized',...
%	'Tag','HAxView',...
%	'DrawMode','fast',...
%	'Position',[0.1 0.4 0.8 0.5]);
%axsl = axes('Units','normalized',...
%	'Tag','HAxSlider',...
%	'DrawMode','fast',...
%	'ButtonDownFcn','ViewReconCB Select',...
%	'Position',[0.1 0.1 0.8 0.2]);
if (nargin < 5)
	trange = [0,tsnips(end)+sniprange(2)];
end
ncells = length(tclust);
% Build the unassigned group
clustindx = cell(1,1+ncells);	% The first is the unassigned group
for i = 1:ncells
	[common,cindx] = intersect(tsnips,tclust{i});
	clustindx{i+1} = cindx;
end
cindx = cat(1,clustindx{:});
clustindx{1} = setdiff(1:length(tsnips),cindx);
% Reconstruct waveforms
for i = 1:(ncells+1)
	[wcell{i},tcell{i}] = ReconstructWaveform(snips(:,clustindx{i}),tsnips(clustindx{i}),sniprange,trange);
end
setappdata(gcf,'wcell',wcell);
setappdata(gcf,'tcell',tcell);
% Now plot the slider panel
figure(fslide);
%axes(axsl);
hold on
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:(ncells+1)
	plot(tcell{i},wcell{i},'Color',co(mod(i-1,ncol)+1,:),'HitTest','off','EraseMode','none');
end
xlim = trange;
set(gca,'XLim',xlim);
ylim = get(gca,'YLim');
setappdata(gcf,'figxlim',xlim);
setappdata(gcf,'figylim',ylim);
% Set & plot the selection rectangle
selrectx = [xlim(1) xlim(2) xlim(2) xlim(1) xlim(1)];
selrecty = [ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];
hselrect = line(selrectx,selrecty,'LineStyle',':','Color','k',...
	'ButtonDownFcn','ViewReconCB Slide',...
	'Tag','HSelRect',...
	'EraseMode','xor');
% Plot the top panel
figure(fview);
%axes(axz);
hold on
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:(ncells+1)
	plot(tcell{i},wcell{i},'Color',co(mod(i-1,ncol)+1,:),'HitTest','off',...
	'EraseMode','background');
end
set(gca,'XLim',xlim);
set(gca,'YLim',ylim);
%ViewReconCB('PlotTop',gcf);
