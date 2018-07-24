function [res, info] = de(cmd, varargin)
%DE VLBenchmarks DetEval command line interface
%  `DE help`
%     Print this help string.
%  `DE help COMMAND`
%     Print a help string for a COMMAND.
%
%  `DE provision [scores-compact|scores-all|features]`
%
%  `DE compute EXPDEF_FILE`
%  `DE results EXPDEF_FILE`
%
%  `DE imagelist DATASET DETECTOR`
%  `DE view matchpair imdb taskid`
%  `DE view detections imdb featsname imid`
%  `DE view matches benchname imdb feats taskid`


% Copyright (C) 2018 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
vlb_setup();
usage = @(varargin) utls.helpbuilder(varargin{:}, 'name', 'vlb');

cmds = struct();
cmds.view = struct('fun', @vlb_view, 'help', '');
cmds.imagelist = struct('fun', @de_imagelist, 'help', '');

cmds.provision = struct('fun', @de_provision, 'help', '');
cmds.compute = struct('fun', @de_compute, 'help', '');
cmds.results = struct('fun', @de_results, 'help', '');

% The last command is always help
if isempty(varargin), varargin = {''}; end
cmds.help = struct('fun', @(varargin) usage(cmds, varargin{:}));

if nargin < 1, cmd = nan; end
if ~ischar(cmd), usage(cmds, ''); return; end
if strcmp(cmd, 'commands'), res = cmds; return; end;

if isfield(cmds, cmd) && ~isempty(cmds.(cmd).fun)
  if nargout == 1
    res = cmds.(cmd).fun(varargin{:});
  elseif nargout == 2
    [res, info] = cmds.(cmd).fun(varargin{:});
  else
    cmds.(cmd).fun(varargin{:});
  end
else
  error('Invalid command. Run help for list of valid commands.');
end

end


function de_provision(package_name)
packages = jsondecode(fileread(fullfile(de_path(), './packages.json')));
packages_names = arrayfun(@(a) a.name, packages, 'Uni', false);
packages_map = containers.Map(packages_names, num2cell(packages));

if ~packages_map.isKey(package_name)
  error('Invalid package name for provisioning %s', package_name);
end

package_def = packages_map(package_name);
utls.provision(package_def.url, package_def.target_dir, ...
  'doneName', ['.', package_def.name, '.download.done']);
end
