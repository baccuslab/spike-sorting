function PlotCellAll(rec,recfiles,vlvtxt,cellnum,trange)
% PlotCellAll: generates plots of cell activity from many files
if (length(rec) ~= length(vlvtxt) | length(rec) ~= length(recfiles))
	error('The first 3 inputs have to have the same length');
end
if (length(rec) == 0)
	return;
end
for i = 1:length(rec)
	ncells(i) = length(rec{i}.T);
end
if (~isempty(find(ncells-ncells(1))))
	error('Must have the same cells in all records');
end
for i = 1:length(rec)
	[stim,spike] = CollectResponses(rec{i},cellnum,trange);
	PlotResponses(stim,spike,[rec{i}.evP;50e-6*rec{i}.evT],vlvtxt{i});
	% Overall title
	htitax = axes('Units','pixels','Position',[325 640 1 1],'Visible','off');
	text(0.5,1,sprintf('%s, cell %d',recfiles{i},cellnum),...
		'FontSize',18,'Visible','on','HorizontalAlignment','center',...
		'Interpreter','none');
end
