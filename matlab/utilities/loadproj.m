function proj=loadproj(projfile,chindices,numchannels,numfiles,numproj)
	fid=fopen(projfile,'r');
	projfp=fread(fid,[numchannels,numfiles],'int32');
	projfp=projfp(chindices,:);
	for ch=1:size(chindices,2)
		for fnum=1:numfiles
			fseek(fid,projfp(ch,fnum),'bof');
			if (length(numproj)<=1)
				[proj{ch,fnum},count]=fread(fid,[3,numproj],'float32');
			else
				[proj{ch,fnum},count]=fread(fid,[3,numproj(ch,fnum)],'float32');
			end
		end
    end
    fclose(fid);
