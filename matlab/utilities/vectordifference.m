function D=vectordifference (A)
D(size(A,2),size(A,2))=0;
for i=1:size(A,2)
	V=A(:,i);
	dif=A-repmat(V,1,size(A,2));;	
	difsq=dif.*dif;	
	D(i,:)=sqrt(mean(difsq)/mean(V.*V));
	D(i,i)=9999;
end
