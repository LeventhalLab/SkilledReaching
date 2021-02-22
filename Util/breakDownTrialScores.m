function [score_breakdown,ind_trial_type] = breakDownTrialScores(reachData,validTrialTypes)
%
% INPUTS
%   reachData - structure array containing outcomes for each trial
%   validTrialTypes - cell array of trial types/scores to be counted up
%
% OUTPUTS
%   score_breakdown - vector containing the number of trials for each
%       validTrialType

numTrials = length(reachData);

score_breakdown = zeros(1,length(validTrialTypes));
ind_trial_type = zeros(numTrials,1);
for iTrial = 1 : numTrials
    current_outcome = reachData(iTrial).trialScores;
    
    if isempty(current_outcome)
        % workaround for in case session hasn't been scored
        current_outcome = 0;
    end
    
    for i_validType = 1 : length(validTrialTypes)
        if any(ismember(current_outcome,validTrialTypes{i_validType}))
            score_breakdown(i_validType) = score_breakdown(i_validType) + 1;
            ind_trial_type(iTrial) = i_validType;   % this could be slightly inaccurate, but most trials only have 1 outcome
        end
    end
    
end