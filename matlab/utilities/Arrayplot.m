function Arrayplot(channels,hch,xc,yc,nspikes) 
    tmp = [xc{:}];
    maxx = max(tmp(:));
    minx = min(tmp(:));
    tmp = [yc{:}];
    maxy = max(tmp(:));
    miny = min(tmp(:));
	for chindx=1:size(channels,1)
		axes(hch(chindx));
		hold off
        yc_arr = [yc{chindx}];
        xc_arr = [xc{chindx}];
        sp_arr = [log(nspikes{chindx}+1)];
		h=imagesc(yc_arr(:),xc_arr(:),sp_arr(:));
		set(h,'UserData',chindx,'ButtonDownFcn','startsort');
		colormap(1-gray);
		set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[],'XColor',[0.8 0.8 0.8],'YColor',[0.8 0.8 0.8])
		set(gca,'Ydir','normal')
		hold on
		%xlim([minx maxx]);ylim([miny maxy]);
		vx=xlim; %vx used because xlim(1) tries to set the xlim instead of returning a value
		vy=ylim;
		text(vx(2)-(vx(2)-vx(1))/4,vy(2)-(vy(2)-vy(1))/8,num2str(channels(chindx)));	
	end

