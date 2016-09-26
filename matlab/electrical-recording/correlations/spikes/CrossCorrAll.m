function [cpdf,pair,npb] = CrossCorrAll(trec,tmax)
% CrossCorrAll: Compute spike time cross correlations for all pairs
% [cpdf,pair] = CrossCorrAll(trec,tmax):
%	Input:
%		trec: trec{i,j} is a vector of spike times. trec(i,:) should be a
%			cell array of related spike times, i.e. same channel or same cell.
%			trec can be a N-by-1 cell array.
%		tmax: maximum time separation to include
%	Output: sorted in order of least-flat cross correlation
%		cpdf: fit to a flat line, chisq/degree of freedom
% 		pair: the cell/channel identities for each entry in cpdf (n-by-2)
nchans = size(trec,1);
cpdf = [];
npb = {};
pair = zeros(0,2);
for i = 1:nchans-1
	for j = i+1:nchans
		npbtemp = CrossCorrRec(trec(i,:),trec(j,:),tmax,30);
		%nbins = 2*ceil(sum(npbtemp)^(1/2)/2) + 1;
		%nbins=30;
		%npb{end+1} = rehist(npbtemp,nbins);
		npb{end+1}=npbtemp;
		pair(end+1,1:2) = [i j];
	end
end
% Now compute chisq for each of these
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
%[cpdf,indx] = sort(-cpdf);
%cpdf = -cpdf;
%pair = pair(indx,:);
%npb = npb(indx);
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
	%title(sprintf('%d and %d: %g',pair(i,1),pair(i,2),cpdf(i)))
	title(sprintf('%d and %d',pair(i,1),pair(i,2)))
end
