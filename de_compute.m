function pres = de_compute(expdef_file, varargin)
opts.loadOnly = false;
[opts, varargin] = vl_argparse(opts, varargin);
if exist(expdef_file, 'file') == 2
  expdef = jsondecode(fileread(expdef_file));
  [expdef_path, benchmark_name, ~] = fileparts(expdef_file);
else
  error('Experiment definition file %s does not exist.', expdef_file);
end

fprintf('Loading datasets...\n');
imdbs_all = de_get_datasets();

  
fprintf('Preparing experiments....\n');
evargs = {};
for di = 1:numel(expdef.detectors)
  det_path = fullfile(expdef_path, expdef.detectors{di});
  det = jsondecode(fileread(det_path));
  % Add a file detector - throws error when features not pre-computed.
  det.fun = @features.det.filedet; 
  for ni = 1:numel(expdef.datasets)
    imdb_name = expdef.datasets{ni};
    if ~imdbs_all.isKey(imdb_name)
      error('Invalid imdb name %s', imdb_name);
    end
    imdb = imdbs_all(expdef.datasets{ni});
    for nf = 1:numel(expdef.nframes_defs)
      nfdef = expdef.nframes_defs(nf);
      evargs{end+1} = [{imdb, det, 'topn', nfdef.num, ...
        'benchName', sprintf('%s_%d', benchmark_name, nfdef.num)}, ...
        'fix', true, varargin{:}];
    end
  end
end
fprintf('%d experiments created.\n', numel(evargs));
sel = utls.parallelise(1:numel(evargs));

res = cell(1, size(sel, 1));
for ai = 1:size(sel, 1)
  fprintf('Computing experiment %d/%d.\n', ai, size(sel,1));
  res{ai} = vlb('detrep', evargs{sel(ai)}{:}, 'loadOnly', opts.loadOnly);
end
res = vertcat(res{:});
pres = de_res_preprocess(res);
end