function subset=getsubset(fullindx,subsetsize)
% Getsubset: returns a subset of indexes
nfiles=size(fullindx,2);
for fn=1:nfiles; nidxs(fn)=size(fullindx{fn},2);end %nidxs: num in each file
totidxs=sum(nidxs);
if (subsetsize<totidxs)
	nsubidxs=ceil(subsetsize*nidxs/totidxs);%nsubidxs:num in each file for subset
	for fn=1:sum(nsubidxs)-subsetsize; nsubidxs(fn)=nsubidxs(fn)-1;end %Adjust to correct num of idxs
	%Create subset index array
	subset=cell(1,nfiles);
	for fn=1:nfiles
		stx=floor(size(fullindx{fn},2)/2-nsubidxs(fn)/2);
		endx=stx+nsubidxs(fn)-1;
		if (and(stx~=0,endx~=0))
			subset{fn}=fullindx{fn}(stx:endx);
		end
	end
else
	subset=fullindx;
end	
