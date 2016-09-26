function PlotCellAll(rec,recfiles,stimtxt,cellnum,width)
% PlotCellAll: generates plots of cell activity from many files
if (length(rec) ~= length(stimtxt) | length(rec) ~= length(recfiles))
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
ncells = ncells(1);
for i = 1:length(rec)
	temprec = SplitRecordCell(rec{i},cellnum,1);
	PlotCellFast0(temprec,cellnum,width,stimtxt{i});
	htitle = suptitle(recfiles{i});
	set(htitle,'Interpreter','none');	% Turn off TeX interpretation
end
