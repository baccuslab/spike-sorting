function ViewReconstruction(snips,tsnips,tclust,sniprange,trange)
fview = figure('Position',[21   475   961   231]);%,...
%fslide = figure('Position',[21 341 961 100]);
if (nargin < 5)
	trange = [0,tsnips(end)+sniprange(2)];
end
ncells = length(tclust);
% Build the unassigned group
clustindx = cell(1,ncells);	% The first is the unassigned group
for i = 1:ncells
	if (nargin < 6)
		[common,cindx] = intersect(tsnips,tclust{i});
		clustindx{i+1} = cindx;
	else
		clustindx{i} = tclust{i};
	end
end
if (nargin < 6)
	cindx = cat(1,clustindx{:});
else
	cindx = cat(2,clustindx{:});
end
clustindx{1} = setdiff(1:length(tsnips),cindx);
keyboard
% Reconstruct waveforms
for i = 1:(ncells+1)
	[wcell{i},tcell{i}] = ReconstructWaveform(snips(:,clustindx{i}),tsnips(clustindx{i}),sniprange,trange);
end
hold on
co = get(gca,'ColorOrder');
ncol = size(co,1);
for i = 1:(ncells+1)
	plot(tcell{i},wcell{i},'Color',co(mod(i-1,ncol)+1,:),'HitTest','off','EraseMode','none');
end
SliderWindow(gca);
