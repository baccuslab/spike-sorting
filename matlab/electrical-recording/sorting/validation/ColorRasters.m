function ColorRasters(selspikes,color)
% ColorRasters(selspikes,color)
% Add (or overwrite) colored spikes in the raster portion
% of the current figure
% selspikes is a cell array listing the times of the new/overwritten spikes
% color is the character or RGB defining the color
axes(findobj(gcf,'Tag','Rasters'));
hold on
toSecs = 50e-6;
for i = 1:length(selspikes)
	y1 = ones(1,length(selspikes{i}));
	y = [(i-0.2)*y1;(i+0.2)*y1];
	x = [toSecs*selspikes{i};toSecs*selspikes{i}];
	plot(x,y,color);
end
hold off
