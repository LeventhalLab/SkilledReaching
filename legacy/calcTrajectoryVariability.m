function [mean_trajectory, mean_xyz_from_trajectory, mean_euc_dist_from_trajectory] = ...
    calcTrajectoryVariability(normalized_trajectories,trialTypeIdx)

numPointsPerTrajectory = size(normalized_trajectories,1);
numTrialTypes_to_analyze = size(trialTypeIdx,2);

mean_xyz_from_trajectory = zeros(numPointsPerTrajectory,3,numTrialTypes_to_analyze);
mean_euc_dist_from_trajectory = zeros(numPointsPerTrajectory,numTrialTypes_to_analyze);

mean_trajectory = zeros(size(normalized_trajectories,1),size(normalized_trajectories,2),numTrialTypes_to_analyze);
for iType = 1 : numTrialTypes_to_analyze
    mean_trajectory(:,:,iType) = nanmean(normalized_trajectories(:,:,trialTypeIdx(:,iType)),3);
    
    numTrials = sum(trialTypeIdx(:,iType));
    
    current_mean_trajectory = squeeze(mean_trajectory(:,:,iType));
    
    dist_from_trajectory = normalized_trajectories(:,:,trialTypeIdx(:,iType)) - repmat(current_mean_trajectory,1,1,numTrials);
    euclidean_dist_from_trajectory = sqrt(squeeze(sum(dist_from_trajectory.^2,2)));
    mean_xyz_from_trajectory(:,:,iType) = nanmean(abs(dist_from_trajectory),3);
    mean_euc_dist_from_trajectory(:,iType) = nanmean(euclidean_dist_from_trajectory,2);
    
end