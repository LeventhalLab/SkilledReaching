function [all_reachEndPoints,numReaches_byPart,numReaches,reachFrames,reach_endPoints] = ...
    collectall_reachEndPoints(all_reachFrameIdx,allTrajectories,validTrialTypes,all_trialOutcomes,digIdx)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%
% collect final locations of 2nd and 3rd digit tip for each reach
% 
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

% min frame separation for digits 2 and 3 to consider separate reaches
minFrameSep = 20;

numTrialTypes_to_analyze = length(validTrialTypes);
all_reachEndPoints = cell(numTrialTypes_to_analyze,1);
numReaches_byPart = cell(numTrialTypes_to_analyze,1);
distFromPellet = cell(numTrialTypes_to_analyze,1);

trialTypeIdx = false(length(all_trialOutcomes),numTrialTypes_to_analyze);
num_bodyparts = length(all_reachFrameIdx{1});
for iType = 1 : numTrialTypes_to_analyze
    
    trialTypeIdx(:,iType) = extractTrialTypes(all_trialOutcomes,validTrialTypes{iType});
    numReaches_byPart{iType} = zeros(num_bodyparts,sum(trialTypeIdx(:,iType)));
    all_reachEndPoints{iType} = cell(num_bodyparts,1);
    numValidTrials = 0;
    for iTrial = 1 : size(trialTypeIdx,1)
        if trialTypeIdx(iTrial,iType)
            numValidTrials = numValidTrials + 1;
            for i_bodypart = 1 : num_bodyparts
                numReaches_byPart{iType}(i_bodypart,numValidTrials) = length(all_reachFrameIdx{iTrial}{i_bodypart});
                all_reachEndPoints{iType}{i_bodypart} = zeros(numReaches_byPart{iType}(i_bodypart,numValidTrials),3);
                for i_reach = 1 : numReaches_byPart{iType}(i_bodypart,numValidTrials)
                    curEndPt = squeeze(allTrajectories(all_reachFrameIdx{iTrial}{i_bodypart}(i_reach),:,i_bodypart,iTrial));
                    try
                    all_reachEndPoints{iType}{i_bodypart}(i_reach,:) = curEndPt;
                    catch
                        keyboard
                    end
                end
            end
        end
    end
   
end

[numReaches,reachFrames,reach_endPoints] = assignOverallReachEndPoints(all_reachFrameIdx,allTrajectories,digIdx,minFrameSep);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [numReaches,reachFrames,reach_endPoints] = assignOverallReachEndPoints(all_reachFrameIdx,allTrajectories,digIdx,minFrameSep)

numTrials = length(all_reachFrameIdx);

digitTipIdx = digIdx(2:3);    % 2nd and 3rd digit tips
numReaches = zeros(numTrials,1);
reach_endPoints = cell(numTrials,1);
reachFrames = cell(numTrials,1);
for iTrial = 1 : numTrials
    
    % find all frames in which either the digit 2 tip or digit 3 tip was
    % identified as executing a reach
    dig2_reachFrames = all_reachFrameIdx{iTrial}{digitTipIdx(1)};
    dig3_reachFrames = all_reachFrameIdx{iTrial}{digitTipIdx(2)};
    
    if isrow(dig2_reachFrames)
        dig2_reachFrames = dig2_reachFrames';
    end
    if isrow(dig3_reachFrames)
        dig3_reachFrames = dig3_reachFrames';
    end
    if isempty(dig2_reachFrames)
        trial_reachFrames = dig3_reachFrames;
    elseif isempty(dig3_reachFrames)
        trial_reachFrames = dig2_reachFrames;
    else
        try
        trial_reachFrames = [dig2_reachFrames;dig3_reachFrames];
        catch
            keyboard
        end
    end
    
    % make sure there aren't any reachFrames too close together
    reachFrames{iTrial} = removeNearbyElementsFromArray(trial_reachFrames, minFrameSep);
    numReaches(iTrial) = length(reachFrames{iTrial});
    
    reach_endPoints{iTrial} = zeros(2,3,numReaches(iTrial));
    
    for iReach = 1 : numReaches(iTrial)
        for iDig = 1 : 2
            reach_endPoints{iTrial}(iDig,:,iReach) = squeeze(allTrajectories(reachFrames{iTrial}(iReach),:,digIdx(iDig),iTrial));
        end
    end
end
end
    
    