function imdbs_map = de_get_datasets()
cacheFile = fullfile(de_path, 'datasets.mat');

if exist(cacheFile, 'file')
  imdbs = load(cacheFile); imdbs = imdbs.imdbs;
else
  error('Cannot find cached datasts (%s).', cacheFile);
end

imdbs_names = cellfun(@(a) a.name, imdbs, 'Uni', false);
imdbs_map = containers.Map(imdbs_names, imdbs);

end