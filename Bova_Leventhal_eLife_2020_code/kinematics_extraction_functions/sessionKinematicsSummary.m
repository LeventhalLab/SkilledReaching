function [sessionSummary, reachData] = sessionKinematicsSummary(reachData,num_traj_segments)
%
% INPUTS
%   reachData - structure to hold data for individual reaches within trials
%       with the following fields:
%       .reachEnds - vector containing frames at which each
%            reach terminates (based on digit 2)
%       .graspEnds - vector containing frames at which each
%            grasp terminates. Grasps occur at the end of each reach, but
%            could also be identified if the rat makes another grasp
%            without retracting its paw
%       .reachStarts - vector containing frames at which each reach
%            starts (based on paw dorsum)
%       .graspStarts - when digit 2 started moving forward before a given
%           graspEnd frame
%       .pdEndPoints - n x 3 array (calculated in sessionKinematicsSummary)
%           containing the endpoints of the paw dorsum in 3D for each reach
%       .slotBreachFrame - vector containing frame at which the paw
%            breached the slot for each reach
%       .firstDigitKinematicsFrame - vector containing first frame at which
%           digit kinematics could be identified for each reach
%       .pd_trajectory - cell array containing n x 3 arrays where each
%           array contains (x,y,z) coordinates for each reach within a
%           trial
%       .pd_pathlength - total paw dorsum path length for each reach (sum 
%           of distances between each point along trajectory)
%       .segmented_pd_trajectory - paw dorsum trajectory segmented into a
%           consistent number of segments (default 100)
%       .pd_v - cell array of vectors containing tangential velocity of paw
%           dorsum for each reach
%       .max_pd_v - maximum paw dorsum velocity for each reach
%       .dig_trajectory - cell array of n x 3 x 4 arrays where each array
%           contains (x,y,z) trajectories for each digit (n is the number
%           of points along the trajectory)
%       .dig_pathlength - array of pathlengths for each digit in each reach
%       .segmented_dig_trajectory - array containing individual digit
%           trajectories segmented into consistent numbers of points
%       .dig2_v - cell array of digit 2 tangential velocities for each
%           reach
%       .max_dig2_v - maximum digit 2 velocity
%       .dig_endPoints - end points for each digit in each reach
%       .orientation - cell array of vectors containing paw orientation at
%           each point along the digit trajectory
%       .aperture - cell array of vectors containing digit apertures at
%           each point along the digit trajectory
%       .trialScores - scores read in from trial scores data sheets, but
%           also automatically estimated (e.g., could have no pellet and
%           reach with the wrong paw)
%       .ratIDnum - integer with rat ID number
%       .sessionDate - date session was recorded as a datetime variable
%       .trialNumbers - 2-element vector; first element is the actual trial
%           number in the video name; second element is the total number in
%           the sesson; could be different if labview restarted mid-session
%       .slot_z_wrt_pellet - z-coordinate of the reaching slot with respect to
%           the pellet
%   num_traj_segments - number of segments to divide the standardized
%       trajectories into
%
% OUTPUTS
%   sessionSummary - structure containing summary data for this session
%       with the following fields:
%       .reachStart_z - vector containing the maximum z-coordinate of the 
%           paw dorsum for the first reach in each trial
%       .pd_endPts - num_trials x 3 array containing (x,y,z) end points of
%           the paw dorsum for the first reach of each trial
%       .dig_endPts - num_trials x 3 x 4 array containing (x,y,z) end
%           points of each digit for the first reach of each trial
%       .mean_pd_trajectory - n x 3 array where n is the number of points
%           in each standardized trajectory. each row contains (x,y,z)
%           coordinates of a point along the mean paw dorsum trajectory for
%           the first reach in a trial
%       .pd_mean_euc_dist_from_trajectory - mean distance of all
%           trajectories from the mean trajectory  for the paw dorsum
%           (vector on n points)
%       .pd_var_euc_dist_from_trajectory - variance of all paw dorsum 
%           trajectories' distance from the mean trajectory (vector of n 
%           points)
%       .mean_dig_trajectories - n x 3 x 4 array containing mean
%           standardized digit trajectories for the first reach in each
%           trial
%       .dig_mean_euc_dist_from_trajectory - mean distance of all
%           trajectories from the mean trajectory for each digit
%           (n x 4 array)
%       .dig_var_euc_dist_from_trajectory - variance of all digit 
%           trajectories' distance from the mean trajectories (n x 4 array) 
%       .mean_dig_endPts - mean end point of each digit for the first reach
%           of each trial (3 x 4 array)
%       .mean_pd_endPt - mean paw dorsum end point of the first reach in
%           each trial (x,y,z vector)
%       .cov_dig_endPts - covariance matrices of the end point of each
%           digit for the first reach of each trial (3x3x4 array)
%       .cov_pd_endPt - covariance matrix of the end point of the paw
%           dorsum for the first reach of each trial (3 x 3 array)
%   reachData - same as above. structure array with one entry per trial in
%       this session
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

segmented_pd_trajectories = NaN(num_traj_segments,3,num_trials);
segmented_dig_trajectories = NaN(num_traj_segments,3,4,num_trials);

sessionSummary.pd_endPts = NaN(num_trials,3);
sessionSummary.dig_endPts = NaN(num_trials,3,4);
for i_trial = 1 : num_trials
    if ~any(reachData(i_trial).trialScores == 11) && ... % paw started through slot
       ~any(reachData(i_trial).trialScores == 6)  && ... % no reach on this trial
       ~any(reachData(i_trial).trialScores == 8)         % only used contralateral paw
       
        if ~isempty(reachData(i_trial).pd_trajectory)
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