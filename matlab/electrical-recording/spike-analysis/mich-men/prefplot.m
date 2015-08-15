function prefplot(pin,Cin,cnum)
ncells = length(Cin);
if (size(pin,2) ~= ncells)
	error('Number of cells does not match');
end
figure
ang = linspace(0,2*pi,30);
x = sqrt(2.3)*cos(ang); y = sqrt(2.3)*sin(ang);
for i = 1:ncells
	[pout,W] = ChangeVarMMklin(pin(:,i));
	Wi = inv(W);
	Cnew = Wi'*Cin{i}*Wi;
	Cproj = Cnew(4:5,4:5);
	R = chol(Cproj);
	i,R,
	ellps = R*[x;y];
	patch(ellps(1,:) + pout(4),ellps(2,:) + pout(5),'w');
	text(pout(4),pout(5),sprintf('%d',cnum(i)));
end
xlim = get(gca,'XLim'); ylim = get(gca,'YLim');
minc = max(xlim(1),ylim(1));
maxc = min(xlim(2),ylim(2));
[minc maxc]
hold on
plot([minc maxc],[minc maxc],':k');
xlabel('Female ( Hz / rel. conc. )')
ylabel('Male ( Hz / rel. conc. )')
title('r_{prop}*k_1/k_m')
