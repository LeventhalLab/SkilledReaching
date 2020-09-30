function [trialNumbers,pd_endPts, dig2_endPts] = extractReachEndPoints(reachData)
%
% for now, assume extracting the endpoints for the first reach
%

numTrials = length(reachData);

trialNumbers = zeros(numTrials,1);

pd_endPts = NaN(numTrials,3);
dig2_endPts = NaN(numTrials,3);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).pdEndPoints)
        continue;
    end
    pd_endPts(iTrial,:) = reachData(iTrial).pdEndPoints(1,:);
    dig2_endPts(iTrial,:) = squeeze(reachData(iTrial).dig_endPoints(1,2,:))';
    trialNumbers(iTrial) = reachData(iTrial).trialNumbers(2);
end