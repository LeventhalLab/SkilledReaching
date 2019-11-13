function [mean_pd_endPt,cov_pd_endPts,mean_dig2_endPt,cov_dig2_endPts] = ...
    breakDownReachEndPointsByOutcome(reachData,validTrialOutcomes)

num_trials = length(reachData);
num_possOutcomes = length(validTrialOutcomes);

pd_endPts = NaN(num_trials,3);
dig_endPts = NaN(num_trials,4,3);

mean_pd_endPt = zeros(num_possOutcomes,3);
mean_dig2_endPt = zeros(num_possOutcomes,3);

cov_pd_endPts = zeros(num_possOutcomes,3,3);
cov_dig_endPts = zeros(num_possOutcomes,4,3,3);

outcomeFlag = false(num_trials,length(validTrialOutcomes));
for iTrial = 1 : num_trials

    current_outcome = reachData(iTrial).trialScores;
    
    for i_validType = 1 : length(validTrialOutcomes)
        if any(ismember(current_outcome,validTrialOutcomes{i_validType}))
            outcomeFlag(iTrial,i_validType) = true;   % this could be slightly inaccurate, but most trials only have 1 outcome
        end
    end
    
    if ~isempty(reachData(iTrial).reachEnds)
        pd_endPts(iTrial,:) = reachData(iTrial).pdEndPoints(1,:);
        for i_dig = 1 : 4
            dig_endPts(iTrial,i_dig,:) = reachData(iTrial).dig2_endPoints(1,:);
        end
    end
    
end

for i_outcome = 1 : length(validTrialOutcomes)
    mean_pd_endPt(i_outcome,:) = nanmean(pd_endPts(outcomeFlag(:,i_outcome),:));
    cov_pd_endPts(i_outcome,:,:) = nancov(pd_endPts(outcomeFlag(:,i_outcome),:));
    
    for i_dig = 1 : 4
        mean_dig2_endPt(i_outcome,:) = nanmean(dig2_endPts(outcomeFlag(:,i_outcome),:));
        cov_dig2_endPts(i_outcome,:,:) = nancov(dig2_endPts(outcomeFlag(:,i_outcome),:));
    end
end

ratSummary.cov_dig_endPts = NaN(numSessions_to_analyze,num_outcome_categories,4,3,3);
ratSummary.mean_dig_endPt = NaN(numSessions_to_analyze,num_outcome_categories,4,3);