function [orientation_traj, mean_orientation_traj, MRL_traj] = breakDownFullOrientationByOutcome(reachData,z_interp_digits)

num_trials = length(reachData);

traj_limits = align_trajectory_to_reach(reachData);
orientation_traj = NaN(num_trials, length(z_interp_digits));
for iTrial = 1 : num_trials

    if isempty(reachData(iTrial).orientation)
        continue;
    end
    if isempty(reachData(iTrial).orientation{1})
        continue;
    end
    
    graspFrames = traj_limits(iTrial).reach_aperture_lims(1,1) : ...
        traj_limits(iTrial).reach_aperture_lims(1,2);
%     dig2_z = reachData(iTrial).dig2_trajectory{1}(graspFrames,3);
    dig2_z = reachData(iTrial).dig_trajectory{1}(graspFrames,3,2);
    
    if length(reachData(iTrial).aperture{1}) > 1
        cur_orientations = pchip(dig2_z,reachData(iTrial).orientation{1},z_interp_digits);
    else
        cur_orientations = NaN(size(z_interp_digits));
    end
    
    cur_orientations(z_interp_digits < min(dig2_z)) = NaN;
    cur_orientations(z_interp_digits > max(dig2_z)) = NaN;
    orientation_traj(iTrial,:) = cur_orientations;
end
mean_orientation_traj = nancirc_mean(orientation_traj);
mean_orientation_traj(mean_orientation_traj==0) = NaN;
MRL_traj = nancirc_r(orientation_traj);
MRL_traj(MRL_traj==0) = NaN;

end