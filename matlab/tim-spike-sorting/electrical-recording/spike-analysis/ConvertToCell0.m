function [record,recfiles,cells,chandef] = ConvertToCell(stimfile,shapefilename,ctfilename)
% ConvertToCell: convert sorted spikes to Cell File format
% [record,recfiles,cells,chandef] = ConvertToCell(stimfile,shapefilename,ctfilename)
if (nargin == 3)	% Load cells defined by crosstalk
	fprintf('Loading crosstalk file...\n');
	load(ctfilename)
	pairchandef = channels(pairdef);
	pcdcode = bitshift(pairchandef(:,1),8)+pairchandef(:,2);	% Store 2 channels in sep. 8-bit halves of int16
	sfct = spikefiles;	% Save this for later matching
end
[stimfiles,stim] = ReadVlv(stimfile);
fprintf('Loading shape file...\n');
load(shapefilename)
% Make crosstalk records look like shape records for later processing
% (yes, a cheap & inefficient way out)
if (nargin == 3)
	channels = [channels,pcdcode'];
	[temp,shindx,ctindx] = intersect(spikefiles,sfct);
	if (length(shindx) < length(spikefiles) | length(ctindx) < length(sfct))
		warning('Not all files were processed by both shape & CT');
	end
	[temp,iperm] = sort(ctindx);
	srct = scanrate(shindx(iperm));	% Match up scanrate info
	% Convert back to scan #s
	for i = 1:size(pairtime,1)		% Loop over cells
		for j = 1:length(ctindx)	% Loop over common files
			scannum{shindx(iperm(j))} = pairtime{i,ctindx(j)}*srct(j);
		end
		chanclust{end+1} = scannum;
	end
end
for i = 1:length(spikefiles)
	sftrunc{i} = strtok(spikefiles{i},'.');
end
[temp,stimindx,spindx] = intersect(stimfiles,sftrunc);	% Work with common files
recfiles = deblank(stimfiles(stimindx));
% Clean up stimulus information
for i = 1:length(stimindx)
	%stimfiles(stimindx(i))
	keepstim{i} = CleanStim(stim{stimindx(i)});
%	keepstim{i}
end
%spikefiles{spindx(1)}
%keepstim{1}
% Convert from channel indexing to cell# indexing
%   First delete any empty channels
%   Keep track of channel on which cell was defined
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
%   Now index by cell #
cells = cat(1,chanclust{:});
ncells = size(cells,1);
% Now put into cell file format
% The most significant step is to convert the times from
% scan #s to time units (50e-6 secs)
toSecs = 50e-6;
for i = 1:length(stimindx)
	record{i}.evT = keepstim{i}(2,:)/(toSecs*scanrate(spindx(i)));
	record{i}.evP = keepstim{i}(1,:);
	record{i}.evW = 0*record{i}.evP;
	stmax = max(keepstim{i}(2,:));
	%fprintf('Stimtime max: %d\nSpike time maxs: ',stmax);
	for j = 1:ncells
		record{i}.T{j} = cells{j,spindx(i)}'/(toSecs*scanrate(spindx(i)));
	%	fprintf(' %1.3f',max([0;cells{j,spindx(i)}])/stmax);
	end
	%fprintf('\n');
end
% Convert the times in cells to seconds
for i = 1:length(stimindx)
	for j = 1:ncells
		cells{j,i} = cells{j,i}/scanrate(spindx(i));
	end
end
