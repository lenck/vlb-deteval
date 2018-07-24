function [ S ] = scmat( sc )
if size(sc, 1) == 1
  sc = [sc; sc];
end;
assert(size(sc, 1) == 2); 

S = zeros(3, 3, size(sc, 2));
S(1, 1, :) = sc(1, :);
S(2, 2, :) = sc(2, :);
S(3, 3, :) = 1;
end
