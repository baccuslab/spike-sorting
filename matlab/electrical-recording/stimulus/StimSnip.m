function ssnip = StimSnip(stim,trange)
evT = stim(2,:);
tindx = find(evT >= trange(1) & evT <= trange(2));
previndx = max([tindx(1)-1,1]); postindx = min([tindx(end)+1,length(evT)]);
ssnip = stim(:,previndx:postindx);
ssnip(2,1) = trange(1);
ssnip(2,end) = trange(2);
ssnip(1,end) = ssnip(1,end-1);
