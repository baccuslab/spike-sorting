function [stimout,envout] = ResponseEnvs(stimin,envin,trange,decfactor)
% ResponseEnvs: cut out envelopes from periods with stimulus
% [stimout,envout] = ResponseEnvs(stimin,envin,trange,decfactor)
% where
%	stimin is a 2-by-n matrix giving stimulus information (see ReadVlv & CleanStim)
%	envin is a 2*nchannels-by-n matrix of envelope info (see loadFromEnv)
%	trange is the range relative to valve transitions to cut out (in scan #s)
%	decfactor is the decimation factor used in making envelopes
%
%	stimout{valvenum}{rptnum} is a stimulus snippet
%	envout{valvenum}{rptnum} is the matrix of envelope snippets

% Much of the following is just copied from CollectResponses
nvalves = 12;
nchannels = size(envin,2)/2;
stimout = cell(1,nvalves);
envout = cell(1,nvalves);
for i = 1:nvalves
	vindx = find(stimin(1,:) == i);
	nrpt = length(vindx);
	stimout{i} = cell(1,nrpt);
	envout{i} = cell(1,nrpt);
	for k = 1:nrpt
		ttransition = stimin(2,vindx(k));
		currange = ttransition + trange;
		% First cut out a snippet of the stimulus
		tindx = find(stimin(2,:) >= currange(1) & stimin(2,:) <= currange(2));
		previndx = max([tindx(1)-1,1]); postindx = min([tindx(end)+1,length(stimin(2,:))]);
		temp = [stimin(1,previndx:postindx); stimin(2,previndx:postindx)];
		temp(2,1) = currange(1);
		temp(2,end) = currange(2);
		temp(1,end) = temp(1,end-1);
		stimout{i}{k} = temp;
		% Now cut envelopes from all channels
		envrange = round(currange/decfactor);
		envindx = envrange(1):envrange(2);
		envout{i}{k} = envin(:,envindx);
	end
end
