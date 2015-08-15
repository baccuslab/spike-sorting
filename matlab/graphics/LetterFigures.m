function hletters = LetterFigures(axpos,hfig)
if (nargin == 1)
	hfig = gcf;
end
hcfig = gcf;
hcax = gca;
figure(hfig);
hax = axes('Position',[0 0 1 1],'Visible','off');
nletters = length(axpos);
offset = [-0.02 0.05];
for i = 1:nletters
	tl(i,:) = [axpos{i}(1),axpos{i}(2)+axpos{i}(4)];
	curlet = char(double('a') + i-1);
	cpos = tl(i,:) + offset;
	hletters(i) = text(cpos(1),cpos(2),curlet,'Visible','on','FontWeight','bold');
end
