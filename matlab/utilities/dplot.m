function dplot (h,x,y,rectx,recty)
	axes(h)
	binsize=min([(rectx(2)-rectx(1))/40 (recty(2)-recty(1))/40]);
	nx = max(2,round((rectx(2)-rectx(1))/binsize));
	ny = max(2,round((recty(2)-recty(1))/binsize));
	% Generate & plot histogram
	xlim(rectx)
	ylim(recty)
	[n,xc,yc] = hist2d(x,y,[rectx recty],nx,ny);
	n=(exp(1)-1)*n/max(max(n))+1;%n goes from 1 to e
	himage = imagesc(xc,yc,64*log(n)');
	set(h,'YDir','normal');
	colormap(1-gray);
	set(h,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[])
	set(himage,'HitTest','off');
