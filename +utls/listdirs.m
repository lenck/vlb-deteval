function dirs = listdirs(path)
if ~exist(path, 'dir'), error('Dir %s does not exist', path); end;
dirs = dir(path);
is_valid = [dirs.isdir] & arrayfun(@(d) d.name(1)~='.', dirs)';
dirs = {dirs.name};
dirs = dirs(is_valid);
end