function [s,D]=fillcluster (D,SNR,num,thresh,s)
	s=[s num];
	while (SNR(minidx(D,num))<thresh)
		next=minidx (D,num);
		D(:,num)=9999;
		[s,D]=fillcluster (D,SNR,next,thresh,s);
	end
	D(:,num)=9999;
function idx=minidx (D,num)
	[i,idx]=find(D(num,:)==min(D(num,:)));
	idx=idx(1);
