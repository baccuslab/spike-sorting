function FitInteractiveCB(action,hfig)
%action
if (nargin < 2)
	hfig = gcbf;
end
Data = get(hfig,'UserData');
switch(action)
case 'ChooseParm'
	v = get(findobj(hfig,'Tag','ParmMenu'),'Value');
	heb = findobj(hfig,'Tag','ParmBox');
	set(heb,'String',num2str(Data.pcur(v)));
case 'ChangeParm'
	v = get(findobj(hfig,'Tag','ParmMenu'),'Value');
	heb = findobj(hfig,'Tag','ParmBox');
	val = str2num(get(heb,'String'));
	testp = Data.pcur;
	testp(v) = val;
	testpall = untangle(testp,Data.varloc,Data.dims)+untangle(Data.pfix,Data.fixloc,Data.dims);
	if feval(Data.pcheckfunc,testpall)
		Data.pcur = testp;
	else
		warndlg('Old value will be used instead','Invalid parameter set');
		uiwait;
	end
	Data.opt = 0;
	set(hfig,'UserData',Data);
	FitInteractiveCB('Refresh',hfig);
case 'Refresh'
	FitInteractiveCB('ChooseParm',hfig);
	chi2v = PSTRateMrqCoef(Data.tsplit,Data.mn,Data.err,Data.keep,Data.trange,Data.pcur,...
		Data.varloc,Data.pfix,Data.fixloc,Data.nparms,Data.ifunc);
	chi2 = sum(chi2v);
	chi2txt = sprintf('chi^2 = %g',chi2);
	%chi2txt
	set(findobj(hfig,'Tag','chitext'),'String',chi2txt);
	p = untangle(Data.pcur,Data.varloc,Data.dims)+untangle(Data.pfix,Data.fixloc,Data.dims);
	for i = 1:Data.nexp
		rth{i} = feval(Data.ratefunc,Data.texp{i},p(:,i));
		axes(Data.hax(i));
		plot(Data.texp{i},Data.rexp{i},'-',Data.texp{i},rth{i},'--');
		set(Data.hax(i),'XTick',[],'XLim',[min(Data.texp{i}),max(Data.texp{i})]);
		title(sprintf('%d',i));
		if (Data.keep(i) == 0)
			set(Data.hax(i),'Color',[0.8 0.8 0.8]);
		end
	end
case 'Fit'
	warning off
	[pbest,chi2,dof,C] = FitPSTRateChi(Data.tsplit,Data.mn,Data.err,Data.keep,Data.trange,...
		Data.pcur,Data.varloc,Data.pfix,Data.fixloc,Data.nparms,Data.ifunc,Data.pcheckfunc);
	if (chi2 < 0)
		errordlg('Fewer bins than parameters!');
		uiwait;
	end
	Data.pcur = pbest;
	Data.chi2 = chi2;
	Data.dof = dof;
	Data.C = C;
	Data.opt = 1;
	set(hfig,'UserData',Data);
	FitInteractiveCB('Refresh',hfig);
case 'Keep'
	indx = find(gcbo == Data.hcheck);
	Data.keep(indx) = get(gcbo,'Value');
	set(hfig,'UserData',Data);
	FitInteractiveCB('Refresh',hfig);
case 'Done'
	if (~Data.opt)
		bname = questdlg('You have not optimized the current parameters. Optimize first?');
		switch(bname)
		case 'Yes'
			FitInteractiveCB('Fit',hfig);
		case 'Cancel'
			return;
		end;
	end;
	uiresume;
end
