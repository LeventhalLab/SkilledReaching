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
min_reachStart_pd_z = min_reachStart_pawTrajectory_z(reachData);

segmented_pd_trajectories = zeros(num_traj_segments,3,num_trials);
segmented_dig_trajectories = zeros(num_traj_segments,3,4,num_trials);

for i_trial = 1 : num_trials

    reachData(i_trial).segmented_pd_trajectory = standardizeSingleTrajectory(reachData(i_trial).pd_trajectory{1},min_reachStart_pd_z,num_traj_segments);
    segmented_pd_trajectories(:,:,i_trial) = reachData(i_trial).segmented_pd_trajectory;
    
    reachData(i_trial).segmented_dig_trajectory = zeros(num_traj_segments,3,4);
    for i_dig = 1 : 4
        cur_dig_trajectory = squeeze(reachData(i_trial).dig_trajectory{1}(:,:,i_dig));
        reachData(i_trial).segmented_dig_trajectory(:,:,i_dig) = standardizeSingleTrajectory(cur_dig_trajectory,min_slot_z,num_traj_segments);
    end
    segmented_dig_trajectories(:,:,:,i_trial) = reachData(i_trial).segmented_dig_trajectory;
    
end

sessionSummary.mean_pd_trajectory = nanmean(segmented_pd_trajectories,3);
sessionSummary.mean_dig_trajectories = nanmean(segmented_dig_trajectories,4);

end