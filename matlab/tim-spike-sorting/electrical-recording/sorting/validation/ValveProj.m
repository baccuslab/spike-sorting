function [proj,tproj] = ValveProj(filename,channel,tclust,stim)
% ValveProj: compute MaxSep projections during the course of a single
%	valve opening
% proj = ValveProj(filename,channel,tclust,stim)
% With no output argument, it plots; otherwise it returns the values
[snip,time,h] = LoadSnip(filename,channel);
% Identify the individual cells
ncells = length(tclust);
clustindx = cell(1,1+ncells);	% The first is the unassigned group
for i = 1:ncells
	[common,cindx] = intersect(time,tclust{i});
	clustindx{i+1} = cindx;
end
cindx = cat(1,clustindx{:});
clustindx{1} = setdiff(1:length(time),cindx);
% Now loop over the different times in which the valve was open
nstim = length(stim);
subsnip = cell(1,ncells+1);
if (nargout == 2)
	tproj = cell(1,ncells+1);
end
for i = 1:nstim
	tranges = stim{i}(2,[1 end]); % in seconds
	trange = round(tranges*h.scanrate);
	indx0 = find(time > trange(1) & time < trange(2));
	for i = 1:(ncells+1)
		subindx = intersect(indx0,clustindx{i});
		subsnip{i} = [subsnip{i},snip(:,subindx)];
		if (nargout == 2)
			tproj{i} = [tproj{i};time(subindx)/h.scanrate];
		end
	end
end
% Now find the best separation directions
[f,lambda] = MaxSep(subsnip);
if (nargout == 0)
	% Plot the color-coded projections
	co = get(gca,'ColorOrder');
	hold on
	for i = 1:(ncells+1)
		cindx = mod(i-1,size(co,1))+1;
		p = f(:,1:2)'*subsnip{i};
		plot(p(1,:),p(2,:),'.','Color',co(cindx,:));
	end
	hold off
else
	proj = cell(1,ncells+1);
	for i = 1:(ncells+1)
		proj{i} = f(:,1:2)'*subsnip{i};
	end
end
