function nbrs = neighbors(chname)
% nbrs = neighbors(chname)
% Gives the list of nearest-neighbors to a given channel
global arraynum
chnum = name2num(chname);
[x,y] = find(arraynum==chnum);
nbrstemp = [arraynum(x+1,y),arraynum(x+1,y-1),arraynum(x,y-1),...
			arraynum(x-1,y),arraynum(x-1,y+1),arraynum(x,y+1)];
indx = [nbrstemp ~= -1];
nbrs = nbrstemp(indx);
