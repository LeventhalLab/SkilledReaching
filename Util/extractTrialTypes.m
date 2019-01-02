function validIdx = extractTrialTypes(reachScores,scores_to_extract)
%
% INPUTS
%   reachScores - array containing reach scores
%   scores_to_extract - vector containing valid scores for which this
%       function will identify trials
%
% OUTPUTS
%   validIdx - boolean array the same size as reachScores with true
%       indicating that a trial matches one of the scores_to_extract types

% 0 - No pellet, mechanical failure
% 1 -  First trial success (obtained pellet on initial limb advance)
% 2 -  Success (obtain pellet, but not on first attempt)
% 3 -  Forelimb advance -pellet dropped in box
% 4 -  Forelimb advance -pellet knocked off shelf
% 5 -  Obtain pellet with tongue
% 6 -  Walk away without forelimb advance, no forelimb advance
% 7 -  Reached, pellet remains on shelf
% 8 - Used only contralateral paw
% 9 - Laser fired at the wrong time
% 10 ?Used preferred paw after obtaining or moving pellet with tongue

validIdx = false(size(reachScores));
for iType = 1 : length(scores_to_extract)
    
    validIdx = validIdx | (reachScores == scores_to_extract(iType));
    
end