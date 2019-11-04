function interpolatedOrientations = interpolateOrientations(normalized_digit_trajectories,smoothed_digit_trajectories,bodyparts,pawOrientationTrajectories,pawPref)

part_idx_to_align_with_orientations = 10;    % should be the tip of digit 2

% [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
numTrials = length(pawOrientationTrajectories);
numPointsPerTrajectory = size(normalized_digit_trajectories,2);

for iTrial = 1 : numTrials
    
    cur_smoothed_trajectory = squeeze(smoothed_digit_trajectories{iTrial,part_idx_to_align_with_orientations})
    cur_normalized_trajectory = 
    
    for iPoint = 1 : numPointsPerTrajectory