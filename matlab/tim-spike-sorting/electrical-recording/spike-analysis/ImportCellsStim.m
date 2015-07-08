function [cells,stim,files,chandef] = ImportCellsStim(shapefilename,stimfilename)
% ImportCellsStim: read in results of shape-based spike sorting & stimulus information
% [cells,stim,files,chandef] = ImportCellsStim(shapefilename,stimfilename)
% Outputs:
%	cells{filenumber,cellnumber} is the time (in secs) of the spikes of given cell in given file
%	stim{filenumber} is the stimulus record for a given file (times in secs), a 2-by-n matrix
%		of valve #s and times of the format of ReadVlv
%	files: a cell arrary containing the list of files common to both the shapefile & stimfile
%	chandef: the channel number on which each cell was defined
[stimfiles,stim] = ReadVlv(stimfilename);
fprintf('Loading shape file...\n');
load(shapefilename)
% File order in stimfile & shapefiles may not be equivalent (and there
%	may not be complete overlap). Compare them, and use the ordering
%	from the spikefile
for i = 1:length(spikefiles)
	sftrunc{i} = strtok(spikefiles{i},'.');
end
[temp,spikeindx,stimindx] = intersect(sftrunc,stimfiles);	% Work with common files
[spikeindx,I] = sort(spikeindx);			% Use the order in spikefiles
stimindx = stimindx(I);
files = sftrunc(spikeindx);
nfiles = length(spikeindx);
% Saved format is indexed by channel number. Figure out which
% channel each cell came from, and wipe out the channels
% with no cells
bi = [];
chandef = [];
for i = 1:length(chanclust)
	li = size(chanclust{i},1);
	if (li == 0)
		bi(end+1) = i;		% These are the channels that had no cells
	else
		chandef(end+1:end+li) = channels(i);
	end
end
chanclust(bi) = [];
% Now index by cell #
cells = cat(1,chanclust{:})';
ncells = size(cells,2);
% Keep only the relevant files
cells = cells(spikeindx,:);
stim = stim(stimindx);
scanrate = scanrate(spikeindx);	% just for convenience
% Now convert time to seconds
for i = 1:nfiles
	stim{i}(2,:) = stim{i}(2,:)/scanrate(i);
	for j = 1:ncells
		cells{i,j} = cells{i,j}/scanrate(i);
	end
end
