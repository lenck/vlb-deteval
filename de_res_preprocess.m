function [ pres ] = de_res_preprocess( res )
%UNTITLED Preprocess the detection results
%   Detailed explanation goes here


%% Preprocess the hpatches dataset - split between the viewpoint and illum, parse nfeats
pres = res;
dataset = pres.dataset;
sequence = pres.sequence;
benchmark = pres.benchmark;
nfeats = nan(size(pres, 1), 1);
benchname = cell(size(pres, 1), 1);
imbn = nan(size(pres, 1), 1); 
imb = pres.imb;
status = utls.textprogressbar(size(pres, 1));
for ri = 1:size(pres, 1)
  if strcmp(dataset(ri), 'hpatches-sequences')
    seq = char(sequence(ri));
    if seq(1) == 'i'
      dataset{ri} = 'hseq-i';
    else
      dataset{ri} = 'hseq-v';
    end
  end
  % Decode the name of the second image
  tokens = regexp(benchmark{ri}, '(\w+)_([\d.]+)', 'tokens');
  nfeats(ri) = sscanf(tokens{1}{2}, '%d'); benchname{ri} = tokens{1}{1};
  tokens_imb = regexp(imb{ri}, '(\w+)-(img)?([\d]+)', 'tokens');
  imbn(ri) = sscanf(tokens_imb{1}{3}, '%d');
  status(ri);
end
pres.benchname = categorical(benchname);
pres.nfeats = nfeats;
pres.dataset = dataset;
pres.imbn = imbn;

%%
%% Convert variables to categorical variables
flds = {'benchmark', 'features', 'dataset', 'sequence', 'ima', 'benchname'};
for fi = 1:numel(flds)
  pres.(flds{fi}) = categorical(pres.(flds{fi}));
end

end

