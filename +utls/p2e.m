function [ pts ] = p2e( pts )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
pts = pts./repmat(pts(size(pts,1),:),size(pts,1),1);
pts = pts(1:size(pts,1)-1,:);

end

