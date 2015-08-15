function dlmwrite0(filename, m, dlm, r, c)
%DLMWRITE0 Write ASCII delimited file.
%   DLMWRITE0(FILENAME,M,DLM) writes matrix M into FILENAME using the
%   character DLM as the delimiter.  Specify '\t' to produce 
%   tab-delimited files.
%
%   DLMWRITE0(FILENAME, M, DLM, R, C) writes matrix M starting at
%   offset row R, and column C in the file.  R and C are zero-based,
%   that is R=C=0 specifies first number in the file.
%
%   NOTE: differs from DLMWRITE only in that 0 _is_ written to the file
%
%   See also DLMWRITE, DLMREAD, CSVREAD, WK1READ, WK1WRITE.

%   Brian M. Bourgault 10/22/93
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.14 $  $Date: 1997/11/21 23:35:06 $

%
% test for proper filename
%
if ~isstr(filename),
    error('FILENAME must be a string.');
end;

if nargin < 2, error('Requires at least 2 input arguments.'); end

NEWLINE = sprintf('\n');

% delimiter defaults to Comma for CSV
if nargin < 3, dlm = ','; end
dlm = sprintf(dlm); % Handles special characters.


% open the file
if strncmp(computer,'MAC',3)
  fid = fopen(filename ,'wt');
else
  fid = fopen(filename ,'wb');
end

if fid == (-1), error(['Could not open file ' filename]); end

% check for row,col offsets
if nargin < 4, r = 0; end
if nargin < 5, c = 0; end

% dimensions size of matrix
[br,bc] = size(m);

% start with offsetting row of matrix
for i = 1:r
    for j = 1:bc+c-1
        fwrite(fid, dlm, 'uchar');    
    end
    fwrite(fid, NEWLINE, 'char');
end

% start dumping the array, for now number format float
for i = 1:br

    % start with offsetting col of matrix
    for j = 1:c
        fwrite(fid, dlm, 'uchar');    
    end

    for j = 1:bc
        if(m(i,j) ~= 0)
            str = num2str(m(i,j));
            fwrite(fid, str, 'uchar');    
        end
        if(j < bc)
            fwrite(fid, dlm, 'uchar');    
        end
    end
    fwrite(fid, NEWLINE, 'char'); % this may \r\n for DOS 
end

% close files
fclose(fid);
