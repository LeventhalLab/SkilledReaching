function standardized_trajectory = standardizeSingleTrajectory(interp_trajectory,max_z,n)

% function to take a single reaching trajectory, beginning at some maximum
% z-value (to make sure artificial differences aren't introduced by
% different starting points), and divide the trajectory into n evenly
% spaced points

