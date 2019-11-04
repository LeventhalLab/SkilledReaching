function [reachEndPoints,distFromPellet] = collectReachEndPoints(all_endPts,validTrialTypes,all_trialOutcomes)
%
% INPUTS
%   all_endPts - array containing final location of each body part at reach
%       terminus. m x 3 x n, where m is the number of bodyparts, and n is
%       the number of trials. The values are w.r.t the pellet
%
% OUTPUTS
%   reachEndPoints - 


% trialOutcomes: 
% 0 ? No pellet, mechanical failure
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

numTrialTypes_to_analyze = length(validTrialTypes);
reachEndPoints = cell(numTrialTypes_to_analyze,1);
distFromPellet = cell(numTrialTypes_to_analyze,1);

trialTypeIdx = false(length(all_trialOutcomes),numTrialTypes_to_analyze);
num_bodyparts = size(all_endPts,1);
for iType = 1 : numTrialTypes_to_analyze
    
    trialTypeIdx(:,iType) = extractTrialTypes(all_trialOutcomes,validTrialTypes{iType});
    reachEndPoints{iType} = squeeze(all_endPts(:,:,trialTypeIdx(:,iType)));
    
    % create an array num_bodyparts x 3 x number of trials of this type
    distFromPellet{iType} = zeros(num_bodyparts,sum(trialTypeIdx(:,iType)));
    for i_bodypart = 1 : num_bodyparts
        cur_endPts = squeeze(reachEndPoints{iType}(i_bodypart,:,:));
        distFromPellet{iType}(i_bodypart,:) = sqrt(sum(cur_endPts.^2));
%         distFromPellet{iType}(i_bodypart,:,:) = 
    end
    
end

end

    
    