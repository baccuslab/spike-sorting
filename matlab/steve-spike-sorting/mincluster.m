function s=mincluster (D,SNR,num)
	next=num;
	s=[];
	i=1;
	while (i<150)
		s=[s next];
		D(:,next)=9999;
		next=minidx (D,s);
		i=i+1;
	end
	
function idx=minidx (D,s)
	[i,idx]=find(D(s,:)==min(min(D(s,:))));
	idx=idx(1);
