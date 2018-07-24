function [ poly_tf ] = frame2polygon( frame )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

frame = vl_frame2oell(frame);
A1 = utls.frame2afftf(frame);
poly = [-1, 1 1 -1 -1; -1, -1, 1, 1, -1];

poly_tf = utls.p2e(A1 * utls.e2p(poly(:, end:-1:1)));

end

