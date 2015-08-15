function sm = SkewMean(npb)
% SkewMean: skewness of the distribution of the mean, as estimated
% from the points themselves.
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
sm = zeros(1,nbins);
zvari = find(den == 0);
sm(zvari) = 1;
nzvari = setdiff(1:nbins,zvari);
sm(nzvari) = num(nzvari)./den(nzvari);
