function snipctcell=getsnipsfrommem(indxsel,hsort,sniprange);
storedsnips=getappdata(hsort,'storedsnips');
storedindx=getappdata(hsort,'storedindx');
storedsniprange=getappdata(hsort,'storedsniprange');
if (~exist('sniprange'))
	range=1:(storedsniprange(2)-storedsniprange(1)+1);
elseif (or(sniprange(1)<storedsniprange(1),sniprange(2)>storedsniprange(2)))
	range=[];
else
	range=(sniprange(1)-storedsniprange(1)+1):(sniprange(2)-storedsniprange(1)+1);
end
nfiles=size(storedindx,2);nchans=size(storedsnips,1);
snipctcell=cell(nchans,nfiles);
for f=1:nfiles
	for ch=1:nchans
		if (~isempty(storedsnips{ch,f}))
			[a,b,sidx]=intersect(indxsel{f},storedindx{f});
			snipctcell{ch,f}=storedsnips{ch,f}(range,sidx);
		end
	end
end
