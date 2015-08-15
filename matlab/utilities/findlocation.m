function loc=findlocation (sptimes)
	for ch=1:57
		filename='1.ssnp';
        %[snips,t] = LoadSnip(filename,'spike',ch,10000);
		[t1,h1] = LoadSnipTimes(filename,ch,10000);
		[c,ia,idxtimes]=intersect(sptimes,t1);
		[snips,filenum,t,header] = LoadIndexSnippetsMF({filename},ch,{idxtimes});
		if size(snips,2)>=1
			smean=mean(snips');
			samp=max(smean)-min(smean);
			loc(ch)=samp;
		else
			loc(ch)=0;
		end
	end	
