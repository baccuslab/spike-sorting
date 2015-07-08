function ci = ConfInterval(X,f)
% ConfInterval: quote the percentile interval for a parameter
% ci = ConfInterval(X,f)
% The columns of X contain the individual values
% f contains the fraction of the range you want to be in the
%	confidence interval (between 0 and 1). Defaults to 0.68.
if (nargin < 2 | isempty(f))
	f = 0.68;
end
N = size(X,1);
fi = N*(1-f)/2;
Xs = sort(X);
%ci = Xs([round(fi),round(N-fi)],:);
ncol = size(X,2);
for i = 1:ncol
	num = N - sum(isnan(Xs(:,i)));
	fi = num*(1-f)/2;
	ci(1,i) = Xs(round(fi),i);
	ci(2,i) = Xs(round(num-fi),i);
end
