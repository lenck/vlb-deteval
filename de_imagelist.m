function de_imagelist(feats, varargin)
%DE_IMAGELIST Export imagelist and target paths to a txt file
%  DE_IMAGELIST featsname
%  Exports imagelist to `data/imagelists/<imdb>-<featsname>.csv in format:
%
%  ```
%  <Source image path>;<feature frames path>;<feature responses path>\n
%  ...
%
%  ```

% Copyright (C) 2016-2017 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.targetDir = vlb_path('imagelists');
opts = vl_argparse(opts, varargin);

if ~ischar(feats) || isempty(feats)
  error('Invalid features name `%s`', feats);
end
  
% TODO load from cached datasets...
imdbs_all = de_get_datasets();
imdbs = imdbs_all.keys();

for ii = 1:numel(imdbs)
  imdb = dset.factory(imdbs{ii});
  if isstruct(feats), feats = feats.name; end
  featsname =  matlab.lang.makeValidName(feats);
  tgt_path = fullfile(opts.targetDir, sprintf('%s-%s.csv', imdb.name, featsname));
  
  out = fopen(tgt_path, 'w');
  for imi = 1:numel(imdb.images)
    impath = imdb.images(imi).path;
    tgtpath = fullfile(vlb_path('features', imdb, feats), [imdb.images(imi).name]);
    fprintf(out, '%s;%s;%s\n', impath, [tgtpath '.frames.csv'],...
      [tgtpath '.detresponses.csv']);
  end
  fclose(out);
  fprintf('Output exported to %s\n', tgt_path);
end

end