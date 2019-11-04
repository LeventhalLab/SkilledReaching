function smoothed_trajectories = smooth_and_align_Trajectory(trajectories3D, triggerTimes, frameRate, session_mp)

% triggerTime is a vector for the trigger times for the entire session
% figure out where the front panel is


% figure out where the floor is

triggerFrames = triggerTimes * frameRate;

% set the trigger frame as frame 300

for iTraj = 1 : length(triggerTimes)
    
    
    
end