function sz = SkewZ(npb)
% SkewZ: z-score for the skewness of a distribution of points
% If the variance in a bin is zero, its corresponding skewness
% is defined to be 1.
npoints = size(npb,1);
nbins = size(npb,2);
mn = mean(npb);
dev = npb - repmat(mn,npoints,1);
dev2 = dev.^2;
dev3 = dev.^3;
den = sum(dev2).^(3/2);
num = abs(sum(dev3));
sz = zeros(1,nbins);
zvari = find(den == 0);
sz(zvari) = Inf;
nzvari = setdiff(1:nbins,zvari);
s(nzvari) = sqrt(npoint/15)*num(nzvari)./den(nzvari);
