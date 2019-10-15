function [mean_pd_v, std_pd_v] = breakDownVelocityByOutcome(reachData,validTrialOutcomes)

num_trials = length(reachData);
max_pd_v = NaN(num_trials,1);
mean_pd_v = NaN(1,length(validTrialOutcomes));
std_pd_v = NaN(1,length(validTrialOutcomes));
outcomeFlag = false(num_trials,length(validTrialOutcomes));

for iTrial = 1 : num_trials

    current_outcome = reachData(iTrial).trialScores;
    
    for i_validType = 1 : length(validTrialOutcomes)
        if any(ismember(current_outcome,validTrialOutcomes{i_validType}))
            outcomeFlag(iTrial,i_validType) = true;   % this could be slightly inaccurate, but most trials only have 1 outcome
        end
    end
    
    if isempty(reachData(iTrial).pd_v)
        continue;
    end
    max_pd_v(iTrial) = max(reachData(iTrial).pd_v{1});
end

for i_outcome = 1 : length(validTrialOutcomes)
    mean_pd_v(i_outcome) = nanmean(max_pd_v(outcomeFlag(:,i_outcome)));
    std_pd_v(i_outcome) = nanstd(max_pd_v(outcomeFlag(:,i_outcome)));
end