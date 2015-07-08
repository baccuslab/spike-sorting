function TestAutoThresh(filename,fac)
tmax = 5;
[d,h] = loadmc(filename,[0 tmax]);
numch = size(d,1);
for i = 1:numch
	mn(i) = mean(d(i,:));
	absdev(i) = mean(abs(d(i,:)-mn(i)));
	sig(i) = std(d(i,:));
end
dims = CalcSubplotDims(numch);
for i = 1:numch
	subplot(dims(1),dims(2),i);
	[n,x] = peakHist(d(i,:),mn(i));
	bar(x,n+1);
	set(gca,'YScale','log','XTick',[]);
	val = fac*absdev(i)+mn(i);
	vline(val);
	indx = find(x > val);
	title(sprintf('%d: %g',h.channels(i),sum(n(indx))/tmax))
end
return

function vline(x)
yrange = get(gca,'YLim');
line([x x],yrange,'Color','r');
return
