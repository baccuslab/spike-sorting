function MultiClusterFunctions(action,hfig)
global selWidth unselWidth
handles=getappdata(gcf,'handles');
g=getappdata(handles.main,'g');
selWidth = 2;
unselWidth = 0.5;
mstyle = 's';
msize = 2;
if (nargin < 2)
	hfig = gcbf;
end
hmembership = findobj(hfig,'Tag','memberline');
delete(hmembership);
% Notes:
%	Figure contains a number of user properties with the following names:
%		clustnums:	the # assigned to each cluster (0 if unoccupied, otherwise identity)
%		polygons:	a cell array containing the vertices of all polygons
%		hlines:		handles to graphical repres. of polygons
%		x,y:		all data points
%		selectflag:	0 or 1 for each cluster
%		mode:		"density" or "scatter" plot
%		SelCb:		cluster selection callback string
%    polygons are coded by (usually) invisible lines in plots, with Tag=polygon
switch(action)
case 'DoPolygon'
	hax = gcbo;
	%mode = getappdata(hfig,'mode');
	% Prevent resizing of plot during polygon drawing
	xlm = get(hax,'XLimMode'); ylm = get(hax,'YLimMode');
	set(hax,'XLimMode','manual'); set(hax,'YLimMode','manual');
	% Tasks:
	%   Determine whether to replace the selected cluster,
	%     or start a new cluster.
	selection_type = get(hfig,'SelectionType');
	if (strcmp(selection_type,'normal'))
		mode='new';
		color='b';
	elseif (strcmp(selection_type,'extend'))
		mode='add';
		color='r';
	elseif (strcmp(selection_type,'alt'))
		mode='delete';
		color='k';
	end
	setappdata (gcf,'selectmode',mode);
	% Get necessary data
	% Reset all selections 
	%if (~replace)
	%	Unselect(hfig,selclust);
	%end
	%   Disable cluster selection callbacks, so don't select while
	%   in the middle of forming a polygon
	DisableClusterSelCb(hfig);
	%   Get selection polygon
	%[pvx,pvy] = GetSelPolygon('go',color);
	[pvx, pvy] = GetNewPolygon(color);
	
	if (~isempty(pvx))
		%   Assign cluster number to selected points, and
		%   record polygon information and clustered pts
		polygons{1}.x = pvx;
		polygons{1}.y = pvy;
		setappdata(hfig,'polygons',polygons);
		MultiClusterFunctions ('showselected');
	end
	if (ishandle(hfig))	% User might have hit cancel during polygon drawing
		%   Re-enable cluster selection callbacks
		EnableClusterSelCb(hfig);
		set(hax,'XLimMode',xlm); set(hax,'YLimMode',ylm);	% Restore previous state
	end
case 'SelectCluster'
	hclustline = gcbo;
	hax = get(hclustline,'Parent');
	selection_type = get(hfig,'SelectionType');
	append = 0;
	if (strcmp(selection_type,'extend'))
		append = 1;
	end
	% If not appending, de-select old selected cluster(s)
	if (~append)
		selvec = getappdata(hfig,'selectflag');
		selclust = find(selvec);
		Unselect(hfig,selclust);
	end
	% Select new cluster
	hlines = getappdata(hfig,'hlines');
	clustnum = find(hlines == hclustline);	% Figure out the corresponding cluster number
	Select(hfig,clustnum);
case 'ScatterPlot'
	hax = gca;
	axes(hax);
	setappdata(hfig,'mode','scatter');
	% First plot all the points
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	h=hax;
	%h = plot(x,y,'Color','k','LineStyle','none','Marker','.','MarkerSize',6,'HitTest','off');
	%set(h,'Color','k','LineStyle','none','Marker','.','MarkerSize',6,'HitTest','off');
	%axis tight
	set(gca,'Tag','ClustAx','ButtonDownFcn','MultiClusterFunctions DoPolygon');
	PlotPolygons(hfig);
	% Set button & slider states
	hbutton = findobj(hfig,'Tag','ScatDensButton');
	set(hbutton,'String','Density','Callback','MultiClusterFunctions DensityPlot');
	hslider = findobj(hfig,'Tag','Slider');
	set(hslider,'Visible','off');
	htext = findobj(hfig,'Tag','BinWidthText');
	set(htext,'Visible','off');
	hbutton = findobj(hfig,'Tag','ShowClustsButton');
	set(hbutton,'Visible','on');
case 'DensityPlot'
	hax = gca;
	axes(hax);
	setappdata(hfig,'mode','density');
	% Determine bin sizes
	hslider = findobj(hfig,'Tag','Slider');
	%STEVE 01/19/01 Added /10 because the bins were too big
	binsize = exp(get(hslider,'Value'))/10;
	rectx = get(hax,'XLim'); recty = get(hax,'YLim');
	nx = max(2,round((rectx(2)-rectx(1))/binsize));
	ny = max(2,round((recty(2)-recty(1))/binsize));
	% Generate & plot histogram
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	[n,xc,yc] = hist2d(x,y,[rectx recty],nx,ny);
	himage = imagesc(xc,yc,log(n+1)');
	set(gca,'YDir','normal');
	colormap(1-gray);
	axis([rectx recty]);
	set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[])
	set(himage,'HitTest','off');
	set(gca,'Tag','ClustAx','ButtonDownFcn','MultiClusterFunctions DoPolygon');
	% Draw polygons
	PlotPolygons(hfig);
	% Set button states
	hbutton = findobj(hfig,'Tag','ScatDensButton');
	set(hbutton,'String','Scatter','Callback','MultiClusterFunctions ScatterPlot');
	set(hslider,'Visible','on');
	htext = findobj(hfig,'Tag','BinWidthText');
	set(htext,'Visible','on');
	hbutton = findobj(hfig,'Tag','ShowClustsButton');
	set(hbutton,'Visible','off');
case 'Replot'
	mode = getappdata(hfig,'mode');
	if (strcmp(mode,'scatter'))
		MultiClusterFunctions('ScatterPlot',hfig);
	else
		MultiClusterFunctions('DensityPlot',hfig);
	end
case 'ShowMembership'
	mode = getappdata(hfig,'mode');
	hax = gca;
	if (strcmp(mode,'density'))
		MultiClusterFunctions('ScatterPlot',hfig);
	end
	x = getappdata(hfig,'x');
	y = getappdata(hfig,'y');
	polygons = getappdata(hfig,'polygons');
	indxs = ClusterMembers(ComputeMembership(x,y,polygons));
	for i = 1:length(indxs)
		clustcol = GetClustCol(i);
		line(x(indxs{i}),y(indxs{i}),'Marker','.','LineStyle','none','MarkerSize',12,'Color',clustcol,'Tag','memberline');
	end
case 'Clear'
	setappdata(hfig,'polygons',{});
	setappdata(hfig,'clustnums',[]);
	setappdata(hfig,'hlines',[]);
	setappdata(hfig,'selectflag',[]);
	if (strcmp(getappdata(hfig,'mode'),'density'))
		MultiClusterFunctions('DensityPlot',hfig);
	else
		MultiClusterFunctions('ScatterPlot',hfig);
	end
case 'grayscale'
	val= get(findobj(hfig,'Tag','grayslider'),'Value');
	clr=makecolormap(val,[0 0 0]);
	colormap(clr);
	drawnow
case 'displayselected'
	if (getappdata(hfig,'displaymode'))
		nsel=getappdata(hfig,'nsel');
		xc=getappdata(hfig,'xc');
		yc=getappdata(hfig,'yc');
		axh=getappdata(hfig,'axh');
		xchs=getappdata(hfig,'xchs');
		ychs=getappdata(hfig,'ychs');
		numall=getappdata(hfig,'numall');
		numsel=getappdata(hfig,'numsel');
		
		for ax=1:length(axh)
			axes (axh(ax))
			plotonetype (1.99+64*log((exp(1)-1)*nsel{ax}+1),xc{ax},yc{ax});
		end
		val= get(findobj(hfig,'Tag','grayslider'),'Value');
		clr=makecolormap(val,[1 0 0]);
		colormap(clr);
		drawnow
	else
		x=getappdata(hfig,'xall');
		y=getappdata(hfig,'yall');
		selected=getappdata(hfig,'selected');
		axh=getappdata(hfig,'axh');
		rectx=getappdata(hfig,'rectx');
		recty=getappdata(hfig,'recty');
		
		for ax=1:length(axh)
			axes (axh(ax))
			for fn=1:size(x,2)
				h=plot(x{ax,fn}(selected{ax,fn}),y{ax,fn}(selected{ax,fn}),'r.')
				set(h,'HitTest','off');
				if (fn==1) hold on; end
			end
			hold off
			xlim(rectx{ax})
			ylim(recty{ax})
			set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[])
			set(gca,'ButtonDownFcn','MultiCluster (gca)');
		end
	end
case 'displayall'
	if (getappdata(hfig,'displaymode'))
		n=getappdata(hfig,'n');
		x=getappdata(hfig,'xall');
		y=getappdata(hfig,'yall');		
		xc=getappdata(hfig,'xc');
		yc=getappdata(hfig,'yc');
		axh=getappdata(hfig,'axh');
		xchs=getappdata(hfig,'xchs');
		ychs=getappdata(hfig,'ychs');
		numall=getappdata(hfig,'numall');
		numsel=getappdata(hfig,'numsel');
		
		for ax=1:length(axh)
			axes (axh(ax))
			plotonetype (1.99+64*log((exp(1)-1)*n{ax}+1),xc{ax},yc{ax});
			xlabel(strcat(num2str(xchs(ax)),':',num2str(totlength(x(ax,:)))));
			if (ychs(ax))
				ylabel(num2str(ychs(ax)),'Rotation',0);
			end
		end
		val= get(findobj(hfig,'Tag','grayslider'),'Value');
		clr=makecolormap(val,[0 0 0]);
		colormap(clr);
		drawnow
	else
		axh=getappdata(hfig,'axh');
		rectx=getappdata(hfig,'rectx');
		recty=getappdata(hfig,'recty');
		
		for ax=1:length(axh)
			axes (axh(ax))
			for fn=1:size(x,2)
				num=ceil(9*size(x{ax,fn},2)/10);
				if (num>0)
					h=plot(x{ax,fn}(1:num),y{ax,fn}(1:num),'b.');
				end
				set(h,'HitTest','off');
				if (fn==1) hold on; end
			end
			for fn=1:size(x,2)
				num=ceil(9*size(x{ax,fn},2)/10);
				if (num>0)
					h=plot(x{ax,fn}(num:end),y{ax,fn}(num:end),'k.');
				end
				set(h,'HitTest','off');
			end
			hold off
			xlim(rectx{ax})
			ylim(recty{ax})
			set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[])
			set(gca,'ButtonDownFcn','MultiCluster (gca)');
			
		end
	end
case 'displayboth'
	xc=getappdata(hfig,'xc');
	yc=getappdata(hfig,'yc');
	n=getappdata(hfig,'n');
	nsel=getappdata(hfig,'nsel');
	axh=getappdata(hfig,'axh');
	for ax=1:length(axh)
		axes(axh(ax))
		plotselected (n{ax},nsel{ax},1,0.6,xc{ax},yc{ax});
	end
case 'displaymode'
	setappdata(hfig,'displaymode',1-getappdata(hfig,'displaymode'));
	
case 'showselected'
	polygons = getappdata(hfig,'polygons');
	xall = getappdata(hfig,'xall');
	yall = getappdata(hfig,'yall');
	curax=getappdata(hfig,'ax');
	axh=getappdata(hfig,'axh');
	rectx=getappdata(hfig,'rectx');
	recty=getappdata(hfig,'recty');
	xc=getappdata(hfig,'xc');
	yc=getappdata(hfig,'yc');
	ix=getappdata(hfig,'ix');
	n=getappdata(hfig,'n');
	xchs=getappdata(hfig,'xchs');
	ychs=getappdata(hfig,'ychs');
	hsort=getappdata(hfig,'hsort');
	mode=getappdata(gcf,'selectmode');
	selected=getappdata(gcf,'selected');
	if (size(selected,1)==0)
		selected=cell(size(xall,1),size(xall,2));
	end
	for fn=1:size(xall,2)
		pstart=1;
		pend=min(20000,length(xall{curax,fn}));
		while (pstart<=length(xall{curax,fn}))
			selpolyone = ...
			find(ComputeMembership(xall{curax,fn}(pstart:pend),...
			yall{curax,fn}(pstart:pend),polygons))+pstart-1;
			if (pstart==1)
				selpoly{fn}=selpolyone;
			else
				selpoly{fn}=[selpoly{fn} selpolyone];
			end	
			pstart=pstart+20000;
			pend=min(pend+20000,length(xall{curax,fn}));
		end
	end
	for ax=1:length(axh)
		for fn=1:size(xall,2)
			if (size(ix{curax,fn},2)>0)
				newselected=find(ismembc(ix{ax,fn},ix{curax,fn}(selpoly{fn})));
			else
				newselected=[];
			end
			if (strcmp(mode,'new'))
				selected{ax,fn}=newselected;
			elseif (strcmp(mode,'add'))
				selected{ax,fn}=intersect(selected{ax,fn}, newselected);
			elseif (strcmp(mode,'delete'))
				selected{ax,fn}=setdiff(selected{ax,fn},newselected);
			end
			if (size(xall{ax,fn},2)>0)
				[nsel1,xcsel,ycsel]=hist2d(xall{ax,fn}(selected{ax,fn}),yall{ax,fn}(selected{ax,fn}),...
				[rectx{ax} recty{ax}],length(xc{ax}),length(yc{ax}));
			else
				nsel1(length(xc{ax}),length(yc{ax}))=0;
			end
			if (fn==1) nsel{ax}=nsel1; else nsel{ax}=nsel{ax}+nsel1; end
		end
		nsel{ax}=nsel{ax}/max(max(nsel{ax}));
		axes (axh(ax));
		cla ;
		plotselected (n{ax},nsel{ax},1,0.6,xc{ax},yc{ax});
		numall{ax}=totlength(ix(ax,:));
		numsel{ax}=totlength(selected(ax,:));
		xlabel(strcat(num2str(xchs(ax)),':',num2str(numall{ax}),'(',num2str(numsel{ax}),')'));
		if (ychs(ax))
			ylabel(num2str(ychs(ax)),'Rotation',0);
		end
	end
	setappdata (hfig,'numall',numall);
	setappdata (hfig,'numsel',numsel);
	setappdata (hfig,'nsel',nsel);
	setappdata (hfig,'selected',selected);
	%Autocorrelation
	t=getappdata (hsort,'t');
	selindx=getappdata(hsort,'selindx');
	if g.pwflag
		nfiles=1;
	else
% 		nfiles=size(g.spikefiles,2);
        nfiles = length(g.snipfiles);
	end
	tsecs=cell(1,nfiles);
	for fn = 1:nfiles
		if (and(~isempty(t{fn}), ~isempty(selindx{fn})))
			tsecs{fn} = t{fn}(selindx{fn}(selected{1,fn}))/g.scanrate;
		end
	end
	acaxis=getappdata (hfig,'acaxis1');
	set(gca,'Units','pixels');
	pos = get(gca,'Position');
	npix = pos(3);
	nbins = ceil(npix/2);
	actime=0.01;
	plotac (acaxis,tsecs,actime,nbins);
	if (averagerate(tsecs)>0)
		set(gca,'Ylim',[0 averagerate(tsecs)/2]);
	end
	acaxis=getappdata (hfig,'acaxis2');
	actime=0.01;
	plotac (acaxis,tsecs,actime,nbins);
	acaxis=getappdata (hfig,'acaxis3');
	actime=1;
	plotac (acaxis,tsecs,actime,nbins);
	
	
	
case 'Revert'
	setappdata(hfig,'polygons',getappdata(hfig,'polygons0'));
	clustnums = getappdata(hfig,'clustnums0');
	setappdata(hfig,'clustnums',clustnums);
	setappdata(hfig,'selectflag',zeros(size(clustnums)));
	if (strcmp(getappdata(hfig,'mode'),'density'))
		MultiClusterFunctions('DensityPlot',hfig);
	else
		MultiClusterFunctions('ScatterPlot',hfig);
	end
case 'Cancel'
	delete(hfig);
case 'Done'
	selected=getappdata(hfig,'selected');
	h=getappdata (hfig,'hsort')
	nfiles=getappdata (hfig,'nfiles');
	close (hfig);
	clflindx = getappdata(h,'clflindx');
	channels=getappdata(h,'channels');
	selindx=getappdata (h,'selindx');
	selclust=getappdata (h,'selclust');
	indxnew=cell(2,nfiles);
	for fn=1:nfiles
		if (size (selected,2)>0)
			indxnew{1,fn}=setdiff(1:size(selindx{1,fn},2),selected{1,fn});
			indxnew{2,fn}=selected{1,fn};
		else
			indxnew{1,fn}=[];
			indxnew{2,fn}=[];
		end
	end
	% Determine the cluster #s of the newly-created clusters
	% Make replclust at least as long as # of new clusters
	% (it's OK if it's longer)
	replclust = selclust(find(selclust>1));	% Don't replace the unassigned channel
	replclust(end+1) = size(clflindx,1)+1;	% After replacing, append more clusters
	while (size(indxnew,1) > length(replclust))
		replclust(end+1) = replclust(end)+1;
	end
	% Replace the old assignments with the new, and append
	% any new clusters
	newclflindx = clflindx;	% Not strictly necessary, but useful for debugging
	for i = 1:size(indxnew,1)
		for j = 1:nfiles
			if (size(selindx{j},2)>0)
				newclflindx{replclust(i),j} = selindx{j}(indxnew{i,j});
			end
		end
	end
	if (length(replclust)-1 > size(indxnew,1))
		% Trash any clusters that got eliminated
		elim = replclust(size(indxnew,1)+1:end-1); % eliminate if selected more than returned
		newclflindx(elim,:) = [];
	end
	if (getappdata(h,'Sortstatus'))
		newclflindx(1,:) = RebuildUnassigned(getappdata(h,'clflindxall'),newclflindx);
	else
		newclflindx(1,:) = RebuildUnassigned(getappdata(h,'clflindxsub'),newclflindx);
	end
	% Store the new assignments
	setappdata(h,'clflindx',newclflindx);
	%Set updatelist to update all clusters
	updatearr(1:3,1:7)=0;
	setappdata (h,'updatearr',updatearr);
	DoMultiChanFunctions('Unselect',h);
	DoMultiChanFunctions('UpdateDisplay',h);
	DoMultiChanFunctions('SetCAxProp',h);
	
	
	
case 'KeyTrap'
	c = get(hfig,'CurrentCharacter');
	if (double(c) == 8)
		DeleteClusts(hfig);
	end
otherwise
	error(['Do not recognize action ',action]);
end
return

function Select(hfig,clustnum)
global selWidth
selvec = getappdata(hfig,'selectflag');
if (nargin < 2)
	clustnum = find(selvec);	% Will update graphical display for selected clusters
end
selvec(clustnum) = 1;
setappdata(hfig,'selectflag',selvec);
hlines = getappdata(hfig,'hlines');
hlines = hlines(clustnum);
set(hlines,'LineWidth',selWidth);
return

function Unselect(hfig,clustnum)
global unselWidth
selvec = getappdata(hfig,'selectflag');
if (nargin < 2)
	clustnum = find(selvec);	% Will unselect all clusters
end
selvec(clustnum) = 0;
setappdata(hfig,'selectflag',selvec);
hlines = getappdata(hfig,'hlines');
hlines = hlines(clustnum);
set(hlines,'LineWidth',unselWidth);
return

function DisableClusterSelCb(hfig)
hlines = getappdata(hfig,'hlines');
indx = ishandle(hlines);
set(hlines(indx),'ButtonDownFcn','');
set(hlines(indx),'HitTest','off');
return

function EnableClusterSelCb(hfig)
hlines = getappdata(hfig,'hlines');
SelCb = getappdata(hfig,'SelCb');
indx = ishandle(hlines);
set(hlines(indx),'ButtonDownFcn',SelCb);
set(hlines(indx),'HitTest','on');
return

function DeleteClusts(hfig)
selvec = getappdata(hfig,'selectflag');
selclust = find(selvec);
selvec(selclust) = 0;
setappdata(hfig,'selectflag',selvec);
clustnums = getappdata(hfig,'clustnums');
clustnums(selclust) = 0;
setappdata(hfig,'clustnums',clustnums);
polygons = getappdata(hfig,'polygons');
for i = 1:length(selclust)
	polygons{selclust(i)} = [];
end
setappdata(hfig,'polygons',polygons);
%hlines = getappdata(hfig,'hlines');
%delete(hlines(selclust));
PlotPolygons(hfig);
return

% This version of GetNextClust fills in gaps for deleted clusters
%function clustnum = GetNextClust(clustnums)
%nznums = find(clustnums);
%maxn = max(nznums);
%if (isempty(maxn))
%	maxn = 0;
%end
%avail = setdiff(1:maxn,nznums);
%if (isempty(avail))
%	clustnum = maxn+1;
%else
%	clustnum = min(avail);
%end
%return

%function clustnum = GetNextClust(clustnums)
%firstclnum = getappdata(gcf,'firstclnum');
%if (isempty(firstclnum))
%	firstclnum = 1;
%end
%clustnum = length(clustnums)+firstclnum;

function clustnum = GetNextClust(clustnums)
clustnum = length(clustnums)+1;
return

function PlotPolygons(hfig)
clustnums = getappdata(hfig,'clustnums');
clustlabels = getappdata(hfig,'ClusterLabels');
polygons = getappdata(hfig,'polygons');
SelCb = getappdata(hfig,'SelCb');
hlines = getappdata(hfig,'hlines');
isnr = find(hlines);
ish = ishandle(hlines(isnr));
delete(hlines(isnr(ish)));
hlines = zeros(size(clustnums));
txth = findobj(hfig,'Type','text');
delete(txth);			% Get rid of cluster # markers
for i = 1:length(clustnums)
	if (clustnums(i) > 0)
		hlines(i) = line(polygons{i}.x,polygons{i}.y,'Color',GetClustCol(clustnums(i)),'ButtonDownFcn',SelCb);
		text(polygons{i}.x(1),polygons{i}.y(1),num2str(GetClustLabel(clustnums(i),clustlabels)));
	end
end
setappdata(hfig,'hlines',hlines);
Select(hfig)

function clustcol = GetClustCol(clustnum)
%co = get(hax,'ColorOrder');
co = [0 0 1;0 0.65 0;1 0 0;0 0.75 0.75; 0.75 0 0.75; 0.7 0.7 0;0.5 0.5 0.5];
clustcol = co(mod(clustnum-1,size(co,1))+1,:);
return

function clustmembers = ClusterMembers(membership)
maxnum = max(membership);
clustmembers = cell(maxnum);
for i = 1:maxnum
	clustmembers{i} = find(membership == i);
end

function len=totlength (arr)
len=0;
for f=1:size(arr,2)
	len=len+length(arr{f});
end

function plotselected (n,nsel,nsc,nselsc,xc,yc)
im1=nsc-n*nsc;
im1(find(im1==nsc))=exp(1)-1;
im2=im1;
im3=im1;
im1(find(nsel>0))=exp(1)-1;
im2(find(nsel>0))=exp(nselsc-nsel(find(nsel>0))*nselsc)-1;
im3(find(nsel>0))=exp(nselsc-nsel(find(nsel>0))*nselsc)-1;
im(:,:,1)=im1';
im(:,:,2)=im2';
im(:,:,3)=im3';
set(gca,'nextplot','replacechildren')
himage = image(xc,yc,log(im+1));
set(gca,'YDir','normal');
set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[])
set(himage,'HitTest','off');
set(gca,'Tag','','ButtonDownFcn','MultiCluster (gca)');

function plotonetype (n,xc,yc)
himage = image(xc,yc,n');
set(gca,'YDir','normal');
set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[]);
set(himage,'HitTest','off');
set(gca,'Tag','','ButtonDownFcn','MultiCluster (gca)');




function plotac (h,tsecs,actime,nbins)
binwidth = actime/nbins;
nPerBin = AutoCorrRec(tsecs,actime,nbins);
xc = linspace(binwidth/2,actime-binwidth/2,nbins);
axes (h);
bar(xc,nPerBin,1,'k');
%set(gca,'XTickMode','manual','XTick',[],'YTickMode',...
%'manual','YTick',[],'Xlim',[min(xc) max(xc)]);
if (max(nPerBin)>min(nPerBin))
	set(gca,'Ylim',[min(nPerBin) max(nPerBin)]);
end
function clr=makecolormap (val,color)
if (val<=1)
	clr(:,1)=linspace(val,color(1),64)';
	clr(:,2)=linspace(val,color(2),64)';
	clr(:,3)=linspace(val,color(3),64)';
	clr(1,:)=[1 1 1];
else
	clr(:,1)=linspace(1,val-1,64)';
	clr(:,2)=linspace(1,val-1,64)';
	clr(:,3)=linspace(1,val-1,64)';
	clr(1,:)=[1 1 1];
end

