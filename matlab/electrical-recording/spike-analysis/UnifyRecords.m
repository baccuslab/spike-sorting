function [ustim,uspike] = UnifyRecords(stim,spike)
% UnifyRecords: combine responses from different files
% Appropriate when different files contain the same set
% of odorants.
% [ustim,uspike] = UnifyRecords(stim,spike)
nrec = size(stim,1);
if (size(spike,1) ~= nrec)
	error('Inputs must have same number of records!');
end
nvalves = size(stim,2);
ncells = size(spike,3);
ustim = cell(1,nvalves);
uspike = cell(nvalves,ncells);
for j = 1:nvalves
	ustim{j} = {};
	for i = 1:nrec
		ustim{j} = {ustim{j}{:},stim{i,j}{:}};
	end
	for k = 1:ncells
		uspike{j,k} = {};
		for i = 1:nrec
			uspike{j,k}{:};
			spike{i,j,k}{:};
			uspike{j,k} = {uspike{j,k}{:},spike{i,j,k}{:}};
		end
	end
end
