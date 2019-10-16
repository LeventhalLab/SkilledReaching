function [trialNumbers,end_aperture] = extractReachEndApertures(reachData)
%
% for now, assume extracting the endpoints for the first reach
%

numTrials = length(reachData);
trialNumbers = NaN(numTrials,1);
end_aperture = NaN(numTrials,1);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).aperture)
        continue;
    end
    if isempty(reachData(iTrial).aperture{1})
        continue;
    end
    end_aperture(iTrial) = reachData(iTrial).aperture{1}(end);
    trialNumbers(iTrial) = reachData(iTrial).trialNumbers(2);
end