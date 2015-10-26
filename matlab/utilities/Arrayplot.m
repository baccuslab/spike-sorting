function Arrayplot(channels,hch,xc,yc,nspikes) 
	maxx=0;minx=0;maxy=0;miny=0;
	for chindx=1:size(channels,2)
		maxx=max([maxx xc{chindx}]);
		minx=min([minx xc{chindx}]);
		maxy=max([maxy yc{chindx}]);
		miny=min([miny yc{chindx}]);
	end
	for chindx=1:length(channels)
		axes(hch(chindx));
		hold off
		h=imagesc(yc{chindx},xc{chindx},log(nspikes{chindx}+1));
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

