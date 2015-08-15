function stimout = RescueStim(stimin,scanrate)
% Some serious surgery for a case when I forgot to
% turn on the D/A converter, and the stimulus channels
% was massively corrupted.
vlv = stimin(1,:);
t = stimin(2,:);
% Kill any -1s we might find
badi = find(vlv == -1);
vlv(badi) = [];
t(badi) = [];
% First, find the 0->1->0 transitions which mark the beginning of a stimulus cycle
dt = diff(t);
vlvsl = [vlv(2:length(vlv)),0];
vlvsr = [0,vlv(1:length(vlv)-1)];
zozi = find(vlvsl == 0 & vlv == 1 & vlvsr == 0);
%fprintf('length(zozi) = %d\n',length(zozi));
badi = find(dt(zozi) < 0.006*scanrate | dt(zozi) > 0.014*scanrate);	% Must be transitions near 0.01s long
zozi(badi) = [];
% The other criterion is that these should be approx. periodic
if (length(zozi) > 2)
	dtzozi = diff(t(zozi));
	dtzozi = sort(dtzozi);
	cyclelen = dtzozi(end-1);	% Next-to-largest
	tzoziest = t(zozi(1)) + cyclelen*(0:length(zozi)-1);
	tzoziest
	t(zozi)
	badi = [];
	for i = 1:length(zozi)
		hit = find(abs(tzoziest - t(zozi(i)))/cyclelen < 0.05);	%within 5%
		if (length(hit) == 0)
			badi(end+1) = i;
		end
	end
	zozi(badi) = [];
end
format short e
t(zozi)+1e-9
dt(zozi)
format
hfig = figure;
hold on
stairs(t,vlv);
line(t(zozi),ones(1,length(zozi)),'LineStyle','none','Color','r','Marker','.','MarkerSize',16);
% Now find the transition times for the stimulus
% Define these as points at which the valve # changes
% in the same direction (+ or -) for 2 consecutive changes
cpi = find(vlv < vlvsl & vlvsr < vlv);
cmi = find(vlv > vlvsl & vlvsr > vlv);
% Occassionally one actually gets the right answer straight from
% CalcStim; spot these by the criterion that the valve # should change
% by more than 1 value
dv = diff(vlv);
cpi = union(cpi,find(dv > 1)+1);
cmi = union(cmi,find(dv < -1)+1);
%figure
%plot(t,[vlvsl'-2,vlv',vlvsr'+2]);
%hold on
%line(t(cpi),1.25*ones(1,length(cpi)),'LineStyle','none','Color','g','Marker','.','MarkerSize',16);
%line(t(cmi),1.75*ones(1,length(cmi)),'LineStyle','none','Color','m','Marker','.','MarkerSize',16);
%figure(hfig)
% Now consolidate this information; first, the valve # often "bounces",
% so get rid of positive-going traces that immediately follow negative-going,
% and vice versa
dtmin = 0.1*scanrate;		% The definition of "immediate"
for i = 1:length(cpi)
	badm = find(t(cmi) > t(cpi(i)) & t(cmi) < t(cpi(i))+dtmin);
	cmi(badm) = [];
end
	line(t(cmi),ones(1,length(cmi)),'LineStyle','none','Color','m','Marker','.','MarkerSize',16);
for i = 1:length(cmi)
	badp = find(t(cpi) > t(cmi(i)) & t(cpi) < t(cmi(i))+dtmin);
	cpi(badp) = [];
end
% The only kind that leaks through now is the last upward blip on
% the valve-open peaks. Get rid of these.
cmi1 = cmi-1;
bad = find(cmi1 < 1);	% Make sure don't get invalid index
cmi1(bad) = [];
badm = find(vlvsl(cmi1) == vlvsr(cmi1));	% A blip returns to previous value
[dummy,testindx] = intersect(cmi(1:end-1),cmi1(badm)+1);
dcmi = diff(cmi);
killii = find(dcmi(testindx) == 1);			% The last upward blip should be followed by a downward valve transition
cmi(testindx(killii)) = [];
% Now consolidate nearby valve steps to determine
% the actual valve opening points
% Choose the first of a block as the actual time
dtcpi = diff(t(cpi));
killpi = find(dtcpi < dtmin)+1;
cpi(killpi) = [];
dtcmi = diff(t(cmi));
killmi = find(dtcmi < dtmin)+1;
cmi(killmi) = [];
checki = 1;
while (length(cmi) ~= length(cpi) & length(checki) > 0)
	len = min(length(cmi),length(cpi));
	timeon = t(cmi(1:len))-t(cpi(1:len));
	checki = find(abs(timeon-timeon(1))/timeon(1) > 0.1);
	if (length(checki) > 0 & length(cmi) > length(cpi))
		cmi(checki(1)) = [];
	elseif (length(checki) > 0 & length(cmi) < length(cpi))
		cpi(checki(1)) = [];
	%else
	%	error('length(checki) = 0, but still mismatch');
	end
end
if (length(cpi) ~= length(cmi))
	line(t(cpi),ones(1,length(cpi)),'LineStyle','none','Color','g','Marker','.','MarkerSize',16);
	line(t(cmi),ones(1,length(cmi)),'LineStyle','none','Color','m','Marker','.','MarkerSize',16);
	fprintf('length(cmi) = %d, length(cpi) = %d\n',length(cmi),length(cpi));
	t(cmi(1:len))-t(cpi(1:len))
	XZoomAll
	error('cpi & cmi do not have the same length');
	%cpi(end) = [];
end
% We have made real progress!
% Now figure out which valves are open and for how long between
% cpi/cmi pairs
% The top 1 or 2 total times determine the valve #: if there's only
% 1 open for most of the time, then that's the valve # (exception: valves 10 & 11
% occassionally reads _only_ one higher); if there are 2 open for much of the time,
% choose the lower value
for i = 1:length(cmi)
	valvet = zeros(1,13);
	for j = cpi(i):cmi(i)
		valvet(vlv(j)) = valvet(vlv(j)) + dt(j);
	end
	major = find(valvet > dtmin);
	if (length(major) == 1)
		v(i) = major;
		if (v(i) > 9)
			v(i) = major-1;
		end
	elseif (length(major) == 2)
		v(i) = min(major);
	else
		error(sprintf('More than 2 major valves on i = %d',i));
	end
end
% Now put it all together to make a stim matrix
% First do the valves
stimout = [];
for i = 1:length(cpi)
	stimout(1:2,end+1) = [v(i);t(cpi(i))];
	stimout(1:2,end+1) = [0;t(cmi(i))];
end
% Now do the indicators
for i = 1:length(zozi)
	stimout(1:2,end+1) = [1;t(zozi(i))];
	stimout(1:2,end+1) = [0;t(zozi(i)+1)];
end
% Put everything in order
[tdummy,indx] = sort(stimout(2,:));
stimout = stimout(:,indx);
% Now prepend & postpend zeros
stimout = [[0;1],stimout,[0;t(end)]];
stairs(stimout(2,:),stimout(1,:),'g');
