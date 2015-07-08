function hh = xerrorbar(x, y, l,u,symbol)
% xerrorbar: Put error bars on x coordinate, rather than y coordinate
hh1 = errorbar(y,x,l,u,symbol);
for i = 1:length(hh1)
	temp = get(hh1(i),'XData');
	set(hh1(i),'XData',get(hh1(i),'YData'));
	set(hh1(i),'YData',temp);
end
