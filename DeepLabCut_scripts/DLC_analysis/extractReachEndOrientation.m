function [trialNumbers,end_orientation] = extractReachEndOrientation(reachData)
%
% for now, assume extracting the endpoints for the first reach
%

numTrials = length(reachData);
trialNumbers = NaN(numTrials,1);
end_orientation = NaN(numTrials,1);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).orientation)
        continue;
    end
    if isempty(reachData(iTrial).orientation{1})
        continue;
    end
    end_orientation(iTrial) = reachData(iTrial).orientation{1}(end);
    trialNumbers(iTrial) = reachData(iTrial).trialNumbers(2);
end