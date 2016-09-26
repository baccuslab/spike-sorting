function [filters,wave,sv] = Build2Filters(spikes,noise)
[f,w,sv] = calcFiltFromSnips(spikes,noise);
filters = f(:,1:2);
wave = w(:,1:2);
if (nargout > 1)
	return
end
nfilt = 2;
figure
plot(sv(1:min([15 length(sv)])),'r.')
hlines = findobj(gcf,'Type','line');
set(hlines,'MarkerSize',10);
title('Singular values');
figure
subplot(2,1,1)
plot(w(:,1:nfilt));
title('Waveforms');
subplot(2,1,2)
plot(f(:,1:nfilt));
title('Filters');
