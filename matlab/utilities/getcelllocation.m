function locs=getcelllocation(g)
%Get file with most spikes
cnum=0;
locs=[];
for ch=2:size(g.channels,2)
	for cell=1:size(g.chanclust{ch},1)
		cnum=cnum+1;
		sptimes=g.chanclust{ch}(cell,:);
		for f=1:size(sptimes,2)
			nspikes(f)=size(sptimes{f},2);
		end
		lf=find(nspikes==max(nspikes));lf=lf(1);
		snips=loadaibdata(g.ctfiles(lf),g.channels,{sptimes{lf}(1:60)},[-10 20]);
		for chidx=1:size(snips,1)
			snipamp(chidx)=amp(mean(cat(2,snips{chidx,:})'));
		end
		snipamp=snipamp.*(snipamp>(max(snipamp)*0.1)); %Threshold amplitudes
		snipamp=snipamp*size(snipamp,2)/mean(snipamp); %Normalize amplitudes
		pos=getposition(g.channels);
		locs(cnum,:)=snipamp*pos/sum(snipamp);
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=amp(arr)
val=max(arr)-min(arr);
