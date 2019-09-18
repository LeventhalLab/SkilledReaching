function trialReachEndFrames = determineTrialReachEndFrames(reachFrames_for_each_bodypart,bodyparts,pawPref)
%
% INPUTS
%   reachFrames_for_each_bodypart - cell array containing reach end points
%       for each bodypart
%   bodyparts - cell array of strings identifying each body part
%
% OUTPUTS
%   trialReachEndFrames

minFrameSepBetweenReaches = 10;
[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);

% find reach end points based on the positions of the 2nd or 3rd digits
validParts = digIdx(2:3);

endFrames = [];

for i_bp = 1 : length(validParts)
    
    if isrow(reachFrames_for_each_bodypart{validParts(i_bp)})
        cur_endFrames = reachFrames_for_each_bodypart{validParts(i_bp)}';
    else
        cur_endFrames = reachFrames_for_each_bodypart{validParts(i_bp)};
    end
    
    endFrames = [endFrames;cur_endFrames];

end

trialReachEndFrames = removeNearbyElementsFromArray(endFrames,minFrameSepBetweenReaches);