function standardized_trajectory = standardizeSingleTrajectory(interp_trajectory,max_z,n)

% function to take a single reaching trajectory, beginning at some maximum
% z-value (to make sure artificial differences aren't introduced by
% different starting points), and divide the trajectory into n evenly
% spaced points
%
% INPUTS
%   interp_trajectory - trajectory for this bodypart for this reach (the
%      "interp" part is that this should be the trajectory with
%      interpolated points from the original 3D analysis)
%   max_z - maximum z-value at which to cut off the trajectory (so all
%       trajectories start at the same z-coordiate)
%   n - number of points to dive the trajectory into
%
% OUTPUTS
%   standardized_trajectory - trajectory segmented into n equally spaced
%       points using piecewise cubic hermite interpolating polynomials
%       (pchip)

traj_to_segment = interp_trajectory(interp_trajectory(:,3) <= max_z,:);
if size(traj_to_segment,1) < 2
    % not enough points found to segment the trajectory
    standardized_trajectory = NaN(n,3);
    return
end
try
standardized_trajectory = interparc(n,traj_to_segment(:,1),traj_to_segment(:,2),traj_to_segment(:,3),'pchip');
catch
    keyboard
end

end