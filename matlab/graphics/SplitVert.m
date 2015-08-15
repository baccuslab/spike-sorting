function hax = SplitVert(split)
% SplitVert: split an axis vertically into subaxes
% hax = SplitVert(split)
%	The input split is a vector of fractional split points,
%		e.g., if you want to cut into 3 equal axes you
%		would have
%			split = [0.333 0.667];
%	Output handles are ordered from top to bottom
pos = get(gca,'position');
delete(gca);
split = unique([0;split(:);1]);
ht = diff(split);
for i = 1:length(split)-1
	normin = [0 split(i) 1 ht(i)];
	posout = SetAxPosNorm(pos,normin);
	hax(i) = axes('position',posout);
end
hax = hax(end:-1:1);
