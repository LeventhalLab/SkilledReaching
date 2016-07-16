function [unnormalized_points] = unnormalize_points(points2d, K)
% INPUTS
%   points2d - m x 2 array containing (x,y) pairs in each row
%   K - intrinsic matrix (lower triangular format)
homogeneous_points = [points2d,ones(size(points2d,1),1)];
unnormalized_points  = homogeneous_points * K;
unnormalized_points = bsxfun(@rdivide,unnormalized_points(:,1:2),unnormalized_points(:,3));

end