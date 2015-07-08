function MovieValveProj(proj,tproj,stim,dt,tclip)
frameinterval = 0.1;
if (nargin < 4)
	dt = 1;		% Default advance by 1s
end
if (nargin < 5)
	tclip = 2;	% 2s long clips
end
figure('BackingStore','off');
%figure('DoubleBuffer','on');
pall = cat(2,proj{:});
xlim = [min(pall(1,:)) max(pall(1,:))];
ylim = [min(pall(2,:)) max(pall(2,:))];
set(gca,'XLim',xlim,'YLim',ylim,'NextPlot','add');%,'Drawmode','fast')
nstim = length(stim);
ncells = length(proj);
co = get(gca,'ColorOrder');
ncol = size(co,1);
hline = zeros(1,ncells);
for i = 1:ncells
	colindx = mod(i-1,ncol)+1;
	hline(i) = line('Color',co(colindx,:),'Marker','.','LineStyle','none',...
		'Erase','background','MarkerSize',16);
end
tic
for i = 1:nstim
	pause(2);
	tcur = stim{i}(2,1);
	tend = stim{i}(2,end);
	while (tcur + tclip < tend)
		ctime = toc;
		for j = 1:ncells
			keepi{j} = find(tproj{j} >= tcur & tproj{j} < tcur+tclip);
		end
		for j = 1:ncells
			kp = proj{j}(:,keepi{j});
			set(hline(j),'XData',kp(1,:),'YData',kp(2,:));
		end
		tcur = tcur+dt;
		while (toc < ctime + frameinterval), end		% Even the frame rate
		drawnow;
	end
end

	
