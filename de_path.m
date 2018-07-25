function funpath = de_path()
%DE_PATH Return the root path of the project

% Copyright (C) 2016 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
if isdeployed
  % assume that the script is being run either from root or from bin
  %fprintf('PWD is %s\n', pwd);
  paths = {pwd, fullfile(pwd, '..')};
  funpath = '';
  for pi = 1:numel(paths)
    path = paths{pi};
    if exist(fullfile(path, 'expdefs'), 'dir') == 7 && ...
       exist(fullfile(path, 'data'), 'dir') == 7
     funpath = path;
    end
  end
  if isempty(funpath)
    error('VLB-DetEval not found.');
  end
else
  funpath = fileparts(mfilename('fullpath'));
end
