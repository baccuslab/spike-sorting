function [proj,sptimes]= savepw (sf)
	proj=cell(length(sf),1);
	sptimes=cell(length(sf),1);
	for i=1:length(sf)
		proj{i}=sf{i}(1:2,:);
		sptimes{i}=sf{i}(3,:);
	end
	
