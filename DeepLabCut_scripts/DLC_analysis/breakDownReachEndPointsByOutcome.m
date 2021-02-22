function [mean_pd_endPt,cov_pd_endPts,mean_dig_endPts,cov_dig_endPts] = ...
    breakDownReachEndPointsByOutcome(reachData,validTrialOutcomes)

num_trials = length(reachData);
num_possOutcomes = length(validTrialOutcomes);

pd_endPts = NaN(num_trials,3);
dig_endPts = NaN(num_trials,4,3);

mean_pd_endPt = zeros(num_possOutcomes,3);
mean_dig_endPts = zeros(num_possOutcomes,4,3);

cov_pd_endPts = NaN(num_possOutcomes,3,3);
cov_dig_endPts = NaN(num_possOutcomes,4,3,3);

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
%         for i_dig = 1 : 4
            dig_endPts(iTrial,:,:) = reachData(iTrial).dig_endPoints(1,:,:);
%         end
    end
    
end

outcomeFlag(:,1) = true;  % work-around for sessions that haven't been scored

for i_outcome = 1 : length(validTrialOutcomes)
    mean_pd_endPt(i_outcome,:) = nanmean(pd_endPts(outcomeFlag(:,i_outcome),:));
    cov_pd_endPts(i_outcome,:,:) = nancov(pd_endPts(outcomeFlag(:,i_outcome),:));
    
    for i_dig = 1 : 4
        cur_dig_endPts = squeeze(dig_endPts(outcomeFlag(:,i_outcome),i_dig,:));
        mean_dig_endPts(i_outcome,i_dig,:) = nanmean(cur_dig_endPts,1);
        cov_dig_endPts(i_outcome,i_dig,:,:) = nancov(cur_dig_endPts);
    end
end