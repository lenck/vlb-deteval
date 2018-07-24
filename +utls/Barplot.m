classdef Barplot < handle
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Exps;
    DPoints;
    GlobalArgs;
    Opts;
  end
  
  methods
    function obj = Barplot(varargin)
      opts.plotValue = true;
      opts.TickLabelInterpreter = 'none';
      opts.mult = 100;
      opts.sort = true;
      [obj.Opts, varargin] = vl_argparse(opts, varargin);
      obj.Exps = {};
      obj.DPoints = {};
      obj.GlobalArgs = varargin;
    end
    
    function idx = findexp(obj, name)
      expnames = cellfun(@(a) a.name, obj.Exps, 'Uni', false);
      [found, idx] = ismember(name, expnames);
      if ~found
        error('Exp %s not found', name);
      end
    end
    
    function add_dpoint_mark(obj, name, value, varargin)
      opts.marker = 'x';
      [opts, varargin] = vl_argparse(opts, varargin);
      eidx = obj.findexp(name);
      res = struct('value', value, 'type', 'mark', 'opts', opts, 'args', {varargin});
      obj.Exps{eidx}.dpoints{end+1} = res;
    end
    
    function add_dpoint_textbox(obj, name, value, text, varargin)
      opts.VerticalAlignment = 'bottom';
      opts.HorizontalAlignment = 'center';
      opts.BackgroundColor = [[1, 1, 1], 0.5];
      opts.EdgeColor = 0.8*[1,1,1];
      opts.Margin = 0.08;
      opts.FontWeight = 'bold';
      opts.FontSize = 4;
      opts.LineWidth = 0.08;
      opts.offset = 0;
      %opts.FaceAlpha = 0.5;
      [opts, varargin] = vl_argparse(opts, varargin);
      eidx = obj.findexp(name);
      res = struct('value', value, 'text', text, 'type', 'textbox', ...
        'opts', opts, 'args', {varargin});
      obj.Exps{eidx}.dpoints{end+1} = res;
    end
    
    
    function add_dpoint_value(obj, name, value, pos, varargin)
      opts.template = '%.2f';
      opts.offsetx = 0;
      [opts, varargin] = vl_argparse(opts, varargin);
      eidx = obj.findexp(name);
      res = struct('value', value, 'pos', pos, 'type', 'value', 'opts', opts, 'args', {varargin});
      obj.Exps{eidx}.dpoints{end+1} = res;
    end
        
    function add_bar(obj, name, value, color, varargin)
      res = struct('name', name, 'value', value, 'type', 'bar', ...
        'color', color, 'dpoints', {{}}, 'args', {varargin});
      obj.Exps{end+1} = res;
    end
    
    function add_rect(obj, name, sval, eval, value, color, varargin)
      opts.barWidth = 0.2;
      opts.lineWidth = 2;
      opts.valueColor = [0, 0, 0];
      alpha = 0.1;
      opts.faceColor = color*alpha + (1-alpha)*[1, 1, 1]';
      opts.valueArgs = {};
      [opts, varargin] = vl_argparse(opts, varargin);
      assert(eval > sval);
      res = struct('name', name, 'sval', sval, 'eval', eval, 'value', value, ...
        'type', 'rect', 'color', color, 'opts', opts,'dpoints', {{}}, 'args', {varargin});
      obj.Exps{end+1} = res;
    end
    
    function res = add_boxandw(obj, name, data, color, varargin)
      if isempty(data)
        warning('Data empty for %s', name);
        res = [];
        return;
      end
      opts.barWidth = 0.3;
      opts.lineWidth = 1;
      alpha = 0.1;
      opts.faceColor = color*alpha + (1-alpha)*[1, 1, 1]';
      opts.ptiles = [10, 25, 75, 90];
      opts.meanColor = utls.rgb('red');
      opts.wisColor = utls.rgb('black');
      opts.wisArgs = {};
      opts.nanValue = 0;
      [opts, varargin] = vl_argparse(opts, varargin);
      assert(numel(opts.ptiles) == 4);
      data(isnan(data)) = opts.nanValue;
      ptiles = arrayfun(@(a) utls.prctile(data, a), opts.ptiles);
      
      res = struct('name', name, 'mean', mean(data), 'median', median(data), 'value', mean(data), ...
        'pt', ptiles, 'std', std(data), ...
        'type', 'boxandw', 'color', color,'dpoints', {{}}, 'opts', opts, 'args', {varargin});
      obj.Exps{end+1} = res;
    end
        
    function hs = plot(obj)
      exps = obj.Exps; opts = obj.Opts; m = opts.mult;
      expvals = cellfun(@(a) a.value, exps);
      if opts.sort
        [~, ei] = sort(expvals, 'ascend');
        exps = exps(ei);
      end
      expnames = cellfun(@(a) a.name, exps, 'Uni', false);
      hs = cell(1, numel(exps));
      for ni = 1:numel(exps)
        exp = exps{ni}; pos = ni;
        switch exp.type
          case 'bar'
            hs{ni}.main = barh(pos, exp.value*m, ...
              'FaceColor', exp.color.color, exp.args{:});
          case 'rect'
            bw = exp.opts.barWidth;
            len = exp.eval - exp.sval;
            hs{ni}.main = rectangle('Position', [exp.sval*m, pos-bw/2, len*m, bw], ...
              'EdgeColor', exp.color, 'LineWidth', exp.opts.lineWidth, ...
              'FaceColor', exp.opts.faceColor, exp.args{:});
            hold on;
            hs{ni}.value = plot([exp.value exp.value].*m, [pos-bw/2 pos+bw/2], ...
              'color', exp.color, 'LineWidth', exp.opts.lineWidth, exp.opts.valueArgs{:});
          case 'boxandw'
            bw = exp.opts.barWidth; lw = exp.opts.lineWidth;
            len = exp.pt(3) - exp.pt(2);
            hs{ni}.w = zeros(1, 4);
            hs{ni}.w(1) = plot([exp.pt(3) exp.pt(4)]*m, [pos pos],'--','linewidth', 1, 'color', exp.opts.wisColor, exp.opts.wisArgs{:}); hold on;
            hs{ni}.w(2) = plot([exp.pt(1) exp.pt(2)]*m, [pos pos],'--','linewidth', 1, 'color', exp.opts.wisColor, exp.opts.wisArgs{:});
            hs{ni}.w(3) = plot([exp.pt(1) exp.pt(1)]*m, [pos-bw/3 pos+bw/3],'-','linewidth',1,'color',exp.opts.wisColor);
            hs{ni}.w(4) = plot([exp.pt(4) exp.pt(4)]*m, [pos-bw/3 pos+bw/3],'-','linewidth',1,'color',exp.opts.wisColor);
            
            hs{ni}.rect = rectangle('Position', [exp.pt(2)*m, pos-bw/2, len*m, bw], ...
              'EdgeColor', exp.color', 'LineWidth', lw, ...
              'FaceColor', exp.opts.faceColor, exp.args{:});
            hs{ni}.median = plot([exp.median exp.median].*m, [pos-bw/2 pos+bw/2], ...
              'color', exp.color,'linewidth', 1);
            hs{ni}.mean = plot(exp.mean.*m, pos, 'x' ,'color', exp.color);
            
        end
        hold on;
        
        fs{ni}.dp = nan(1, numel(exp.dpoints));
        for di = 1:numel(exp.dpoints)
          dp = exp.dpoints{di};
          switch dp.type
            case 'mark'
              fs{ni}.dp(di) = plot(dp.value*m, pos, dp.opts.marker, 'Color', exp.color, dp.args{:});
            case 'textbox'
              off = dp.opts.offset;
              do = rmfield(dp.opts, 'offset');
              args = utls.struct2argscell(do);
              %fs{ni}.dp(di) = text(dp.value*m, pos-off, dp.text, 'Color', exp.color, 'EdgeColor', exp.color, args{:}, dp.args{:});
              fs{ni}.dp(di) = text(dp.value*m, pos-off, dp.text, 'Color', exp.color, args{:}, dp.args{:});
            case 'value'
              hs{ni}.textvalue = text(dp.pos, pos+dp.opts.offsetx, sprintf(dp.opts.template, dp.value),...
                'HorizontalAlignment', 'left',...
                'VerticalAlignment', 'middle', dp.args{:});
          end
        end
        
      end
      set(gca, 'Ydir', 'reverse')
      set(gca, 'YTick', 1:numel(exps));
      set(gca, 'TickLabelInterpreter', opts.TickLabelInterpreter);
      set(gca, 'YTickLabel', expnames);
      %axis tight;
      set(gca, 'XLim', [0, 100]);
      set(gca, 'YLim', [0, numel(exps)+1]);
      grid on;
    end
    
  end
  
end

