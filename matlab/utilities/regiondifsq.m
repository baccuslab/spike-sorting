function [Vave,SNR]=regionaverage (A,num)
Vave=A;
for i=1:size(A,2)
	V=A(:,i);
	dif=A-repmat(V,1,size(A,2));;	
	difsq=dif.*dif;	
	D=[mean(difsq);1:size(A,2)];
	Dsort=sortrows(D')';
	Vave(:,i)=mean(A(:,Dsort(2,1:num))')';
	SNR(i)=sqrt(mean(V.*V)/mean(mean(difsq(:,Dsort(2,1:num)))));	
end
