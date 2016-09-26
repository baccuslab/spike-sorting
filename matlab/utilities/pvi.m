function pvi;
scanrate=10000;
[file,path] = uigetfile('*','Select raw data file');
prompt={'Enter channel list:'};
chs=str2num(char(inputdlg(prompt)));
prompt={'Enter time in seconds:'};
tmax=str2num(char(inputdlg(prompt)));
tmax
[fid,message] = fopen([path,file],'r');
if (fid < 1)
	error(message)
end
%header = ReadAIHeaderAncient(fid);
header = ReadAIHeader(fid);
[data,h] = loadlist(fid,header,chs,tmax);


%Threshold extracellular recordings.
%Do not threshold Ch0, Vm, Ch1, the current trace or Ch2, the light stim.
for chn=1:size(chs,2)
	if  chs(chn)~=0 & chs(chn)~=1 & chs(chn)~=2
	%	thresh=0*median(abs(data(chn,:)));
	%	data(chn,:)=data(chn,:)-thresh;
	%	data(chn,:)=(sign(data(chn,:))+1).*data(chn,:)/2;
	end
end
Imch = -1;
for chn=1:size(chs,2)
	if chs(chn)==0 
        Imch=chn;
		b=1;
		keyboard
%		a=[1 -0.99];
%		data(chn,:)=filter(b,a,data(chn,:))/100;
    end
end
for chn=1:size(chs,2)
	if chs(chn)==0 & Imch>0
		data(chn,:)=data(chn,:)-data(Imch,:)*50;
	end
end
%Digital bridge balancing
Relectrode = 0;
for chn=1:size(chs,2)
	if (chs(chn)==0) & (Imch >0) 
        Vmraw=data(chn,:);
		data(chn,:)=data(chn,:)-(data(Imch,:)*Relectrode);
	end
end


size(data,2)

%dlmwrite('101199 3.bin data',data',' \t');

keyboard

df=floor(size(data,2)/50000)+1;
df=1;
if df==1 df=2; end;
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
figure('Position',scnsize)
set(gcf,'DefaultAxesPosition',[0.05,0.1,0.93,0.85])
set(gcf,'Color',[1 1 1])
numpoints= floor(size(data,2)/df);
xrange = [1,numpoints*df];
%t = 0:df/scanrate:(numpoints-1)*df/scanrate;    %For time on x axis
t = 0:df:(numpoints-1)*df;  %For scan# on x axis
for chn = 1:size(chs,2)
	if df > 1
		env_max=max(reshape(data(chn,xrange(1):xrange(2)),df,numpoints));
	else
		env_max = data(chn,xrange(1):xrange(2))
	end
	if df > 1
		env_min=min(reshape(data(chn,xrange(1):xrange(2)),df,numpoints));
    else
		env_min = data(chn,xrange(1):xrange(2))
	end
	if chs(chn)==0
		subplot ('Position',[0.05 0.8 0.93 0.17]), plot(t,env_max,'b-',t,env_min,'b-');
		else
	subplot (size(chs,2)+1,1,chn+1), plot(t,env_max,'b-',t,env_min,'b-');

keyboard
end
%	bkgndcol = get(gcf,'Color');
    axis tight
	set(gca,'Visible','off');
%	ylabel(chs(chn),'Visible','off','Rotation',0)
	set(gca,'YTick',[0],'YTickLabel','  ')
	xlabel('Time (s)')
end

figure
plot(data(1,xrange(1):xrange(2)))
% Make axes invisible on most plots
bkgndcol = get(gcf,'Color');
%set(axhndl,'XColor',bkgndcol,'YColor',bkgndcol,'Color',bkgndcol)
%set(axhndl,'Visible','off');
% Show axes on bottom row
%subax = axhndl(size(chs,2));
%set(subax,'Visible','on','XColor',[0 0 0],'YColor',[0 0 0],'YTick',[0],'YTickLabel','  ','Color',bkgndcol,'Box','off')
%vertsubplot(axhndl(size(chs)));
%ylabel(size(chs)-1,'Color',[0 0 0])
xzoomall
