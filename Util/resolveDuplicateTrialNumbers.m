function realignedTrialNumbers = resolveDuplicateTrialNumbers(trialNumbers)

realignedTrialNumbers = trialNumbers;

% look for trialNumbers where trialNumber(N+1) <= trialNumber(N) (should be
% monotonically increasing since they're ordered by acquisition time in the
% folder)
trialDiff = diff(trialNumbers);
resetIdx = find(trialDiff <= 0);

if isempty(resetIdx)
    return;
end
    
for i_reset = 1 : length(resetIdx)
    
    realignedTrialNumbers(resetIdx(i_reset)+1:end) = ...
        realignedTrialNumbers(resetIdx(i_reset)+1:end) + realignedTrialNumbers(resetIdx(i_reset));
    
end