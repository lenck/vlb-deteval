function res = de_plot_detres( expdef_file, pres, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if exist(expdef_file, 'file') == 2
  expdef = jsondecode(fileread(expdef_file));
  expdef_path = fileparts(expdef_file);
else
  error('Experiment definition file %s does not exist.', opts);
end

opts.out_folder = fullfile(de_path, 'data', 'results', expdef.benchmark_name);
opts.arargs = {'FontSize', 8, 'HorizontalAlignment', 'center'};
opts.ndargs = {'Color', 0.6*ones(1, 3), 'FontSize', 8, 'BackgroundColor', 'w', 'HorizontalAlignment', 'center'};
opts.scoreName = 'repeatability';
opts.xLabel = 'Repeatability [%]';
opts.descriptor = '';
opts.nanValue = 0;
opts.stabXPos = 105;
opts.repXPos = 115;
opts.printSize = 0.5;
opts = vl_argparse(opts, varargin);

vl_xmkdir(opts.out_folder);

detectors = expdef.detectors;
benchname = expdef.benchmark_name;
ddefs = expdef.datasets_defs;
nfdef = expdef.nframes_defs;
  
vals = pres.(opts.scoreName);
vals(isnan(vals)) = opts.nanValue;
pres.(opts.scoreName) = vals;

repres_nf = varfun(@mean, pres, 'InputVariables', opts.scoreName, 'GroupingVariables', {'features', 'dataset', 'nfeats', 'benchname'});
close all; figs = cell(1, numel(ddefs));

arargs = opts.arargs; ndargs = opts.ndargs;
res = cell(1, numel(ddefs));
for di = 1:numel(ddefs)
  %figure('units','normalized','outerposition',[0 0 1 1]); clf;
  dsetv = ddefs(di).name;
  if ~iscell(dsetv)
    dsetv = {dsetv};
  end
  if ~isempty(figs{di}) && isvalid(figs{di}), close(figs{di}); end
  figs{di} = figure('name', strjoin(dsetv, '_')); clf;
  bp = utls.Barplot();
  
  res{di} = cell(1, numel(detectors)); 
  for fd = 1:numel(detectors)
    det_path = fullfile(expdef_path, expdef.detectors{fd});
    det = jsondecode(fileread(det_path));
    detname = det.name;
    if ~isempty(opts.descriptor)
      detname = fullfile(detname, opts.descriptor);
    end
    sel = (pres.features == detname & ismember(pres.dataset, dsetv) & pres.benchname == benchname);
    switch det.type
      case 'trinv', addargs = {'wisArgs', {'LineStyle', ':'}};
      case 'scinv', addargs = {'wisArgs', {'LineStyle', '-.'}};
      case 'affinv', addargs = {'wisArgs', {'LineStyle', '--'}};
    end
    
    baw = bp.add_boxandw(det.texname, pres{sel, opts.scoreName}, det.color, addargs{:});
    bp.add_dpoint_value(det.texname, baw.value*100, opts.repXPos, 'template', '%03.1f%%', arargs{:});
    
%    nc_sel = ncres.features == det.name & ncres.dataset == dsetv & ncres.benchname == benchname & ncres.nfeats == 1000;
%    bp.add_dpoint_value(det.texname, ncres{nc_sel, 'mean_numCorresp'} ./ repres_nf{nc_sel, 'mean_repeatability'}./1000, 95, 'template', '%03.1fk', 'offsetx', 0, ndargs{:});

    mrep = baw.value;
    nd_rep = [];
    for nfi = 1:numel(nfdef)
      nf = nfdef(nfi).num;
      sel_n = repres_nf.features == detname  & ismember(repres_nf.dataset, dsetv) & repres_nf.nfeats == nf & repres_nf.benchname==benchname;
      value = mean(repres_nf{sel_n, ['mean_', opts.scoreName]});
      assert(sum(sel_n) == numel(dsetv));
      bp.add_dpoint_textbox(det.texname, value, nfdef(nfi).text, 'offset', 0.17);
      nd_rep(nfi) = value;
    end
    stability = (std(nd_rep)) ./ mrep;
    bp.add_dpoint_value(det.texname, stability, opts.stabXPos , 'template', '%.1f', 'offsetx', 0, ndargs{:});
    res{di}{fd} = struct('det_name', detname, ...
      'det_texname', det.texname, 'mean', baw.value, ...
      'ptiles', baw.pt, 'std', baw.std, 'median', baw.median, ...
      'stability', stability, 'dataset', strjoin(dsetv, '_'),...
      'dataset_texname', ddefs(di).texname, 'det_color', det.color);
  end
  bp.plot(); title(ddefs(di).texname);
  if true || ~(ddefs(di).plot_xlabel)
    text(opts.stabXPos, 0, 'stb', ndargs{:});
    text(opts.repXPos, 0, sprintf('rep'), arargs{:});
    set(gca,'xtick',[])
    set(gca,'xticklabel',[])
  end
  ax = gca;
  ax.XTick = 0:10:100;
  if (ddefs(di).plot_xlabel), xlabel(opts.xLabel); end
  drawnow;
    
  outname = sprintf('plot_%s_%s', benchname, strjoin(dsetv, '_'));
  out_im_path = fullfile(opts.out_folder, outname);
  vl_xmkdir(fileparts(out_im_path));
  matlab2tikz([out_im_path, '.tikz'], 'showInfo', false, ...
   'width', '\figW', 'height', '\figH', 'interpretTickLabelsAsTex', false, 'strictFontSize', true);
  pos=get(gca,'position');  % retrieve the current values
  pos(3)=0.9*pos(3);        % try reducing width 10%
  set(gca,'position',pos);  % write the new values
  vl_printsize(opts.printSize); 
  set(gcf, 'PaperPositionMode', 'auto');
  print('-dpng', [out_im_path, '.png'], '-r300');

  res{di} = cell2mat(res{di});
  res{di} = struct2table(res{di}, 'AsArray', true);
end

end

