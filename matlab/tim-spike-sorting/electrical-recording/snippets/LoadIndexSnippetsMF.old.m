function [snips,filenum,t,header] = LoadIndexSnippetsMF(filenames,chan,indx)
% LoadIndexSnippetsMF: concatenates indexed snippets from sequential files
% [snips,filenum,t,headers] = LoadIndexSnippetsMF(filenames,chan,indx)
% Much like LoadSnippetsMF, except that only a subset of the total snippets is
% returned.
% indx is a cell array with one vector/file, where the vector specifies the chosen
% subset of snippets
for i = 1:length(filenames)
	cindx = indx{i};
	if (length(cindx) > 0)
		[sniptemp,ttemp,h] = LoadSnip(filenames{i},chan,max(cindx));
		snipc{i} = sniptemp(:,cindx);
		fc{i}(1,:) = i*ones(1,length(cindx));
		fc{i}(2,:) = 1:length(cindx);
		tc{i} = ttemp(cindx);
		header{i} = h;
	else
		snipc{i} = [];
		fc{i} = [];
		tc{i} = [];
		header{i} = [];
	end
end
snips = cat(2,snipc{:});
filenum = cat(2,fc{:});
%t = cat(2,tc{:});
t = tc;
