function [stim,envs,files] = ResponseEnvs(stimfile,trange)
% ResponseEnvs: cut out envelopes from periods with stimulus
% [stim,envs] = ResponseEnvs(stimfile,trange)
% See CollectResponses for format of stim.
% envs: env{fileindx,vlvnum,channelnum}{rptnum} 
%	is a 2-by-n matrix of min/max pairs
[stimfiles,stim] = ReadVlv(stimfile);
for i = 1:length(stim)
	keepstim{i} = CleanStim(stim{i});
end
% Much of the following is just copied from CollectResponses
nvalves = 12;
stim = cell(nrec,nvalves);
spike = cell(nrec,nvalves,ncells);
toSecs = 50e-6;
for j = 1:nrec
	evT = rec{j}.evT*toSecs;
	for i = 1:nvalves
		vindx = find(rec{j}.evP == i);
		nrpt = length(vindx);
		stim{j,i} = cell(1,nrpt);
		for k = 1:nrpt
			ttransition = evT(vindx(k));
			currange = ttransition + trange;
			% First cut out a snippet of the stimulus
			tindx = find(evT >= currange(1) & evT <= currange(2));
			previndx = max([tindx(1)-1,1]); postindx = min([tindx(end)+1,length(evT)]);
			temp = [rec{j}.evP(previndx:postindx); evT(previndx:postindx)];
			temp(2,1) = currange(1);
			temp(2,end) = currange(2);
			temp(1,end) = temp(1,end-1);
			stim{j,i}{k} = temp;
			% Now cut envelopes from all channels
			
