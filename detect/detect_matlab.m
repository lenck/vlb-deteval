function detect_matlab()
% Change rpath if you move the script from vlb-deteval/detect
rpath = fileparts(fileparts(mfilename('fullpath')));
dsets = dir(fullfile(rpath, 'imagelists', '*.csv'));
info = det_info;

for di = 1:numel(dsets)
  fprintf('\n(%d/%d) Dataset %s\n', di, numel(dsets), dsets(di).name);
  dset_path = fullfile(dsets(di).folder, dsets(di).name);
  dset = readtable(dset_path, 'Delimiter', ';', 'ReadVariableNames', false);
  dset.Properties.VariableNames = {'impath', 'dpath', 'dname'};
  
  for ii = 1:size(dset, 1)
    imd = table2struct(dset(ii, :));
    fprintf('\t(%02d/%02d) Processing %s\n', ii, size(dset, 1), imd.dname);
    im = imread(fullfile(rpath, imd.impath));
    feats = detect(im);
    dpath = fullfile(rpath, imd.dpath, info.name);
    if ~exist(dpath, 'dir'), mkdir(dpath); end
    frames_path = fullfile(dpath, [imd.dname, '.frames.csv']);
    dlmwrite(frames_path, feats.frames', ';');
    respones_path = fullfile(dpath, [imd.dname, '.detresponses.csv']);
    dlmwrite(respones_path, feats.detresponses', ';');
  end
end
detspec_path = fullfile(rpath, 'expdefs', 'dets', [info.name, '.json']);
fprintf('Exporting detector info to %s.\n', detspec_path);
ff = fopen(detspec_path, 'w');
json = jsonencode(info);
fprintf(ff, json);
fclose(ff);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit the following two functions for your own detector

function res = det_info()
res.name = 'griddet';
res.texname = 'GridDet';
res.type = 'trinv';
res.color = [0.2, 0.2, 0.2];
end

function feats = detect(im)
% coordinate of the center of a first pixel of the image (top-left) is [1,1]
nfeats = 2000;
[H, W] = size(im);
[x, y] = ndgrid(linspace(1, H, sqrt(nfeats)), ...
  linspace(1, W, sqrt(nfeats)));
scale = ones(1, numel(x)) * sqrt(H*W / nfeats);
feats.frames = [x(:), y(:), scale(:)]';
feats.detresponses = randn(1, numel(x));
end
