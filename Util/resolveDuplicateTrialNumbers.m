function realignedTrialNumbers = resolveDuplicateTrialNumbers(trialNumbers)
%
% INPUTS
%   trialNumbers - list of trial number labels for individual trials in a
%       session. Sometimes if the session was restarted in LabVIEW, trial
%       number labeling starts over. This is to make sure that each video
%       is analyzed separately
%
% OUTPUTS
%   realignedTrialNumbers - renumbered trials such that if the session was
%       restarted, trial numbering picks up where it left off. For example,
%       suppose after trial 10, the session restarted. Then trials labeled
%       numbers 2,5,7 after the reset would be identified as 12,15,17 in 
%       realignedTrialNumbers

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
    
    if i_reset == length(resetIdx)
        realignedTrialNumbers(resetIdx(i_reset)+1:end) = ...
            realignedTrialNumbers(resetIdx(i_reset)+1:end) + realignedTrialNumbers(resetIdx(i_reset));
    else
        realignedTrialNumbers(resetIdx(i_reset)+1:resetIdx(i_reset+1)) = ...
            realignedTrialNumbers(resetIdx(i_reset)+1:resetIdx(i_reset+1)) + realignedTrialNumbers(resetIdx(i_reset));
    end
end