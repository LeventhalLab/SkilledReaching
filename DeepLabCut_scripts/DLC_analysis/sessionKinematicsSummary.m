function [sessionSummary, reachData] = sessionKinematicsSummary(reachData,num_traj_segments)
%
% INPUTS
%   reachData - structure array containing reachData for each trial in a
%       session
%
% calculate the following kinematic parameters:
% 1. max velocity, by reach type
% 2. average trajectory for a session, by reach time
% 3. deviation from that trajectory for a session
% 4. distance between trajectories
% 5. closest distance paw to pellet
% 6. minimum z, by type
% 7. number of reaches, by type

num_trials = length(reachData);

min_slot_z = min([reachData.slot_z_wrt_pellet]);
sessionSummary.reachStart_z = collect_reachStart_pawTrajectory_z(reachData);   % first z-coordinate at which the paw dorsum was first identified for the first reach in this trial
min_reachStart_pd_z = min(sessionSummary.reachStart_z);

segmented_pd_trajectories = zeros(num_traj_segments,3,num_trials);
segmented_dig_trajectories = zeros(num_traj_segments,3,4,num_trials);

sessionSummary.pd_endPts = NaN(num_trials,3);
sessionSummary.dig_endPts = NaN(num_trials,3,4);
for i_trial = 1 : num_trials
    if ~any(reachData(i_trial).trialScores == 11) && ... % paw started through slot
       ~any(reachData(i_trial).trialScores == 6)  && ... % no reach on this trial
       ~any(reachData(i_trial).trialScores == 8)         % only used contralateral paw
       
        sessionSummary.pd_endPts(i_trial,:) = reachData(i_trial).pd_trajectory{1}(end,:);
        reachData(i_trial).segmented_pd_trajectory = standardizeSingleTrajectory(reachData(i_trial).pd_trajectory{1},min_reachStart_pd_z,num_traj_segments);
        
        segmented_pd_trajectories(:,:,i_trial) = reachData(i_trial).segmented_pd_trajectory;

        reachData(i_trial).segmented_dig_trajectory = zeros(num_traj_segments,3,4);
        for i_dig = 1 : 4
            cur_dig_trajectory = squeeze(reachData(i_trial).dig_trajectory{1}(:,:,i_dig));
            sessionSummary.dig_endPts(i_trial,:,i_dig) = cur_dig_trajectory(end,:);
            reachData(i_trial).segmented_dig_trajectory(:,:,i_dig) = standardizeSingleTrajectory(cur_dig_trajectory,min_slot_z,num_traj_segments);
        end
        segmented_dig_trajectories(:,:,:,i_trial) = reachData(i_trial).segmented_dig_trajectory;
    end
    
end

[sessionSummary.mean_pd_trajectory,sessionSummary.pd_mean_euc_dist_from_trajectory,sessionSummary.pd_var_euc_dist_from_trajectory] = ...
    calcTrajectoryStats(segmented_pd_trajectories);
% sessionSummary.mean_pd_trajectory = nanmean(segmented_pd_trajectories,3);
sessionSummary.mean_dig_trajectories = NaN(num_traj_segments,3,4);
sessionSummary.dig_mean_euc_dist_from_trajectory = NaN(num_traj_segments,4);
sessionSummary.dig_var_euc_dist_from_trajectory = NaN(num_traj_segments,4);
sessionSummary.mean_dig_endPts = NaN(3,4);
for i_dig = 1 : 4
    [sessionSummary.mean_dig_trajectories(:,:,i_dig),sessionSummary.dig_mean_euc_dist_from_trajectory(:,i_dig),sessionSummary.dig_var_euc_dist_from_trajectory(:,i_dig)] = ...
        calcTrajectoryStats(squeeze(segmented_dig_trajectories(:,:,i_dig,:)));
end

% calculate means, covariance matrices for paw dorsum and digit endpoints
sessionSummary.mean_pd_endPt = nanmean(sessionSummary.pd_endPts,1);
sessionSummary.mean_dig_endPts = squeeze(nanmean(sessionSummary.dig_endPts,1));

pd_x_ends = sessionSummary.pd_endPts(:,1);
valid_pd_x_ends = ~isnan(pd_x_ends);

sessionSummary.cov_dig_endPts = NaN(3,3,4);
if length(valid_pd_x_ends) > 1
    % if there's only one valid reach end point identified for this
    % session, don't bother computing covariance matrices - they're
    % meaningless
    sessionSummary.cov_pd_endPt = nancov(sessionSummary.pd_endPts);
    for i_dig = 1 : 4
        sessionSummary.cov_dig_endPts(:,:,i_dig) = nancov(squeeze(sessionSummary.dig_endPts(:,:,i_dig)));
    end
else
    sessionSummary.cov_pd_endPt = NaN(3,3);
end
    
end