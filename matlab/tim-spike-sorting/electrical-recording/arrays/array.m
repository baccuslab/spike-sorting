% A0 is a dummy channel
% Put a border of dummy channels all around array,
% so that subscripting works out nicer
harvardhex = [	'A0A0A0A0A0A0A0A0A0A0A0';...
				'A0A0A0A0A0A8B2B5B8C3A0';...
				'A0A0A0A0A5A7B3B6C2C4A0';...
				'A0A0A0H1B1A6B4C1C5C7A0';...
				'A0A0H7H8D1A4B7C6C8D3A0';...
				'A0H6H5H4H2F1D2D4D5D6A0';...
				'A0H3G8G6F7E4E1D8D7A0A0';...
				'A0G7G5G1F4E6E3E2A0A0A0';...
				'A0G4G2F6F3E7E5A0A0A0A0';...
				'A0G3F8F5F2E8A0A0A0A0A0';...
				'A0A0A0A0A0A0A0A0A0A0A0'];
hhxnum = name2num(harvardhex);
global arrayname;
global arraynum;
arrayname = harvardhex;
arraynum = hhxnum;
x = zeros(1,61);
y = zeros(1,61);
for i = 1:11
	for j = 1:11
		indx = hhxnum(i,j)-2;
		if indx > 0
			x(indx) = i*sqrt(3)/2;
			y(indx) = i/2+j;
		end
	end
end
figure('Position',[30   295   957   393]);
subplot(1,2,1);
%plot(x,y,'.');
for i = 1:11
	for j = 1:11
		indx = hhxnum(i,j)-2;
		if indx > 0
			text(x(indx),y(indx),num2name(hhxnum(i,j)));
		end
	end
end
axis([1 10 4 14]);
set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
title('Channel name');
subplot(1,2,2);
axis([1 10 4 14]);
%plot(x,y,'.');
for i = 1:11
	for j = 1:11
		indx = hhxnum(i,j)-2;
		if indx > 0
			text(x(indx),y(indx),num2str(hhxnum(i,j)));
		end
	end
end
set(gca,'XTickMode','manual','XTick',[],'YTickMode','manual','YTick',[]);
title('Channel number');
%axis equal
