function [all_reachEndPoints,numReaches] = collectall_reachEndPoints(all_reachFrameIdx,allTrajectories,validTrialTypes,all_trialOutcomes)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

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

numTrialTypes_to_analyze = length(validTrialTypes);
all_reachEndPoints = cell(numTrialTypes_to_analyze,1);
numReaches = cell(numTrialTypes_to_analyze,1);
distFromPellet = cell(numTrialTypes_to_analyze,1);

trialTypeIdx = false(length(all_trialOutcomes),numTrialTypes_to_analyze);
num_bodyparts = length(all_reachFrameIdx{1});
for iType = 1 : numTrialTypes_to_analyze
    
    trialTypeIdx(:,iType) = extractTrialTypes(all_trialOutcomes,validTrialTypes{iType});
    numReaches{iType} = zeros(num_bodyparts,sum(trialTypeIdx(:,iType)));
    all_reachEndPoints{iType} = cell(num_bodyparts,1);
    numValidTrials = 0;
    for iTrial = 1 : size(trialTypeIdx,1)
        if trialTypeIdx(iTrial,iType)
            numValidTrials = numValidTrials + 1;
            for i_bodypart = 1 : num_bodyparts
                numReaches{iType}(i_bodypart,numValidTrials) = length(all_reachFrameIdx{iTrial}{i_bodypart});
                all_reachEndPoints{iType}{i_bodypart} = zeros(numReaches{iType}(i_bodypart,numValidTrials),3);
                for i_reach = 1 : numReaches{iType}(i_bodypart,numValidTrials)
                    curEndPt = squeeze(allTrajectories(all_reachFrameIdx{iTrial}{i_bodypart}(i_reach),:,i_bodypart,iTrial));
                    all_reachEndPoints{iType}{i_bodypart}(i_reach,:) = curEndPt;
                end
            end
        end
    end
    
%     % create an array num_bodyparts x 3 x number of trials of this type
%     distFromPellet{iType} = zeros(num_bodyparts,sum(trialTypeIdx(:,iType)));
%     for i_bodypart = 1 : num_bodyparts
%         cur_endPts = squeeze(reachEndPoints{iType}(i_bodypart,:,:));
%         distFromPellet{iType}(i_bodypart,:) = sqrt(sum(cur_endPts.^2));
% %         distFromPellet{iType}(i_bodypart,:,:) = 
%     end
%     
end

end
