function de_deploy(varargin)
% DE_DEPLOY Deploy the binary command line interface of the VLB-deteval

% Copyright (C) 2018 Karel Lenc
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
de_setup();

opts.verbose = false;
opts = vl_argparse(opts, varargin);


target_dir = fullfile(de_path, 'bin');
vl_xmkdir(target_dir);

helpstr = evalc('help de');
helpstr = strrep(helpstr, '<strong>de</strong>', 'bin/de_run.sh MCRPATH');
helpstr = strrep(helpstr, '    ', '');
helpstr = strrep(helpstr, '   `', '`');
fd = fopen(fullfile(target_dir, 'README.md'), 'w');
fprintf(fd, '#%s', helpstr);
fclose(fd);

addargs = vl_deps();
if opts.verbose
  addargs{end+1} = '-v';
end

% Add all datasets, as they are called based on a string
dsets = utls.listfiles(fullfile(vlb_path(), 'matlab', '+dset', '*.m'), ...
  'keepext', true, 'fullpath', true);
for di = 1:numel(dsets)
  addargs{end+1} = '-a';
  addargs{end+1} = dsets{di};
end

mcc('-m', 'de.m', '-d', target_dir, '-o', 'de', addargs{:});
end

function depargs = vl_deps()
archs = struct();
archs.mexw64 = '*.dll'; archs.mexw32 = '*.dll';
archs.mexmaci64 = '*.dylib'; archs.mexmaci32 = '*.dylib';
archs.mexa64 = '*.so'; archs.mexaglx = '*.so';

depargs = {};
mexdir = fullfile(vl_root, 'toolbox', 'mex', mexext);
libs = dir(fullfile(mexdir, archs.(mexext)));
for li = 1:numel(libs)
  depargs{end+1} = '-a';
  depargs{end+1} = fullfile(mexdir, libs(li).name);
end

end
