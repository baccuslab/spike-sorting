function PlotStimNum(record,trange,hs)
% PlotStimNum(record,trange,hs)
% record: the cell-array with the stimulus info & neural responses,
%    arranged in records
% trange: the range of the time axis (will be calculated if omitted)
% hs: axis handle for the stimulus plot (will create a new plot window if omitted)
if (nargin < 1)
	error('PlotStim needs at least 1 argument');
elseif (nargin == 1)
	trange = GetRecTimeRange(record);
end
if (nargin < 3)
	newplot;
	hs = gca;
end
toSecs = 50e-6;
axes(hs)
axis([trange 0 12]);
hold on
for i = 1:length(record)
	stairs(toSecs*record{i}.evT,record{i}.evP);
end
hold off

ylabel('Valve #');
if (nargin < 3)
	xlabel('Time (s)');
else
	bkgndcol = get(gcf,'Color');
	set(hs,'XColor',bkgndcol,'Color',bkgndcol);
end
indxnz = find(record{1}.evP > 0);
xt = toSecs*record{1}.evT(indxnz);
yt = 12*ones(size(indxnz));
valvenum = record{1}.evP(indxnz);
valvestr = num2str(valvenum','%3d');
text(xt,yt,valvestr);
