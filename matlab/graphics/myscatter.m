function hh = scatter(varargin)
%SCATTER Scatter plot.
%   SCATTER(X,Y,S,C) displays colored circles at the locations specified
%   by the vectors X and Y (which must be the same size).  The area of
%   each marker is determined by the values in the vector S (in points^2)
%   and the colors of each marker are based on the values in C. S can be a
%   scalar, in which case all the markers are drawn the same size, or a
%   vector the same length as X and Y.
%   
%   When C is a vector the same length as X and Y, the values in C
%   are linearly mapped to the colors in the current colormap.  
%   When C is a LENGTH(X)-by-3 matrix, the values in C specify the
%   colors of the markers as RGB values.  C can also be a color string.
%
%   SCATTER(X,Y) draws the markers in the default size and color.
%   SCATTER(X,Y,S) draws the markers with a single color.
%   SCATTER(...,M) uses the marker M instead of 'o'.
%   SCATTER(...,'filled') fills the markers.
%
%   H = SCATTER(...) returns handles the PATCHES created.
%
%   Use PLOT for single color, single marker size scatter plots.
%
%   Example
%     load seamount
%     scatter(x,y,5,z)
%
%   See also SCATTER3, PLOT, PLOTMATRIX.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 1997/11/21 23:46:45 $

error(nargchk(2,6,nargin))
ax = newplot;
filled = 0;
scaled = 0;
marker = '';
c = '';

% Parse optional trailing arguments (in any order)
nin = nargin;
while nin > 0 & isstr(varargin{nin})
  if strcmp(varargin{nin},'filled'),
     filled = 1;
  else
     [l,ctmp,m,msg] = colstyle(varargin{nin});
     error(msg)
     if ~isempty(m), marker = m; end
     if ~isempty(ctmp), c = ctmp; end
  end
  nin = nin-1;
end
if isempty(marker), marker = 'o'; end
co = get(ax,'colororder');

switch nin
case 2  % scatter(x,y)
  x = varargin{1};
  y = varargin{2};
  if isempty(c),
    c = co(1,:);
  end
  s = get(ax,'defaultlinemarkersize')^2;
case 3 % scatter(x,y,s)
  x = varargin{1};
  y = varargin{2};
  s = varargin{3};
  if isempty(c),
    c = co(1,:);
  end
case 4  % scatter(x,y,s,c)
  x = varargin{1};
  y = varargin{2};
  s = varargin{3};
  c = varargin{4};
otherwise
   error('Wrong number of input arguments.');
end

if length(x) ~= length(y) | ...
   length(x) ~= prod(size(x)) | length(y) ~= prod(size(y))
  error('X and Y must be vectors of the same length.');
end

% Map colors into colormap colors if necessary.
if isstr(c) | isequal(size(c),[1 3]); % string color or scalar rgb
   color = repmat(c,length(x),1);
elseif length(c)==prod(size(c)) & length(c)==length(x), % is C a vector?
   scaled = 1;
elseif isequal(size(c),[length(x) 3]), % vector of rgb's
   color = c;
else
  error(['C must be a single color, a vector the same length as X, ',...
         'or an M-by-3 matrix.'])
end

% Scalar expand the marker size if necessary
if length(s)==1, 
  s = repmat(s,length(x),1); 
elseif length(s)~=prod(size(s)) | length(s)~=length(x)
  error('S must be a scalar or a vector the same length as X.')
end

% Now draw the plot, one patch per point.
h = zeros(length(x),1);
for i=1:length(x),
%   h = [h;patch('xdata',x(i),'ydata',y(i),...
%         'linestyle','none','facecolor','none',...
%          'markersize',sqrt(s(i)), ...
%         'marker',marker)];
   h(i) = patch('xdata',x(i),'ydata',y(i),...
         'linestyle','none','facecolor','none',...
          'markersize',sqrt(s(i)), ...
         'marker',marker);
   if scaled,
      set(h(i),'cdata',c(i),'edgecolor','flat','markerfacecolor','flat');
   else
      set(h(i),'edgecolor',color(i,:),'markerfacecolor',color(i,:));
   end
   if ~filled,
      set(h(i),'markerfacecolor','none');
   end
end

if nargout>0, hh = h; end
