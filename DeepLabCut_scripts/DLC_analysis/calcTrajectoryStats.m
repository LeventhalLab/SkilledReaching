function [mean_trajectory, mean_euc_dist_from_trajectory,var_euc_dist_from_trajectory] = calcTrajectoryStats(all_trajectories)
% INPUTS
%	all_trajectories - n x 3 x num_trials array where n is the number of
%       points in "standardized" trajectories


mean_trajectory = nanmean(all_trajectories, 3);

dist_from_mean_trajectory = bsxfun(@minus,all_trajectories,mean_trajectory);

euc_dist_from_mean_trajectory = squeeze(sqrt(sum(dist_from_mean_trajectory.^2,2)));

mean_euc_dist_from_trajectory = mean(euc_dist_from_mean_trajectory,2);

var_euc_dist_from_trajectory = mean_euc_dist_from_trajectory / size(all_trajectories,3);

end