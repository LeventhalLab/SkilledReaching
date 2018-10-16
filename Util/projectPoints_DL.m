function points2d = projectPoints_DL(points3d, P)
%
% INPUTS
%   points3d - m x 3 matrix where m is the number of points
%
% OUTPUTS
%

points3dHomog = [points3d, ones(size(points3d, 1), 1, 'like', points3d)];
points2dHomog = points3dHomog * P;
points2d = bsxfun(@rdivide, points2dHomog(:, 1:2), points2dHomog(:, 3));

end