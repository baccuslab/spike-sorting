function PlotRecon(snips,tsnips,tclust,sniprange,scanrate,toff)
% PlotRecon: plot the reconstruction of the waveform from snippets
% PlotRecon(snips,tsnips,tclust,sniprange,scanrate)
% All times must be in scan #s!
% The last parameter (optional) gives you the chance to
%	label the x axis in seconds
ncells = length(tclust);
clustindx = cell(1,1+ncells);	% The first is the unassigned group
for i = 1:ncells
	[common,cindx] = intersect(tsnips,tclust{i});
	clustindx{i+1} = cindx;
end
cindx = cat(1,clustindx{:});
clustindx{1} = setdiff(1:length(tsnips),cindx);
hold on
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:(ncells+1)
	if ~isempty(clustindx{i})
		[wcell,tcell] = ReconstructWaveform(snips(:,clustindx{i}),tsnips(clustindx{i}),sniprange);
		if (nargin > 4)
			tcell = tcell/scanrate;
			if (nargin == 6)
				tcell = tcell - toff;
			end
		end
		plot(tcell,wcell,'Color',co(mod(i-1,ncol)+1,:));
	end
end
