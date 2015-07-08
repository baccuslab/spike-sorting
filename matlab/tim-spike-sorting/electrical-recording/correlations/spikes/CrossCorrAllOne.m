function [cpdf,indx,npb] = CrossCorrAllOne(trec,tchosen,tmax)
% CrossCorrAllOne: Compute spike time cross-correlations for all against one
% [cpdf,indx,npb] = CrossCorrAllOne(trec,tchosen,tmax):
%	Input:
%		trec: trec{i,j} is a vector of spike times. trec(i,:) should be a
%			cell array of related spike times, i.e. same channel or same cell.
%			trec can be a N-by-1 cell array.
%		tchosen: tchosen{j} is a vector of spike times. Computes the cross-
%			correlations for trec{i,:} against tchosen{:}.
%		tmax: maximum time separation to include
%		
%	Output: sorted in order of least-flat cross correlation
%		cpdf: fit to a flat line, chisq/degree of freedom
% 		indx: the cell/channel identities for each entry in cpdf (1-by-n)
nchans = size(trec,1);
npb = {};
indx = zeros(0,1);
cpdf = [];
for i = 1:nchans
	npbtemp = CrossCorrRec(trec(i,:),tchosen,tmax,100);
	nbins = 2*ceil(sum(npbtemp)^(1/2)/2) + 1;
	npb{end+1} = rehist(npbtemp,nbins);
	indx(end+1) = i;
end
% Now compute chisq for each of these
% First we have to estimate the baseline
for i = 1:length(npb)
	mncc(i) = median(npb{i})+1;
end
for i = 1:length(npb)
	if (mncc(i) > 0)
		dn = npb{i}-mncc(i);
		chisq(i) = (dn*dn')/mncc(i);
		cpdf(i) = chisq(i)/length(dn);
	else
		chisq(i) = 0;
		cpdf(i) = 0;
	end
end
% Sort them in decreasing order
[cpdf,sindx] = sort(-cpdf);
cpdf = -cpdf;
indx = indx(sindx);
npb = npb(sindx);
if (nargout > 0)
	return;
end
% Now plot the least-flat crosscorr functions
% (the worst 25)
iend = min(25,length(cpdf));
newplot
maxsp = ceil(sqrt(iend));
for i = 1:iend
	subplot(maxsp,maxsp,i);
	nbins = length(npb{i});
	binwidth = 2*tmax/nbins;
	xax = linspace(-tmax+binwidth/2,tmax-binwidth/2,nbins);
	bar(xax,npb{i});
	set(gca,'XLim',[-tmax,tmax]);
	title(sprintf('%d: %g',indx(i),cpdf(i)))
end
