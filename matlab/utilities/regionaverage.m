function [Vave,S]=regionaverage (A,num)
Vave=A;
for i=1:size(A,2)
	V=A(:,i);
	dif=A-repmat(V,1,size(A,2));;	
	difsq=dif.*dif;	
	D=[mean(difsq);1:size(A,2)];
	Dsort=sortrows(D')';
	Vave(:,i)=mean(A(:,Dsort(2,1:num))')';
	S(i)=sqrt((mean((V-Vave(:,i)).*(V-Vave(:,i))))/mean(V.*V));
end
