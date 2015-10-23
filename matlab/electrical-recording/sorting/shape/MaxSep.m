function [f,lambda] = MaxSep(snips)
% MaxSep: find filters to maximize separation
% This is just Fisher's linear discriminant analysis
% [f,lambda] = MaxSep(snips)
% The input snips is a cell array, each cell contains the
%	spike waveforms of a given cluster.
% Outputs:
%	f is the matrix of filters, each in a column
%	lambda is the set of eigenvalues
nclust = length(snips);
if (nclust < 2)
	error('Must have at least 2 clusters to separate');
end
width = size(snips{1},1);
% Compute cluster means, as preparation
% for discarding outliers
for i = 1:nclust
	mns(:,i) = mean(snips{i}')';
	ns(i) = size(snips{i},2);
end
% For each cluster, discard the "outliers": throw out
% the 5% of points that are farthest from the cluster mean
for i = 1:nclust
	dxm = snips{i} - repmat(mns(:,i),1,ns(i));
	dx = sum(dxm.^2);
	[dxs,indx] = sort(dx);
	i95 = ceil(0.95*length(dx));
	snips{i} = snips{i}(:,1:i95);
end
% Recompute means, and also compute
% the overall mean
totmean = zeros(width,1);
for i = 1:nclust
	mns(:,i) = mean(snips{i}')';
	ns(i) = size(snips{i},2);
	totmean = totmean + ns(i)*mns(:,i);
end
nstot = sum(ns);
totmean = totmean/nstot;
% Compute the terms appearing in the generalized eigenvalue equation:
% num is the sum of the square distance tensor products from the mean,
% while denom is the sum of the cluster covariance matrices
num = zeros(width,width);
denom = zeros(width,width);
for i = 1:nclust
	dm = mns(:,i)-totmean;
	num = num + dm*dm';
	ds = snips{i}-repmat(mns(:,i),1,ns(i));	% Difference from own mean
	denom = denom + ds*ds'/ns(i);
end
% Now solve the generalized eigenvalue problem
[f,lambda] = eig(num,denom);
lambda = abs(real(diag(lambda)));
f = real(f);
normf = diag(f'*denom*f)/nclust;	% Change default normalization so that
f = f/diag(sqrt(normf));			% f'*Cnoise*f = identity

f = fliplr(f);
lambda = flipud(lambda);

%lambda = diag(lambda)/(nclust-1);
%[U,V,X,C,S] = gsvd(chol(num),chol(denom),0);	% This version assures it's real
%f = sqrt(width)*inv(S*X');
%lambda = (diag(C)./diag(S)).^2;
%lambda = lambda(width:-1:1);
%f = f(:,width:-1:1);
%f'*Cdenom*f/nclust
%lambda
