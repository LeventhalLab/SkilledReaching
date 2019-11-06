function reachStart_z = collect_reachStart_pawTrajectory_z(reachData)

num_trials = length(reachData);

reachStart_z = NaN(num_trials,1);

for i_trial = 1 : num_trials
    if any(reachData(i_trial).trialScores == 11) || ...  % paw started through slot
       any(reachData(i_trial).trialScores == 6)   % no reach on this trial
        continue;
    end
    try
    reachStart_z(i_trial) = reachData(i_trial).pd_trajectory{1}(1,3);
    catch
        keyboard
    end
end


end