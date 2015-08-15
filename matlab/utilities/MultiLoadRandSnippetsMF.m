function randsnips = MultiLoadRandSnippetsMF(ctfiles,channels,nrand,sniprange)
nfiles=size(ctfiles,2);
nchans=size(channels,2);
%For now, pick the largest file and take all random snippets from it
for f=1:nfiles
	[header,headersize] = ReadAIBHeader(ctfiles{f});
	nscans(f)=header.nscans;
end
lf=find(nscans==max(nscans(find(nscans<36000000))));lf=lf(1);
randtimes={unique(max(1,floor(rand(1,nrand)*nscans(lf))))};
snipcell=loadsnipdata(ctfiles(lf),channels,randtimes,sniprange);
snipchans=cell(nchans,1);
for ch=1:nchans
	temp=snipcell(ch,:);
	snipchans{ch}=cat(2,temp{:});
end
randsnips=cat(1,snipchans{:});
