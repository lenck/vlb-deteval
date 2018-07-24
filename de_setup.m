function de_setup()

run ./vlb/matlab/vlb_setup.m;
if ~exist(['vlb_greedy_matching.', mexext], 'file')
  vlb_compile();
end
setenv('VLB_DATAROOT', fullfile(de_path, 'data'));
addpath('./matlab2tikz/src');

end