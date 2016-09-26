function  [record,recfiles,cells,chandef]=ConvertToCell(shapefilename)
% ConvertToCell: convert sorted spikes to Cell File format
%  ConvertToCell(stimfile,shapefilename,ctfilename)

load(shapefilename)
if (~exist('chanclust'))
	chanclust=g.chanclust;
	snipfiles=g.snipfiles;
	channels=g.channels;
	scanrate=g.scanrate;
end
%Loop across files
for fileno = 1:length(snipfiles)
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
	cells = cells(:,fileno);
	ncells = size(cells,1);
	% Now put into cell file format
	% The most significant step is to convert the times from
	% scan #s to time units (50e-6 secs)
	evch=find(channels==2); %event channel
	toSecs = 50e-6;
	%WRITE EVENT PULSES WITH ONLY ONE PEAK VALUE
	if (~isempty(evch) & size(cells,2)>=evch & ~isempty(cells{evch}))
		stim(2,:)=cells{evch};
		stim(1,:)=1;
		record{1}.evT = stim(2,:)/(toSecs*scanrate);
		record{1}.evP = stim(1,:);
		record{1}.evW = record{1}.evP;
		stmax = max(stim(2,:));
	else
		record{1}.evT = 0;
		record{1}.evP = 0;
		record{1}.evW=0;
	end
	%fprintf('Stimtime max: %d\nSpike time maxs: ',stmax);
	for j = 1:ncells
		record{1}.T{j} = cells{j}'/(toSecs*scanrate);
		%	fprintf(' %1.3f',max([0;cells{j,spindx(i)}])/stmax);
	end
	%fprintf('\n');
	%Write cell file
	sftrunc = strtok(snipfiles{fileno},'.');
	outfilename=[strtok(shapefilename,'.') '.' strtok(snipfiles{fileno},'.') '.cell' ];
	WriteCellFile(outfilename,record,chandef,'nowrap')
	clear record chandef stim
end %Loop across files
