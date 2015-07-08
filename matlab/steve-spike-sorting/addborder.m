%Extends a rectangular boundary by 10% to add a border	
function [rectxout,rectyout] = addborder (rectx,recty)
	xborder=(rectx(2)-rectx(1))*0.05;
	yborder=(recty(2)-recty(1))*0.05;
	rectxout=[rectx(1)-xborder rectx(2)+xborder];
	rectyout=[recty(1)-yborder recty(2)+yborder];
