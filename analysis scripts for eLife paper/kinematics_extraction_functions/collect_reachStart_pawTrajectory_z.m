function reachStart_z = collect_reachStart_pawTrajectory_z(reachData)
%   reachData - structure to hold data for individual reaches within trials
%       with the following fields (array with one entry per trial)
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
%
% OUTPUTS:
%   reachStart_z - vector containing the maximum z-coordinate of the 
%           paw dorsum for the first reach in each trial. Ignores trials
%           where the paw started through the slot, there was no reach, or
%           the contralateral paw was used

num_trials = length(reachData);

reachStart_z = NaN(num_trials,1);

for i_trial = 1 : num_trials
    if any(reachData(i_trial).trialScores == 11) || ...  % paw started through slot
       any(reachData(i_trial).trialScores == 6)  || ... % no reach on this trial
       any(reachData(i_trial).trialScores == 8)             % only used contralateral paw
        continue;
    end
    if ~isempty(reachData(i_trial).pd_trajectory)
        % sometimes the paw dorsum is caught behind the slot and the reach
        % trajectory doesn't exist
        reachStart_z(i_trial) = reachData(i_trial).pd_trajectory{1}(1,3);
    end
end


end