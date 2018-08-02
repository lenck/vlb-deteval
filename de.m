function [res, info] = de(cmd, varargin)
%DE VLBenchmarks DetEval command line interface
%  `DE help`
%     Print this help string.
%  `DE help COMMAND`
%     Print a help string for a COMMAND.
%
%  `DE provision [scores-compact|scores-all|features]`
%     Provision the data packages (defined in packages.json).
%
% Compute and visualise the results
%
%  `DE compute EXPDEF_PATH`
%     Compute the scores using a given experiment defition json file path
%     EXPDEF_PATH.
%  `DE results EXPDEF_PATH`
%     Generate the results files for a given experiment.
%
% Visualise reuslts
%
%  `DE view matchpair DSETNAME TASKID`
%     View the dataset images (named DSETNAME) for a given task TASKID.
%  `DE view detections DSETNAME DETNAME IMID`
%     Plot detections of a given detector DETNAME on a dataset DSETNAME
%     image IMID.
%  `DE view matches SCORES_NAME DSETNAME DETNAME TASKID`
%     View matched frames using scores benchname of a given
%     dataset DSETNAME, detector name DETNAME and for a given dataset
%     task TASKID. For the valid SCORES_NAME, see folders in
%     `./data/scores/`
%
%

% Copyright (C) 2018 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
de_setup();
usage = @(varargin) utls.helpbuilder(varargin{:}, 'name', 'de');
res = ''; info = '';

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

if isdeployed
  nargs = 0;
else
  nargs = nargout;
end

if isfield(cmds, cmd) && ~isempty(cmds.(cmd).fun)
  if nargs == 1
    res = cmds.(cmd).fun(varargin{:});
  elseif nargs == 2
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
