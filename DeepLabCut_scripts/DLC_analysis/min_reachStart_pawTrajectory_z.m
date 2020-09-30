function min_reachStart_z = min_reachStart_pawTrajectory_z(reachData)

num_trials = length(reachData);

reachStart_z = NaN(num_trials,1);

for i_trial = 1 : num_trials
    
    reachStart_z(i_trial) = reachData(i_trial).pd_trajectory{1}(1,3);
    
end

min_reachStart_z = min(reachStart_z);

end