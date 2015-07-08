function plotmm(c,pmmklog,rstimmm,errmm)
minmax = [c(1)*0.9,c(end)*1.1];
c0 = logspace(log10(minmax(1)),log10(minmax(2)),100);
km = pmmklog(2);
rprop = pmmklog(3);
logKm = pmmklog(4:5);
kp = c0'*km*exp(-logKm)';
rstim = rprop*kp./(kp+km);
cla
set(gca,'NextPlot','add','ColorOrder',[1 0 0;0 0 1],'XScale','log','XLim',minmax);	% red = female, blue = male
plot(c0,rstim);
errorbarlog([c' c'],rstimmm,errmm,'x');
