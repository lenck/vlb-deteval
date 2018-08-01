function de_imagelist(varargin)
%DE_IMAGELIST Export imagelist and target paths to a txt file
%  DE_IMAGELIST featsname
%  Exports imagelist to `data/imagelists/<imdb>.csv in format:
%
%  ```
%  <Source image path>;<target features path>;<target features file name>\n
%  ...
%
%  ```

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.targetDir = 'imagelists';
opts = vl_argparse(opts, varargin);
  
% TODO load from cached datasets...
imdbs_all = de_get_datasets();
imdbs = imdbs_all.keys();

for ii = 1:numel(imdbs)
  imdb = dset.factory(imdbs{ii});
  tgt_path = fullfile(opts.targetDir, sprintf('%s.csv', imdb.name));
  feats_path = vlb_path('features', imdb, '');
  feats_path = [strrep(feats_path, [pwd, filesep], ''), filesep];
  
  out = fopen(tgt_path, 'w');
  for imi = 1:numel(imdb.images)
    impath = strrep(imdb.images(imi).path, [pwd, filesep], '');
    imname = imdb.images(imi).name;
    fprintf(out, '%s;%s;%s\n', impath, feats_path, imname);
  end
  fclose(out);
  fprintf('Output exported to %s\n', tgt_path);
end

end