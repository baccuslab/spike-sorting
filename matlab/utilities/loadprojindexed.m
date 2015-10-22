function proj=loadprojindexed(projfile,chindices,numchannels,numfiles,indexes)
fid=fopen(projfile,'r');
projfp=fread(fid,[numchannels,numfiles],'int32');
projfp=projfp(chindices,:);
for ch=1:size(chindices,2)
	for fnum=1:numfiles
		fseek(fid,projfp(ch,fnum),'bof');
		[proj{ch,fnum},count]=fread(fid,[3,max(indexes{ch,fnum})],'float32');
		proj{ch,fnum}=proj{ch,fnum}(:,indexes{ch,fnum});
	end
end

