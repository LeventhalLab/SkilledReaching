function pl = trajectory_pathlength(interp_trajectory)
%
% INPUTS
%   interp_trajectory - m x 3 array where m is the number of points in the
%       trajectory

traj_diff = diff(interp_trajectory,1);

segment_distances = sqrt(sum(traj_diff.^2),2);

pl = sum(segment_distances);