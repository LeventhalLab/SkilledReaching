function [mean_trajectories] = averageTrajectoriesByOutcome(reachData,validTrialOutcomes)
%
% function to take the average trajectories for each reach/trial and
% estimate their (x,y,z) points at matched points along the curve to allow
% the trajectories to be averaged...


num_trials = length(reachData);
end_orientation = NaN(num_trials,1);
mean_orientations = NaN(1,length(validTrialOutcomes));
MRL = NaN(1,length(validTrialOutcomes));
outcomeFlag = false(num_trials,length(validTrialOutcomes));

for iTrial = 1 : num_trials

    current_outcome = reachData(iTrial).trialScores;
    
    for i_validType = 1 : length(validTrialOutcomes)
        if any(ismember(current_outcome,validTrialOutcomes{i_validType}))
            outcomeFlag(iTrial,i_validType) = true;   % this could be slightly inaccurate, but most trials only have 1 outcome
        end
    end
    
    if isempty(reachData(iTrial).orientation)
        continue;
    end
    end_orientation(iTrial) = reachData(iTrial).orientation{1}(end);
end

for i_outcome = 1 : length(validTrialOutcomes)
    mean_orientations(i_outcome) = nancirc_mean(end_orientation(outcomeFlag(:,i_outcome)));
    MRL(i_outcome) = nancirc_r(end_orientation(outcomeFlag(:,i_outcome)));
end