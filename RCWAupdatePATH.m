function pathstr=RCWAupdatePATH(pathstr0)
%add required directories to MATLAB's PATH.
%   The directory parent to the 'RCWA-MATLAB-module\' is expected
%   as the parameter. The current ('.') and the parent ('..') directories
%   are checked by default. The function returns the resulting path 
%   upon success or NaN on failure

if nargin==0
  pathstr0='';
end

pathstr=[pathstr0 '\RCWA-MATLAB-module\'];

if ~exist(pathstr,'dir') && isempty(pathstr0)
  pathstr=['.\' pathstr];
end
if ~exist(pathstr,'dir')
  pathstr=['..\' pathstr];
end

if exist(pathstr,'dir')
  addpath([pathstr 'material\']);
  addpath([pathstr 'RCWA\']);
  addpath([pathstr 'shape\']);
else
  pathstr=nan;
end

end
