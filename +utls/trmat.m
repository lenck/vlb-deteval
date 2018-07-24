function [ T ] = trmat( tr )
if numel(tr) == 2, tr = reshape(tr, 2, 1); end;
assert(size(tr, 1) == 2);

T = zeros(3, 3, size(tr, 2));
T(1, 1, :) = 1;
T(2, 2, :) = 1;
T(3, 3, :) = 1;
T(1, 3, :) = tr(1, :);
T(2, 3, :) = tr(2, :);
end

