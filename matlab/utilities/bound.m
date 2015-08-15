function pctr=bound (mat)
	tic
	imax= mat(1,:)==max(mat(1,:));
	pmax=mat(:,imax);
	dist=distance(mat,pmax);
	binsize=(max(dist)-min(dist))/sqrt(size(mat,2));
	len=(binsize/max(hist(dist,sqrt(size(mat,2)))))^(1/2);
	minx=min(mat(1,:));
	maxx=max(mat(1,:));
	miny=min(mat(2,:));
	maxy=max(mat(2,:));
	pd=zeros(ceil((maxx-minx)/len),ceil((maxy-miny)/len));
	nmat(1,:)=ceil(len+(mat(1,:)-minx)/len);
	nmat(2,:)=ceil(len+(mat(2,:)-miny)/len);
	for p=1:size(mat,2)
		pd(nmat(1,p),nmat(2,p))=pd(nmat(1,p),nmat(2,p))+1;
	end
	imax=find(pd==max(max(pd)));
	ixmax=floor(imax(1)/size(pd,1))+1;
	iymax=mod(imax(1),size(pd,1));
	pctr=[minx+len*iymax miny+len*ixmax];
	dist(1,:)=atan(mat(1,:)./mat(2,:));
	dist(2,:)=distance(mat,pctr);
	dist=sortrows(dist');
	toc
	keyboard
	

function dist=distance(mat,pmax)
	d1d(1,:)=mat(1,:)-pmax(1);
	d1d(2,:)=mat(2,:)-pmax(2);
	dist=sqrt(sum(d1d.*d1d));
