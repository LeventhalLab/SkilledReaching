function [mean_aperture, std_aperture] = breakDownApertureByOutcome(reachData,validTrialOutcomes)

num_trials = length(reachData);
end_aperture = NaN(num_trials,1);
mean_aperture = NaN(1,length(validTrialOutcomes));
std_aperture = NaN(1,length(validTrialOutcomes));
outcomeFlag = false(num_trials,length(validTrialOutcomes));

for iTrial = 1 : num_trials

    current_outcome = reachData(iTrial).trialScores;
    
    for i_validType = 1 : length(validTrialOutcomes)
        if any(ismember(current_outcome,validTrialOutcomes{i_validType}))
            outcomeFlag(iTrial,i_validType) = true;   % this could be slightly inaccurate, but most trials only have 1 outcome
        end
    end
    
    if isempty(reachData(iTrial).aperture)
        continue;
    end
    if isempty(reachData(iTrial).aperture{1})
        continue;
    end
    end_aperture(iTrial) = reachData(iTrial).aperture{1}(end);

end

outcomeFlag(:,1) = true;  % work-around for sessions that haven't been scored

for i_outcome = 1 : length(validTrialOutcomes)
    mean_aperture(i_outcome) = nanmean(end_aperture(outcomeFlag(:,i_outcome)));
    std_aperture(i_outcome) = nanstd(end_aperture(outcomeFlag(:,i_outcome)));
end