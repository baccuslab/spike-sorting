
function uas = RebuildUnassigned(totindx,selindx)
% Re-compute the unassigned group as the difference
% between the total and the assigned data
% First get the union of all assigned data
nclust = size(selindx,1);
nfiles = size(selindx,2);
wvindx = cell(1,nfiles);
for fnum = 1:nfiles
	wvindx{fnum} = cat(2,selindx{2:nclust,fnum});
end
% Now the unassigned data
for fnum = 1:nfiles
	uas{fnum} = setdiff(totindx{fnum},wvindx{fnum});
end
