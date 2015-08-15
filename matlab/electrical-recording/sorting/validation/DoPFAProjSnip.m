function pfp = DoPFAProjSnip(spikes,filt)
% pfp = DoPFAProjSnip(spikes,filt)
% Calculate projections of spike snippets onto filters
% (could of course be any vectors)
% spikes is the matrix of spike snippets (#/snippet,# of snippets)
% filt is the set of filters (#/filter,# of filters)
% This is merely matrix multiplication
pfp = spikes'*filt;
return
