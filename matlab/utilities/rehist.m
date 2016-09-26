function nout = rehist(nin,nbins)
% rehist: make a coarser histogram from a fine one
% nin = number/bin in input histogram
% nbins = number of desired output bins
%    (if greater than length(nin), nin is returned)
% nout = new number/bin in output histogram
% The bins must be evenly spaced
if (length(nin) < nbins)
	nout = nin;
	return
end
width = length(nin)/nbins;
boundaries = (0:nbins)'*width+1;
ip = [ceil(boundaries(1:nbins)),floor(boundaries(2:nbins+1))];
fp = [ip(:,1)-boundaries(1:nbins),boundaries(2:nbins+1)-ip(:,2)];
for i = 1:nbins
	nout(i) = sum(nin(ip(i,1):ip(i,2)-1));	% The integer portion
end
% Now the fractional portion
ip(1,1) = 2;
ip(nbins,2) = length(nin);
for i = 1:nbins
	nout(i) = nout(i) + fp(i,1)*nin(ip(i,1)-1) + fp(i,2)*nin(ip(i,2));
end
