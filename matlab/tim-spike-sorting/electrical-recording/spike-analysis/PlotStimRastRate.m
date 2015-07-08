function PlotStimRastRate(record,cellnum,width)
% PlotStimRastRate(record,cellnum,width)
fig = figure;
set(fig,'Position',[ 54   337   600   383]);
col1w = 0.9;
col1l = 0.05;
trange = GetRecTimeRange(record);
hs = axes('Position',[col1l,0.85,col1w,0.07]);
PlotStimNum(record,trange,hs)
hrast = axes('Position',[col1l,0.40,col1w,0.4]);
PlotRast(record,cellnum,trange,hrast)
hrate = axes('Position',[col1l,0.1,col1w,0.25]);
PlotRate(record,cellnum,width,trange,hrate)
axes(hrate)
xlabel('Time (s)')
axes(hs)
title(['Cell ' num2str(cellnum)])
XZoomAll
