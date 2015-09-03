function membership = ComputeMembership(x,y,polygons)
membership = zeros(size(x));
for i = length(polygons):-1:1			% Do it in reverse order
	if (~isempty(polygons{i}))
			in = polygon(x,y,polygons{i}.x,polygons{i}.y); %name of mexfile is polygon not pointsinpolygon
%           in = pointsinpolygon(x,y,polygons{i}.x,polygons{i}.y);
			%in = inpolygon(x,y,polygons{i}.x,polygons{i}.y);
            if ~islogical(in)
                in = logical(in);
            end
			membership(in)=i;
	end
end
