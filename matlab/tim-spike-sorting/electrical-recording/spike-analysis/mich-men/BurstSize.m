function bsize = BurstSize(t,tsep)
dt = diff(t);
indx = find(dt > tsep);
bsize = diff(indx);
