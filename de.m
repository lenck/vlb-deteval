function [res, info] = de(cmd, varargin)
%DE VLBenchmarks DetEval command line interface
%  `DE help`
%     Print this help string.
%  `DE help COMMAND`
%     Print a help string for a COMMAND.
%
%  `DE provision [scores-compact|scores-all|features|datasets]`
%     Provision the data packages (defined in packages.json).
%
% Check the detected features of a detector
%
%  `DE checkdetections DETNAME`
%     Check whether the detections of a detector DETNAME are correct.
%     Checks whether features are detected for all features (see
%     `./detect/detect_[matlab|python]` and whether the detections are in
%     correct format.
%
% Compute and visualise the results
%
%  `DE compute EXPDEF_PATH`
%     Compute the scores using a given experiment defition json file path
%     EXPDEF_PATH.
%  `DE results EXPDEF_PATH`
%     Generate the results files for a given experiment.
%
% Visualise results
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

cmds = struct();
cmds.view = struct('fun', @vlb_view, 'help', '');
cmds.imagelist = struct('fun', @de_imagelist, 'help', '');
cmds.checkdetections = struct('fun', @check_detections, 'help', 'Check detections of DETNAME');

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
  res = ''; info = '';
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
if strcmp(package_name, 'datasets')
  imdbs = de_get_datasets();
  imdbs = imdbs.keys();
  cellfun(@(a) dset.factory(a), imdbs, 'Uni', false);
  return;
end

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


function nf_stats = check_detections(feats)
imdbs = de_get_datasets();
imdbs = imdbs.values;

if isstruct(feats), featsname = feats.name; else, featsname = feats; end
nf_stats = struct('min', inf, 'max', -inf, 'avg', 0, 'nim', 0);

for di = 1:numel(imdbs)
  imdb = imdbs{di};
  for imi = 1:numel(imdb.images)
    imname = imdb.images(imi).name;
    [feats, fpath] = utls.features_get(imdb, featsname, imname);
    fpath = strrep(fpath, [pwd, filesep], '');
    if ~isfield(feats, 'frames')
      error('Frames in %s not found', [fpath, '.frames.csv']);
    end
    if size(feats.frames, 1) > 6 || size(feats.frames, 1) < 2
      error('Frames in %s must have 2,3,4,5 or 6 values per frame (row)', ...
        [fpath, '.frames.csv']);
    end
    nframes = size(feats.frames, 2);
    if ~isfield(feats, 'detresponses')
      error('Det responses in %s not found', [fpath, '.detresponses.csv']);
    end
    if size(feats.detresponses, 1) ~= 1 
      error('Detresponses in %s must have 1 value per frame (row)', ...
        [fpath, '.detresponses.csv']);
    end
    if nframes ~= size(feats.detresponses, 2)
      error(...
        'Number of rows in frames.csv and detresponses.csv does not agree for %s',...
        fpath);
    end
    nf_stats.min = min(nf_stats.min, nframes);
    nf_stats.max = max(nf_stats.max, nframes);
    nf_stats.avg = nf_stats.avg + nframes;
    nf_stats.nim = nf_stats.nim + 1;
  end
end
nf_stats.avg = nf_stats.avg / nf_stats.nim;

det_path = fullfile(de_path, 'expdefs', 'dets', [featsname, '.json']);
if ~exist(det_path, 'file')
  warning('Detector definition %s does not exist.', det_path);
  return;
end
det = jsondecode(fileread(det_path));
if ~isfield(det, 'name') || ~isfield(det, 'texname') || ~isfield(det, 'color') ...
    || ~isfield(det, 'type')
  error('Detector definition is missing some of the fileds [name, texname, color, type].');
end

display(nf_stats);
end
