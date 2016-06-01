% compile_mex.m
%
% Called by `installmexfiles` shell script.
% Complies c and cpp source codes in subdirectory 'mexcodes' into mex codes
% where source codes are copied into the subdirectories from `installmexfiles` shell script.

% sourse codes to compile to mex files
%source_codes = {'AutoCorr.cpp', 'CrossCorr.cpp', 'FileHeaders.cpp', 'LoadIndexSnip.cpp'};
source_codes = {'AutoCorr.cpp', 'CrossCorr.cpp', 'polygon.cpp'};

for ii = 1:length(source_codes)
    if ~exist(source_codes{ii})
        fprintf('Error finding source code. %s.c could not be found.\n', source_codes{ii});
    end

    % mex compile
    try
        fprintf(' %d mexing %s\n', ii, source_codes{ii});
        if strcmp(debugmode, 'TRUE')
            mex('-g', source_codes{ii})
        else
            mex(source_codes{ii})
        end
        fprintf(' Success mexing %s\n\n', source_codes{ii});
    catch exception
        fprintf(' Error in mexing %s\n\n', source_codes{ii});
        msgString = getReport(exception);
        disp(msgString)
    end
end

exit
