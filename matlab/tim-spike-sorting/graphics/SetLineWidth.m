function SetLineWidth(fig,width)
% SetLineWidth(fig,width)
% For setting linewidth (for nice printouts)
allLines = findobj(get(gcf,'Children'),'type','line');
set(allLines,'LineWidth',width);
