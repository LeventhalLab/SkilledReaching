function [mean_num_reaches, std_num_reaches] = breakDownReachesByOutcome(reachData,validTrialOutcomes)

num_trials = length(reachData);
num_reaches = zeros(num_trials,1);
mean_num_reaches = zeros(1,length(validTrialOutcomes));
std_num_reaches = zeros(1,length(validTrialOutcomes));
outcomeFlag = false(num_trials,length(validTrialOutcomes));

for iTrial = 1 : num_trials

    current_outcome = reachData(iTrial).trialScores;
    
    for i_validType = 1 : length(validTrialOutcomes)
        if any(ismember(current_outcome,validTrialOutcomes{i_validType}))
            outcomeFlag(iTrial,i_validType) = true;   % this could be slightly inaccurate, but most trials only have 1 outcome
        end
    end
    
    num_reaches(iTrial) = length(reachData(iTrial).reachEnds);
end

outcomeFlag(:,1) = true;  % work-around for sessions that haven't been scored

for i_outcome = 1 : length(validTrialOutcomes)
    mean_num_reaches(i_outcome) = mean(num_reaches(outcomeFlag(:,i_outcome)));
    std_num_reaches(i_outcome) = std(num_reaches(outcomeFlag(:,i_outcome)));
end