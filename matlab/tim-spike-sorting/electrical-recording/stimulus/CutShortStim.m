function stimout = CutShortStim(stimin,dtmin)
dt = diff(stimin(2,:));
badi = find(dt < dtmin);
goodi = setdiff(1:size(stimin,2),badi);
stimout = stimin(:,goodi);
