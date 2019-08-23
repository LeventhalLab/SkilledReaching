function sessions_remaining = calcSessionsRemainingFromBlockLabels(sessionBlockLabels)
%
% INPUTS
%   sessionBlockLabels - vector
%
% OUTPUTS
% 

numSessionBlocks = sessionBlockLabels(end);
firstBlockSession = 1;
sessionNumbers = 1 : length(sessionBlockLabels);

for iBlock = 1 : numSessionBlocks
    
    lastBlockSession = find(sessionBlockLabels == iBlock,1,'last');
    
    sessions_remaining(firstBlockSession:lastBlockSession) = ...
        lastBlockSession - sessionNumbers(firstBlockSession:lastBlockSession);
    firstBlockSession = lastBlockSession + 1;
end