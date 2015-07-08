function [f,lambda] = MaxSepN(snips)
% MaxSepN: find filters to maximize separation 
% [f,lambda] = MaxSepN(snips)
nclust = length(snips);
if (nclust < 2)
	error('Must have at least 2 clusters to separate');
end
width = size(snips{1},1);
% Compute cluster means
for i = 1:nclust
	mns(:,i) = mean(snips{i}')';
	ns(i) = size(snips{i},2);
end
nstot = sum(ns);
% Compute variance matrices: denom is sum of
% covariance matrices of individual clusters,
% num is sum of cross-variance matrices
% This version divides by #/clust, so true cov. matrx.
Cnum = zeros(width,width);
Cdenom = zeros(width,width);
for i = 1:nclust
	for j = 1:nclust
		if (i == j)
			ds = snips{i}-repmat(mns(:,i),1,ns(i));	% Difference from own mean
			Cdenom = Cdenom + ds*ds'/ns(i);
		else
			ds = snips{i}-repmat(mns(:,j),1,ns(i));	% Difference from other mean
			Cnum = Cnum + ds*ds'/ns(i);
		end
	end
end
% Now solve the generalized eigenvalue problem
%[f,lambda] = eig(Cnum,Cdenom);
%normf = diag(f'*Cdenom*f)/nclust;	% Change default normalization so that
%f = f/diag(sqrt(normf));			% f'*Cnoise*f = identity
%lambda = diag(lambda)/(nclust-1);
[U,V,X,C,S] = gsvd(chol(Cnum),chol(Cdenom),0);	% This version assures it's real
f = sqrt(width)*inv(S*X');
lambda = (diag(C)./diag(S)).^2;
lambda = lambda(width:-1:1);
f = f(:,width:-1:1);
%f'*Cdenom*f/nclust
%lambda
