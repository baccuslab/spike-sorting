function locs=getcelllocation(g)
%Get file with most spikes
%
% INPUT:
%   g           - ?
%
% (C) 2015 The Baccus Lab
%
% History:
% ?? - Steve Baccus
%   - wrote it
%
% 2015-08-26 - Lane McIntosh
%   - updating to use HDFIO functions instead of loadaibdata
%

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

        % new loadRawData command takes the beginning of the snip and the length
        snip_start_offset = -10;
        snip_length = abs(20 - snip_start_offset) + 1;
		snips=loadRawData(g.ctfiles(lf),g.channels,{sptimes{lf}(1:60) + snip_start_offset}, snip_length);

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
