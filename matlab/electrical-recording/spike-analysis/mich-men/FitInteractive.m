function [pbest,chi2,dof,C,keep] = FitInteractive(spikes,trange,pvar,varloc,pfix,fixloc,nparms,ratefunc,irate,pcheckfunc,dt,varnames,cellnum,skewtol)
% FitInteractive: GUI for interactively fitting PSTRate data
% [pbest,chi2,dof,C] = FitInteractive(spikes,trange,pvar,varloc,pfix,fixloc,nparms,ratefunc,irate,pcheckfunc,dt,varnames,cellnum,skewtol)
% First do the graphical data binning
[texp,rexp] = PlotdataPSTRate(spikes,trange,pvar,varloc,pfix,fixloc,nparms,ratefunc,dt);
nexp = length(spikes);
dims = [nparms nexp];
% Set up the axes, making room for buttons along the top
spdims = CalcSubplotDims(nexp);
hfig = figure('Position',[150   117   677   602]);
if (nargin >= 13)
	set(hfig,'Name',sprintf('Cell %d',cellnum),'NumberTitle','off');
end
hax1 = subplot(spdims(1),spdims(2),1);
postemp = get(hax1,'Position');
left = postemp(1);
% Now draw most the user interface tools
%left = pos{1}(1);
if (nargin > 11 & length(varnames) == length(pvar))
	popstr = varnames;
else
	popstr = num2str((1:length(pvar))');
end
hchitxt = uicontrol('Units','normalized','Position',[left 0.93 0.2 0.04],'Style','text',...
	'String','Temp','Tag','chitext');
hpop = uicontrol('Units','normalized','Position',[left 0.89 0.2 0.04],'Style','PopupMenu',...
	'Callback','FitInteractiveCB ChooseParm','String',popstr,'Tag','ParmMenu','Value',1);
heb = uicontrol('Style','edit','Units','normalized','Position',[left+0.25 0.9 0.2 0.07],...
	'String',num2str(pvar(1)),'Callback','FitInteractiveCB ChangeParm','Tag','ParmBox',...
	'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
hfit = uicontrol('Units','normalized','Position',[left+0.5 0.9 0.12 0.07],'Style','PushButton',...
	'Callback','FitInteractiveCB Fit',...
	'String','Optimize');
hdone = uicontrol('Units','normalized','Position',[left+0.65 0.9 0.12 0.07],'Style','PushButton',...
	'Callback','FitInteractiveCB Done',...
	'String','Done');
% Now really do the axes
for i = 1:nexp
	hax(i) = subplot(spdims(1),spdims(2),i);
end
pos0 = get(hax,'Position');
if (nexp == 1)
	pos0 = {pos0};
end
pfac = [1 0.9 1 0.9];
for i = 1:nexp
	pos{i} = pos0{i}.*pfac;	% Shrink them all
end
set(hax,{'Position'},pos');
% Do the binning
if (nargin < 14)
	skewtol = 0.3;
end
for i = 1:nexp
	[tsplit{i},mn{i},err{i},sk{i}] = SplitGauss(spikes{i},skewtol);
end
keep = zeros(1,nexp);
dof = 0;
for i = 1:nexp
	if (length(sk{i}) > 1 | sk{i}(1) < skewtol)
%		if (isempty(find(i == [13:16 29:32])))		% KLUGE! To get rid of U/30 experiments. Cancel this
			keep(i) = 1;
			dof = dof+length(tsplit{i});
%		end
%	else
%		set(hax(i),'Color',[0.8 0.8 0.8]);
	end;
end;
% Put in the checkboxes
for i = 1:nexp
	postemp = pos{i};
	hcheck(i) = uicontrol('Units','normalized','Position',[postemp(1:2)+postemp(3:4),.025,0.025],'Style','checkbox',...
	'Callback','FitInteractiveCB Keep','max',1,'min',0,'Value',keep(i));
end
% Record all the information in the UserData property of the figure
Data.trange = trange;
Data.varloc = varloc;
Data.pfix = pfix;
Data.fixloc = fixloc;
Data.nexp = nexp;
Data.nparms = nparms;
Data.dims = dims;
Data.texp = texp;
Data.rexp = rexp;
Data.ratefunc = ratefunc;
Data.ifunc = irate;
Data.pcheckfunc = pcheckfunc;
Data.hax = hax;
Data.pcur = pvar;
Data.tsplit = tsplit;
Data.mn = mn;
Data.err = err;
Data.keep = keep;
Data.hcheck = hcheck;
C = -1;
Data.C = -1;
chi2 = -1;
Data.opt = 0;
set(hfig,'UserData',Data)
FitInteractiveCB('Refresh',hfig);
uiwait;
if (ishandle(hfig))
	Data = get(hfig,'UserData');
	pbest = Data.pcur;
	if (isfield(Data,'chi2'))
		chi2 = Data.chi2;
		C = Data.C;
	end
	keep = Data.keep;
	close(hfig);
end
