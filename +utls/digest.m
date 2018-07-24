function [ hash ] = digest( string, varargin )
opts.type = 'SHA-256';
opts = vl_argparse(opts, varargin);
opts.type = upper(opts.type);
VALID_TYPES = {'MD5', 'SHA-1', 'SHA-256'};
assert(ismember(opts.type, VALID_TYPES), 'Invalid hash type.');

try
  md = java.security.MessageDigest.getInstance(opts.type);
  digest = dec2hex(typecast(md.digest(cast(string, 'uint8')), 'uint8'));
  hash = lower(reshape(digest',1,[]));
catch me
  error('Failed to calculate the hash');
end

end

