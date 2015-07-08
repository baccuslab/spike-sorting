function loc=getlocation(g,sptimes)
%Get file with most spikes
for f=1:size(sptimes,2)
	nspikes(f)=size(sptimes{f},2);
end
lf=find(nspikes==max(nspikes));lf=lf(1);
snips=loadsnipdata(g.ctfiles(lf),g.channels,sptimes(lf),[-10 20]);
for chidx=1:size(snips,1)
	snipamp(chidx)=amp(mean(cat(2,snips{chidx,:})'));
end
snipamp=snipamp.*(snipamp>(max(snipamp)*0.1));
pos=getposition(g.channels);
loc=snipamp*pos/sum(snipamp);
keyboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=amp(arr)
val=max(arr)-min(arr);
