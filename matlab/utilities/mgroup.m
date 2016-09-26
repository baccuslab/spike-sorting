function mgroup(hsort,g,sortchannels,selindx)
if (size(sortchannels,2)<2) 
	return
end
figure ('Position',[20 120 1000 680],'doublebuffer','on');
setappdata (hsort,'selindx',selindx);	
handles=getappdata(hsort,'handles');
chindices=getappdata(hsort,'chindices');
spindx=getappdata(hsort,'spindx');
% nfiles=size(g.spikefiles,2); 
nfiles = length(g.snipfiles);
% hdr=ReadSnipHeader (g.spikefiles{1});
nch=length(chindices);
% [chans,numproj,sniprange] = GetSnipNums(g.spikefiles);
if g.pwflag
	global proj
	projch=proj(chindices);
else
	%Load spike projections
	spindxsel=cell(1,nfiles);
	for fn=1:nfiles
		spindxsel{1,fn}=spindx{fn}(1,selindx{fn});
	end
	projsp=loadprojindexed('proj.bin',chindices(1),size(g.channels,2),size(g.ctfiles,2),spindxsel);
	%Load crosstalk projections
	%Get times
	t = getappdata(hsort,'t');
	tsel=cell(1,nfiles);				
% 	for fnum = 1:size(g.spikefiles,2)
    for fnum = 1:nfiles;
		tsel{1,fnum} = t{fnum}(selindx{fnum});
	end
	%Load ct snippets and calculate projections
	if (getappdata(hsort,'Storestatus'))
		snipsct=getsnipsfrommem(selindx,hsort,g.sniprange); %crosstalk is the previously loaded snippets
	else
% 		snipsct=loadaibdata (g.ctfiles,sortchannels(2:end),tsel,g.sniprange); %crosstalk is a list of files
        snipsct = loadRawData(g.ctfiles, sortchannels(2 : end), ...
            tsel, g.sniprange);
	end
	projct=cell(size(sortchannels,2)-1,size(g.ctfiles,2));
	for f=1:size(g.ctfiles,2)
		for ch=1:(size(sortchannels,2)-1)
			projct{ch,f}=g.deffilters{chindices(ch+1)}'*snipsct{ch,f};
			amp=max(snipsct{ch,f})-min(snipsct{ch,f});
			projct{ch,f}=[projct{ch,f};amp];
		end
	end
	projch=cat(1,projsp,projct);
end
t=getappdata(hsort,'t');
if (g.pwflag)
	p1=1;p2=2;p3=2;
else
	p1=1;p2=2;p3=3;
end
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[5 0 142 24], ...
'Style','slider', ...
'Min',0.2, ...
'Max',0.99, ...
'Value',0.2, ...
'Callback','MultiClusterFunctions grayscale', ...
'Tag','grayslider');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[925 5 70 30], ...
'String','Done',...
'Callback','MultiClusterFunctions Done', ...
'Tag','DoneButton');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[925 580 70 30], ...
'String','Selected',...
'Callback','MultiClusterFunctions displayselected', ...
'Tag','dispselbutton');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[925 620 70 30], ...
'String','All',...
'Callback','MultiClusterFunctions displayall', ...
'Tag','dispallbutton');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[925 540 70 30], ...
'String','Both',...
'Callback','MultiClusterFunctions displayboth', ...
'Tag','dispbothbutton');
h1 = uicontrol('Parent',gcf, ...
'Units','points', ...
'Position',[925 500 70 30], ...
'String','Display mode',...
'Callback','MultiClusterFunctions displaymode', ...
'Tag','dispmodebutton');
naxes=length(chindices)^2;
for ax=1:naxes
	rectx{ax}=[99999 -99999];
	recty{ax}=[99999 -99999];
end
ax=1;
ix=cell(naxes,nfiles);
x=cell(naxes,nfiles);
y=cell(naxes,nfiles);
for ch=1:nch
	subplot('position',getpos(nch,ax));
	axh(ax)=gca;
	for fn=1:nfiles		
		if (length(selindx{fn})>0)
			ix{ax,fn}=1:length(selindx{fn});
			x{ax,fn}=projch{ch,fn}(p1,ix{ax,fn});
			y{ax,fn}=projch{ch,fn}(p2,ix{ax,fn});
			rectx{ax}=[min([min(x{ax,fn}) rectx{ax}(1)]) max([max(x{ax,fn}) rectx{ax}(2)])];
			recty{ax}=[min([min(y{ax,fn}) recty{ax}(1)]) max([max(y{ax,fn}) recty{ax}(2)])];
		end
	end
	[rectx{ax},recty{ax}] = addborder (rectx{ax},recty{ax});
	[n{ax},xc{ax},yc{ax}] = densplot (axh(ax),x(ax,:),y(ax,:),rectx{ax},recty{ax});
	set(axh(ax),'ButtonDownFcn','MultiCluster (gca)');	
	xchs(ax)=sortchannels(ch);
	xlabel(strcat(num2str(xchs(ax)),':',num2str(totlength(x(ax,:)))));
	ax=ax+1;
end
ofs=(length(sortchannels)*(length(sortchannels)-1))/2;
for ch1=1:nch
	for ch2=ch1+1:nch
		%Plot F1 vs F1
		subplot('position',getpos(nch,ax));
		axh(ax)=gca;
		numall=0;
		for fn=1:nfiles			
			if (length(selindx{fn})>0)
				ix{ax,fn}=1:length(selindx{fn});
				x{ax,fn}=projch{ch1,fn}(p1,ix{ax,fn});
				y{ax,fn}=projch{ch2,fn}(p1,ix{ax,fn});
				rectx{ax}=[min([min(x{ax,fn}) rectx{ax}(1)]) max([max(x{ax,fn}) rectx{ax}(2)])];
				recty{ax}=[min([min(y{ax,fn}) recty{ax}(1)]) max([max(y{ax,fn}) recty{ax}(2)])];
				numall=numall+length(selindx{fn});
			end	
		end	
		[rectx{ax},recty{ax}] = addborder (rectx{ax},recty{ax});
		[n{ax},xc{ax},yc{ax}] = densplot (axh(ax),x(ax,:),y(ax,:),rectx{ax},recty{ax});
		set(axh(ax),'ButtonDownFcn','MultiCluster(gca)');
		xchs(ax)=sortchannels(ch1);
		ychs(ax)=sortchannels(ch2);
		xlabel(strcat(num2str(xchs(ax)),':',num2str(totlength(x(ax,:)))));
		ylabel(num2str(ychs(ax)),'Rotation',0);
		set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[]);
	
		%Plot F2 vs F2
		subplot('position',getpos(nch,ax+ofs));
		axh(ax+ofs)=gca;
		for fn=1:nfiles
			if (length(selindx{fn})>0)
				ix{ax+ofs,fn}=1:length(selindx{fn});
				x{ax+ofs,fn}=projch{ch1,fn}(p3,ix{ax+ofs,fn});
				y{ax+ofs,fn}=projch{ch2,fn}(p3,ix{ax+ofs,fn});
				rectx{ax+ofs}=[min([min(x{ax+ofs,fn}) rectx{ax+ofs}(1)]) max([max(x{ax+ofs,fn}) rectx{ax+ofs}(2)])];
				recty{ax+ofs}=[min([min(y{ax+ofs,fn}) recty{ax+ofs}(1)]) max([max(y{ax+ofs,fn}) recty{ax+ofs}(2)])];
			end
		end
		[rectx{ax+ofs},recty{ax+ofs}] = addborder (rectx{ax+ofs},recty{ax+ofs});
		[n{ax+ofs},xc{ax+ofs},yc{ax+ofs}] = ...
		densplot (axh(ax+ofs),x(ax+ofs,:),y(ax+ofs,:),rectx{ax+ofs},recty{ax+ofs});
		set(axh(ax+ofs),'ButtonDownFcn','MultiCluster(gca)');
		xchs(ax+ofs)=sortchannels(ch1);
		ychs(ax+ofs)=sortchannels(ch2);
		xlabel(strcat(num2str(xchs(ax+ofs)),':',num2str(totlength(x(ax+ofs,:)))));
		ylabel(num2str(sortchannels(ch2)),'Rotation',0);
		set(gca,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[]);
		ax=ax+1;
	end
end
axes ('Position',[0.03 0.8 0.11 0.11]);
setappdata (gcf,'acaxis1',gca);
axes ('Position',[0.03 0.65 0.11 0.11]);
setappdata (gcf,'acaxis2',gca);
axes ('Position',[0.03 0.5 0.11 0.11]);
setappdata (gcf,'acaxis3',gca);
setappdata (gcf,'xall',x);
setappdata (gcf,'yall',y);
setappdata (gcf,'axh',axh);
setappdata (gcf,'rectx',rectx);
setappdata (gcf,'recty',recty);
setappdata (gcf,'n',n);
setappdata (gcf,'ix',ix);
setappdata (gcf,'xc',xc);
setappdata (gcf,'yc',yc);
setappdata (gcf,'xchs',xchs);
setappdata (gcf,'ychs',ychs);
setappdata (gcf,'hsort',hsort);
setappdata (gcf,'displaymode',1);
setappdata (gcf,'nfiles',nfiles);
nsel=cell(length(axh),nfiles);
hfig=gcf;
setappdata (gcf,'handles',handles);
MultiClusterFunctions ('displayall',hfig);
%MultiClusterFunctions ('grayscale',hfig);


function len=totlength (arr)
len=0;
for f=1:size(arr,2)
	len=len+length(arr{f});
end
function [nx,ny]=bins(rectx,recty)
res=40;
binsize=min([(rectx(2)-rectx(1))/res (recty(2)-recty(1))/res]);
nx = max(2,round((rectx(2)-rectx(1))/binsize));
ny = max(2,round((recty(2)-recty(1))/binsize));

function [n,xc,yc]=densplot (h,x,y,rectx,recty)
if ((rectx(1)>=rectx(2))|(recty(1)>=recty(2)))
	return
end
axes(h);
% Generate & plot histogram
xlim(rectx);
ylim(recty);
clear n;
for f=1:length(x)
	if (length(x{f})>1)
		[n1,xc,yc] = hist2d(x{f},y{f},[rectx recty],100,100);
		if (exist('n')) n=n+n1; else n=n1; end
	end
end
n=n/max(max(n));
himage = imagesc(xc,yc,log(n+1)');
set(h,'YDir','normal');
colormap(1-gray);
set(h,'XTickLabel',{''},'xtick',[],'YTickLabel',{''},'Ytick',[]);
set(himage,'HitTest','off');

function pos=getpos (nch,ax)
	left=0.2;right=0.9;top=1;bottom=0.03;
	width=(right-left)/nch;height=(top-bottom)/nch;
	pos(1)=left+mod(ax-1,nch)*width;
	pos(2)=top-floor((ax-1)/nch)*height-height;
	pos(3)=width*0.9;
	pos(4)=height*0.9;
