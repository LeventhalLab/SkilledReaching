function truncated_trajectory = find_trajectory_start_point(init_trajectory, start_z)
%
% when doing the trajectory interpolation, find the first time the current
% trajectory passes start_z
%
% INPUTS
%   init_trajectory - numFrames x 3 matrix containing coordinates of the
%       paw part
%   start_z - farthest point in the z-dimension from the camera to start
%       the trajectory
%
% OUTPUTS
%   truncated_trajectory - points in init_trajectory after the start point

z = init_trajectory(:,3);

first_valid_point = find(z < start_z,1);

if first_valid_point > 1
	truncated_trajectory = init_trajectory(first_valid_point-1:end,:);
    edge_pts = truncated_trajectory(1:2,:);
    % find the point along the line between the first valid point and the
    % immediately preceding point at z = start_z
    fract_along_line = (start_z - edge_pts(1,3)) / (edge_pts(2,3)-edge_pts(1,3));
    start_pt = edge_pts(1,:) + diff(edge_pts) * fract_along_line;
    truncated_trajectory(1,:) = start_pt;
else
    truncated_trajectory = init_trajectory;
end