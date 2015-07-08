function proj =Project1d(g,channels,filters,snipindx,spindx,hsort)
spikefiles=g.spikefiles;
ctfiles=g.ctfiles;
for i = 1:length(snipindx)
	nsnips(i) = length(snipindx{i});
end
% Process these snippets in blocks
outrange = 0;
start = 0;
loadblock=20000;
while (outrange == 0)
	snips=0;
	lstart=start;
	while (outrange== 0)
		[range,outrange] = BuildRangeMF(nsnips,[lstart+1,lstart+loadblock]);	% Determine how to load the next block
		if (max(range(2,:))>0)
			blkindx = BuildIndexMF(range,snipindx);
			% Load in the snippets
			[snips,f1,header]= MultiLoadIndexSnippetsMF(spikefiles,ctfiles,channels,blkindx,spindx,hsort);
			proj1 = filters'*snips;
			if (lstart==start)
				proj=proj1;
			else
				proj=cat(2,proj,proj1);
			end
			lstart=lstart+loadblock;
		end
	end
	clear snips
end
