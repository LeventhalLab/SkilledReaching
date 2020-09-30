function [mean_trajectory, mean_euc_dist_from_trajectory,var_euc_dist_from_trajectory] = calcTrajectoryStats(all_trajectories)
% INPUTS
%	all_trajectories - n x 3 x num_trials array where n is the number of
%       points in "standardized" trajectories
%
% OUTPUTS
%   mean_trajectory - mean trajectory (excluding NaNs)
%   dist_from_mean_trajectory - mean distance of all trajectories from the
%       mean trajectory (vector on n points)
%   var_euc_dist_from_trajectory - variance of all trajectories' distance
%       from the mean trajectory (vector of n points)


mean_trajectory = nanmean(all_trajectories, 3);

dist_from_mean_trajectory = bsxfun(@minus,all_trajectories,mean_trajectory);

euc_dist_from_mean_trajectory = squeeze(sqrt(nansum(dist_from_mean_trajectory.^2,2)));

mean_euc_dist_from_trajectory = mean(euc_dist_from_mean_trajectory,2);

% figure out number of valid trajectories
temp = squeeze(all_trajectories(1,1,:));
numValidTrajectories = sum(~isnan(temp));
var_euc_dist_from_trajectory = mean_euc_dist_from_trajectory / numValidTrajectories;

end