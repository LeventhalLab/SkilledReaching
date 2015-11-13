function [new_points, idx] = sortClockWise(referencePoint, points)
%
% INPUTS:
%   referencePoint - the "center" point around which to generate the
%       clockwise rotation. 1 x 2 row vector
%   points - m x 2 array where each row is another point to sort in the
%       clockswise direction
%
% OUTPUTS:
%   new_points - the sorted points
%   idx - the indices of the sorted points in the original array

points_diff = bsxfun(@minus, points, referencePoint);

points_angles = angle(points_diff(:,1) + 1i*points_diff(:,2));
[~,idx] = sort(points_angles);

new_points = points(idx,:);