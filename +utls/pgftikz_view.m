function pgftikz_view( path, varargin )
%VIEWTIKZ Summary of this function goes here
%   Detailed explanation goes here
if ~exist(path, 'file')
  error('File %s does not exist', path);
end
[~,~,ext] = fileparts(path);
if strcmp(ext, 'tikz')
  error('File is not tikz');
end
text = fileread(path);
if ~contains(text, '\begin{tikzpicture}')
  error('Invalid tikz file');
end

spath = fileparts(mfilename('fullpath'));

opts.repl.figw = '9cm';
opts.repl.figh = '6cm';
opts.repl.source = text;

opts.compileCmd = 'pdflatex';
opts.openCmd = 'display -flatten -density 300 -background white';
opts.template = fullfile(spath, 'pgftikztemplate.tex');
opts = vl_argparse(opts, varargin);


tmpdir = tempname;
vl_xmkdir(tmpdir);
tmpTex = fullfile(tmpdir, 'src.tex');
tmpOut = fullfile(tmpdir, 'src.pdf');


if ~exist(opts.template, 'file')
  error('Template %s does not exist', opts.template);
end
templ = fileread(opts.template);
repl = opts.repl; repl_f = fieldnames(repl);
for fi  = 1:numel(repl_f)
  fld = repl_f{fi};
  templ = strrep(templ, sprintf('$%s$', fld), repl.(fld));
end
resf = fopen(tmpTex, 'w');
fprintf(resf, '%s', templ);
fclose(resf);

curDir = pwd;
try
  cd(tmpdir);
  [ret, msg] = system(sprintf('%s %s', opts.compileCmd, tmpTex));
  if ret ~= 0
    error('Compilation failed');
  end
  [ret, msg] = system(sprintf('%s %s', opts.openCmd, tmpOut));
catch e
  cd(curDir);
  throw(e);
end
cd(curDir);
system(sprintf('rm -rf %s', tmpdir));

end

