function [catrec,catheader] = ConcatenateSpikeRecords(recs,header)
% catrec = ConcatenateSpikeRecords(recs)
% Reformat a SpikeFile (format 1) by concatenating all records.
catrec.StartClock = recs{1}.StartClock;
catrec.EndClock = recs{end}.EndClock;
catrec.TotalNSpikes = 0;
catrec.NSpikes = zeros(length(recs{1}.T),1);

catrec.T = cell(length(recs{1}.T),1);	% cell array of NChannels
catrec.W = cell(length(recs{1}.W),1);
catrec.P = cell(length(recs{1}.P),1);
for c = 1:length(catrec.T)
	catrec.T{c} = zeros(1,1);
	catrec.W{c} = zeros(1,1);
	catrec.P{c} = zeros(1,1);
end

for i=1:length(recs)

	catrec.TotalNSpikes = catrec.TotalNSpikes + recs{i}.TotalNSpikes;
	
	for c = 1:length(catrec.T)
		catrec.NSpikes(c) = catrec.NSpikes(c) + recs{i}.NSpikes(c);
		catrec.T{c} = [catrec.T{c}, recs{i}.T{c}];	% append new spikes to each channel
		catrec.P{c} = [catrec.P{c}, recs{i}.P{c}];
		catrec.W{c} = [catrec.W{c}, recs{i}.W{c}];
	end
	
end

catheader = header;
catheader.NRecords = 1;
catheader.LengthClock = catrec.EndClock - catrec.StartClock;

return
