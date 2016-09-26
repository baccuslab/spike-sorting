function [filtsout,waveforms,singvals] = calcFiltFromSnips(spikes,nonspikes)
% [filtsout,waveforms,singvals] = calcFiltFromSnips(spikes,nonspikes)
% Calculate the set of filters (eigenvectors) and associated singular values
% (square root of eigenvalues) from the raw data
if (size(spikes,1) ~= size(nonspikes,1))
	error('# of samples in spikes & non-spikes must be the same!');
end
width = size(spikes,1);
meanspike = mean(spikes')';
spikes = SubtractMean(spikes);
nonspikes = SubtractMean(nonspikes);
nspikes = size(spikes,2);
nnonspikes = size(nonspikes,2);
[U,V,X,C,S] = gsvd(spikes',nonspikes',0);
% The filters are the inv(X'), except we normalize
% so that the noise is white
filtsout = sqrt(nnonspikes)*inv(S*X');
singvals = (diag(C)./diag(S))*sqrt(nnonspikes/nspikes);
waveforms = X*S/sqrt(nnonspikes);
singvals = singvals(width:-1:1);		% put largest eigenvalue first
waveforms = waveforms(:,width:-1:1);
filtsout = filtsout(:,width:-1:1);
% Get the sign right on the spike-detection filter
% (so that the filter convolved with the "mean spike" gives
%  a positive number)
pol = mean(filtsout(:,1)'*meanspike);
if (pol < 0)
	filtsout(:,1) = -filtsout(:,1);
	waveforms(:,1) = -waveforms(:,1);
end

function m = SubtractMean(m)
meanm = mean(m')';
m = m - repmat(meanm,1,size(m,2));
