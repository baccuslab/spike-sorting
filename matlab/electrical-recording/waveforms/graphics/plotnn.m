function plotnn(data,chname,scanrate,time)
% plotnn(data,chname,time)
% plots the given channel and its nearest neighbors
% time (optional) specifies the time range [,)
% over which to plot the channel, and defaults to the
% entire sequence
dmax = max(max(data));
dmin = min(min(data));
if (nargin == 4)
	t = time(1):1/scanrate:time(2)-1/scanrate;   %half-open interval
	xrange = round(time*scanrate)+1;
	xrange(2) = xrange(2) - 1;
else
	t = 0:1/scanrate:(size(data,2)-1)/scanrate;
	xrange = [1,size(data,2)];
end
%set(gca,'LineStyleOrder','-|:|:|:|:|:|:')
nbrs = neighbors(chname);
%plot(t,data(name2num(chname)+1,xrange(1):xrange(2)))
%hold on
%plot(t,data(nbrs+1,xrange(1):xrange(2)),':.')
%axis([t(1),t(size(t,2)),dmin,dmax])
%hold off
subplot(length(nbrs)+1,1,1)
plot(t,data(name2num(chname)+1,xrange(1):xrange(2)))
axis([t(1),t(size(t,2)),dmin,dmax])
for i = 1:length(nbrs)
	subplot(length(nbrs)+1,1,i+1)
	plot(t,data(nbrs(i)+1,xrange(1):xrange(2)),':.')
	axis([t(1),t(size(t,2)),dmin,dmax])
end
