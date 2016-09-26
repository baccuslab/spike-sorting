function hline = PlotBundledStim(stim,toff)
% PlotBundledStim: plot stimulus time courses
% hline = PlotBundledStim(stim,toff)
% 	stim is of the format CollectResponses/UnifyResponses
%	toff (optional) is the offset time (defaults to 0)
%
%	The output hline is the vector of line handles
if ~iscell(stim)
	error('stim must be cell arrays of cell arrays, one bundle/cell');
end
if (nargin < 2)
	toff = 0;
end
nbundles = length(stim);
nrpts = zeros(1,nbundles);
for i = 1:nbundles
	nrpts(i) = length(stim{i});
end
cnrpts = cumsum(nrpts);
nrptstot = cnrpts(end);
bindx = [0 cnrpts];
% Compute the time range, as the maximum range in stim
% Also get the maximum value of the stimulus trace
%allstim = cat(2,stim{:});
%tr = zeros(nrptstot,2);
%for i = 1:nrptstot
%	tr(i,:) = allstim{i}(2,[1 end]);
%end
%tmax = max(diff(tr'));
% Do the necessary graphics preliminaries
newplot
co = get(gca,'ColorOrder');
ncol = size(co,1);
%set(gca,'XLim',[0 tmax]+toff);
hold on
% Plot the stimulus traces
for i = 1:nbundles
	colindx = mod(i-1,ncol)+1;	% Wrap-around color indices
	for j = 1:nrpts(i)
		k = j+bindx(i);
		temp = stim{i}{j};
		hlinetemp(k) = stairs(temp(2,:)-temp(2,1)+toff,temp(1,:));
		set(hlinetemp(k),'Color',co(colindx,:));
	end
end
hold off
axis tight
if (nargout > 0)
	hline = hlinetemp;
end
