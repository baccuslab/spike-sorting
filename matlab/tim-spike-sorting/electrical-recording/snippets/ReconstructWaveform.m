function [w,tout] = ReconstructWaveform(snip,tin,sniprange,trange)
% ReconstructWaveform: go from snippets back to raw waveform
% Regions with no data get set to 0
% [w,tout] = ReconstructWaveform(snip,tin,sniprange,trange)
% 	where
%		snip is the matrix of snippets (columns are individual snippets)
%		tin is the time for each snippet
%		sniprange is the 2-vector [tsnipbegin,tsnipend] relative to peak
%		trange (optional) is a 2-vector [tbegin,tend] giving the time range
%			of the reconstruction
%
%		w is the  is the output waveform,
%		tout is the output time
%		where w(i) is the voltage at time tout(i)
%		Both w and tout will contain values only in places where
%		there is data, other than 0 flanking values
%		
% All times are measured in scan #!
if (length(tin) ~= size(snip,2))
	error('On input, the number of snippets must equal the number of times');
end
if (nargin < 4)
	trange = [min(tin)+sniprange(1),max(tin)+sniprange(2)];
end
trpeak = trange-sniprange;
indx = find(tin >= trpeak(1) & tin < trpeak(2));	% Consider only snippets within interval
width = size(snip,1);
nsnips = length(indx);
if (nsnips == 0)
	w = [];
	tout = [];
	return;
end
% Create a matrix tm of times, where snip(i,j) is the 
% voltage at time tm(i,j).
tsnip = (sniprange(1):sniprange(2))';
tsnipm = repmat(tsnip,1,nsnips);
tm = repmat(tin(indx)',width,1) + tsnipm;
% Now convert our matrices into linear sequences
toutfull = reshape(tm,1,width*nsnips);
[tout,uindx] = unique(toutfull);
snipfull = reshape(snip(:,indx),1,width*nsnips);
w = snipfull(uindx);
% Look for gaps in the time, and set waveform value to zero there
gapindx = find(diff(tout) > 1);
ztime = [tout(gapindx)+1,tout(gapindx+1)-1,trange,tout(1)-1,tout(end)+1];	% Make sure endpoints also get zeroed, if necessary
[tout,sindx] = unique([ztime,tout]);
wz = [zeros(size(ztime)),w];
w = wz(sindx);
