function [PL_summary] = collectTrajectoryLengths(trajectoryLengths)

PL_summary.pd_pre_slot = [trajectoryLengths.pd_pre_slot]';

for iTrial = 1 : length(trajectoryLengths)
    PL_summary.digit_traj_length(iTrial) = trajectoryLengths(iTrial).digit_traj_length(10);   % for now, hardcoding in that we're using the tip of the second digit
end