function de_setup()

if ~isdeployed
  addpath(fullfile('vlb', 'matlab'));
end

vlb_setup();
if ~exist(['vlb_greedy_matching.', mexext], 'file')
  vlb_compile();
end
dpath = de_path();
% Make sure that VLB stores data in this project directory
setenv('VLB_ROOT', fullfile(dpath, 'vlb'));
setenv('VLB_DATAROOT', fullfile(dpath, 'data'));
if ~isdeployed
  addpath('./matlab2tikz/src');
end

end