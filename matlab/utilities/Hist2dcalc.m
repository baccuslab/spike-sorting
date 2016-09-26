function [xc,yc,nspikes,rectx,recty]=Hist2dcalc(proj,nx,ny,rectx,recty) 
%CREATE 2d HISTOGRAMS FOR CHANNEL PLOT
nch=size(proj,1);
nfiles=size(proj,2);
nspikes=cell(nch,1);
nspikesfiles=cell(nch,nfiles);
xc=cell(nch,1);
yc=cell(nch,1);
himage(nch)=0;

% Determine bin sizes for plot
if (nargin==3)
	rectx(nch,2)=0;
	rectx(:,1)=999999;
	rectx(:,2)=-999999;
	recty=rectx;
end
for chindx=1:nch
	if (nargin==3)
		for fnum=1:nfiles
			if (size(proj{chindx,fnum},1)>0)
				rectx(chindx,1)=min([rectx(chindx,1) min(proj{chindx,fnum}(1,:))]);
				rectx(chindx,2)=max([rectx(chindx,2) max(proj{chindx,fnum}(1,:))]);
				recty(chindx,1)=min([recty(chindx,1) min(proj{chindx,fnum}(2,:))]);
				recty(chindx,2)=max([recty(chindx,2) max(proj{chindx,fnum}(2,:))]);
			end
		end
		if (rectx(1)==rectx(2))
			rectx(2)=rectx(2)+1;
		end
		if (recty(1)==recty(2))
			recty(2)=recty(2)+1;
		end
	end
	nspikes{chindx}(nx,ny)=0;	
	for fnum=1:nfiles
		% Generate 2d-histogram
		%if (nx>2 & ny>2 & size(proj{chindx,fnum},2)>0)
		if (nx>2 & ny>2 & size(proj{chindx,fnum},2)>1)
% 			xc{chindx} = linspace(rectx(chindx, 1), rectx(chindx, 2), nx);
% 			yc{chindx} = linspace(recty(chindx, 1), recty(chindx, 2), ny);
% 			xcIn = [xc{chindx} xc{chindx}(end) + mean(diff(xc{chindx}))];
% 			ycIn = [yc{chindx} yc{chindx}(end) + mean(diff(yc{chindx}))];
% 			nspikesfiles{chindx, fnum} = hist2d_new(proj{chindx, fnum}(1:2, :)', ...
% 				xcIn, ycIn);
				
			[nspikesfiles{chindx,fnum},xc{chindx},yc{chindx}] =  ... 
                hist2d(proj{chindx,fnum}(1,:),proj{chindx,fnum}(2,:), ...
                [rectx(chindx,:) recty(chindx,:)],nx,ny);
			nspikes{chindx}=nspikes{chindx}+nspikesfiles{chindx,fnum};
		end
	end
end
