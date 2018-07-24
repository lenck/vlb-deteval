function de_results(expdef_file, varargin)

pres = de_compute(expdef_file, varargin{:});
res = de_plot_detres(expdef_file, pres);
de_rank_table(expdef_file, res);
end