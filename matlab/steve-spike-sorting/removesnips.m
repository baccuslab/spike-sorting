function snipsout =removesnips(snipsin,snipsremoved)
%Removes a list of snippets from snipsin
%assumes snipsin and snipsremoved are 1 x fnum cell arrays
%Uses function "logical" to creates logical arrays for snipsin and snipsremoved,
%uses logical operators to remove unwanted snippets,
%and then uses function "find" to return nonzero indices, which are the remaining snippet numbers.
	for fnum=1:size(snipsin,2)
		maxsnipnum=max([max(snipsin{1,fnum}) max(snipsremoved{1,fnum})]);
		inlog (1:maxsnipnum)   =logical(0); %create logical arrays
		remlog(1:maxsnipnum)=logical(0);
		inlog(snipsin{1,fnum})=1;
		remlog(snipsremoved{1,fnum})=1;
		outlog=inlog&~remlog;			%remove unwanted snippets
		snipsout{1,fnum}=find(outlog);		%find nonzero indices
		clear inlog
		clear remlog
	end
		
	
