function res = de_rank_table( expdef_file, res, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if exist(expdef_file, 'file') == 2
  expdef = jsondecode(fileread(expdef_file));
  [expdef_path, benchmark_name, ~] = fileparts(expdef_file);
else
  error('Experiment definition file %s does not exist.', expdef_file);
end


opts.out_folder = fullfile(de_path, 'data', 'results', benchmark_name);
opts = vl_argparse(opts, varargin);

vl_xmkdir(opts.out_folder);
dset_defs = expdef.datasets_defs;

ofile = fopen(fullfile(opts.out_folder, 'detectors_rank.tex'), 'w');
out = @(varargin) [fprintf(varargin{:}), fprintf(ofile, varargin{:})];
fprintf('\n\n');

in_c = @(a, b) max(min(a.*b, 1), 0);
detectors = cell(1, numel(expdef.detectors));
for bi = 1:numel(expdef.detectors)
  alpha = 0.5;
  det_path = fullfile(expdef_path, expdef.detectors{bi});
  det = jsondecode(fileread(det_path));
  detname = det.name;
  detectors{bi} = det;
  detectors{bi}.cname = ['clr-', detname];
  color = in_c((1-alpha).*detectors{bi}.color + alpha, 1);
  out('\\definecolor{%s}{rgb}{%.3f,%.3f,%.3f}\n', detectors{bi}.cname, ... 
    color(1), color(2), color(3));
end

out('\\definecolor{gold}{rgb}{0.72, 0.53, 0.04}');
out('\\definecolor{silver}{rgb}{0.63, 0.47, 0.35}');
out('\\definecolor{bronze}{rgb}{0.6, 0.51, 0.48}');
  

out('\\begin{tabular}{| l | %s c |}\n', strjoin(arrayfun(@(a) 'c c c |', 1:(numel(dset_defs)), 'Uni', false), ' '));

out('\\hline \\multirow{2}{*}{Det} ');
for imi = 1:numel(dset_defs), out('& \\multicolumn{3}{c|}{\\textsc{%s} } ', dset_defs(imi).texname); end
out(' &Avg. $rnk$ \\\\\n');
%out('\\# Pixels ');
for imi = 1:numel(dset_defs), out('& {\\color{white!60!black} $stb$} & $rep$ & $rnk$ '); end
out(' & \\\\ \\hline \n');

for ri = 1:numel(dset_defs)
  res{ri} = sortrows(res{ri}, 'mean', 'descend');
  rank = 1:size(res{ri}, 1);
  res{ri}.rank = rank';
end
ranks = zeros(numel(detectors), numel(dset_defs));
for di = 1:numel(detectors)
  for dsi = 1:numel(dset_defs)
    [~, srow] = ismember(detectors{di}.name, res{dsi}.det_name);  
    det_res = res{dsi}(srow, :);
    ranks(di, dsi) = det_res.rank(1);
  end
end
avg_ranks = mean(ranks, 2);
[~, det_order] = sort(avg_ranks, 'ascend');

for din = 1:numel(detectors)
  di = det_order(din);
  out('\\cellcolor{%s} %s  ', detectors{di}.cname, detectors{di}.texname);
  for dsi = 1:numel(dset_defs)
    [~, srow] = ismember(detectors{di}.texname, res{dsi}.det_texname);
    det_res = res{dsi}(srow, :);
    if det_res.rank(1) == 1
      out(' & {\\color{white!60!black} %.1f } & {\\bf \\color{gold}% 5.2f} & {\\bf \\color{gold} %d} ', det_res.stability(1), det_res.mean(1)*100, det_res.rank(1));
    elseif det_res.rank(1) == 2
      out('& {\\color{white!60!black} %.1f } & {\\bf \\color{silver}% 5.2f} & {\\bf \\color{silver} %d} ', det_res.stability(1), det_res.mean(1)*100, det_res.rank(1));
    elseif det_res.rank(1) == 3
      out('& {\\color{white!60!black} %.1f } & {\\bf \\color{bronze}% 5.2f} & {\\bf \\color{bronze} %d} ', det_res.stability(1), det_res.mean(1)*100, det_res.rank(1));
    else
      out(' & {\\color{white!60!black} %.1f } & % 5.2f & {%d} ', det_res.stability(1), det_res.mean(1)*100, det_res.rank(1));
    end
  end
  out('& % 5.2f ', avg_ranks(di));
  out(' \\\\\n ');
end
out('\\hline\n\\end{tabular}\n\n');
fclose(ofile);

end
