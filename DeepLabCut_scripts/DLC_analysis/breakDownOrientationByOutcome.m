function [mean_orientations,MRL] = breakDownOrientationByOutcome(reachData,validTrialOutcomes)

num_trials = length(reachData);
end_orientation = NaN(num_trials,1);
grasp_end_orientation = NaN(num_trials,1);
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
    if isempty(reachData(iTrial).orientation{1})
        continue;
    end
    end_orientation(iTrial) = reachData(iTrial).orientation{1}(end);

end

outcomeFlag(:,1) = true;  % work-around for sessions that haven't been scored

for i_outcome = 1 : length(validTrialOutcomes)

    if any(outcomeFlag(:,i_outcome))   % is there at least one trial of this type?
        mean_orientations(i_outcome) = nancirc_mean(end_orientation(outcomeFlag(:,i_outcome)));
        MRL(i_outcome) = nancirc_r(end_orientation(outcomeFlag(:,i_outcome)));
    end
    
end