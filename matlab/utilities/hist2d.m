function [n,xcenter,ycenter] = hist2d(xin,yin,rect,nx,ny)
% [nout,xcenter,ycenter] = hist2d(xin,yin,rect,nx,ny)
% Bin data points given by (xin,yin)
% into bins with centered on xcenter,ycenter
% rect determines the exterior range:
% rect = [xmin xmax ymin ymax]
if (length(xin) ~= length(yin))
	error('x & y must have the same length!');
end
if ((rect(1)>=rect(2))|(rect(3)>=rect(4)))
	return % this is a problem, return values not assigned
end
	
dx = (rect(2)-rect(1))/(nx-1);
dy = (rect(4)-rect(3))/(ny-1);
xcenter = linspace(rect(1),rect(2),nx);
ycenter= linspace(rect(3),rect(4),ny);
xi = round((xin-xcenter(1))/dx)+1;
%xok = find(xi <= nx & xi >= 1);
yi = round((yin-ycenter(1))/dy)+1;
%yok = find(yi <= ny & yi >= 1);
%indx = intersect(xok,yok);
n = zeros(nx,ny);
%for i=1:length(indx)
%for i = 1:length(xi)
%	n(xi(i),yi(i)) = n(xi(i),yi(i))+1;
%end
% n=hist2dfast(xi,yi,nx,ny);

n=hist2d_new([xi' yi'],1:nx+1,1:ny+1);

%n(xi(indx(i)),yi(indx(i))) = n(xi(indx(i)),yi(indx(i)))+1;
if (nargout == 0)
	imagesc(ycenter,xcenter,log(n+1));
	set(gca,'YDir','normal');
	colormap(1-gray);
end
