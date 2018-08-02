function files = listfiles(path, varargin)
p = inputParser;
addRequired(p,'path');
addOptional(p,'keepext', true, @islogical);
addParameter(p,'fullpath', true, @islogical);
addParameter(p,'relpath', true, @islogical);
addParameter(p,'exclude', {}, @iscellstr);

parse(p, path, varargin{:});
opts = p.Results;

files = dir(path);
if isempty(files), files = {}; return; end
is_valid = ~[files.isdir] & arrayfun(@(d) d.name(1)~='.', files)';
files = {files.name};
files = files(is_valid);
if ~opts.keepext
  for fi = 1:numel(files), [~, files{fi}, ~] = fileparts(files{fi}); end;
end
if opts.fullpath
  files = cellfun(@(a) fullfile(fileparts(path), a), files, 'Uni', false);
  if opts.relpath
    files = cellfun(@(a) strrep(a, [pwd, filesep], ''), files, 'Uni', false);
  end
end

if ~isempty(opts.exclude)
  valid_files = ~ismember(files, opts.exclude);
  files = files(valid_files); 
end
end