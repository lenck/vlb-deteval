function [ R ] = rotmat( rot )
R = zeros(3, 3, numel(rot));
R(3, 3, :) = 1;
R(1, 1, :) = cos(rot);
R(1, 2, :) = -sin(rot);
R(2, 1, :) = sin(rot);
R(2, 2, :) = cos(rot);
end

