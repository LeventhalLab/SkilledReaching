function [aperture_traj, mean_aperture_traj, std_aperture_traj,sem_aperture_traj] = breakDownFullApertureByOutcome(reachData,z_interp_digits)

num_trials = length(reachData);

traj_limits = align_trajectory_to_reach(reachData);
aperture_traj = NaN(num_trials, length(z_interp_digits));
for iTrial = 1 : num_trials

    if isempty(reachData(iTrial).aperture)
        continue;
    end
    if isempty(reachData(iTrial).aperture{1})
        continue;
    end
    
    graspFrames = traj_limits(iTrial).reach_aperture_lims(1,1) : ...
        traj_limits(iTrial).reach_aperture_lims(1,2);
    dig2_z = reachData(iTrial).dig2_trajectory{1}(graspFrames,3);
    
    if length(reachData(iTrial).aperture{1}) > 1
        cur_apertures = pchip(dig2_z,reachData(iTrial).aperture{1},z_interp_digits);
    else
        cur_apertures = NaN(size(z_interp_digits));
    end
    
    cur_apertures(z_interp_digits < min(dig2_z)) = NaN;
    cur_apertures(z_interp_digits > max(dig2_z)) = NaN;
    aperture_traj(iTrial,:) = cur_apertures;
end
mean_aperture_traj = nanmean(aperture_traj);
std_aperture_traj = nanstd(aperture_traj,0,1);
numValidPoints = sum(~isnan(aperture_traj));

sem_aperture_traj = std_aperture_traj ./ sqrt(numValidPoints);

end