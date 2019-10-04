function reachData = scoreTrial(reachData,interp_trajectory,bodyparts,didPawStartThroughSlot,pelletMissingFlag,initPellet3D,slot_z_wrt_pellet,pawPref,trialOutcome)

% WORK IN PROGRESS - MAY NEED THE OTHER VIEW IN DLC TO FIND THE PELLET...

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
% 11 - paw started out through the slot

% number of frames to look ahead after the end of the first reach to see if
% the pellet is still there
frames_to_look_past_reach = 10;
[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);

numScores = 0;
trialScores = [];
if ~isempty(trialOutcome)
    numScores = numScores + 1;
    trialScores(numScores) = trialOutcome;
end

% did the paw start on the wrong side of the slot?
if didPawStartThroughSlot
    numScores = numScores + 1;
    trialScores(numScores) = 11;
end

% was a pellet brought up by the delivery arm?
if pelletMissingFlag
    numScores = numScores + 1;
    trialScores(numScores) = 0;
end

% was there a forelimb advance at all?
dig2_z = squeeze(interp_trajectory(:,3,digIdx(2)));
didRatReach = any(dig2_z < slot_z_wrt_pellet);
 
% if the paw didn't advance through the slot (and didn't already start
% through the slot)
if ~didPawStartThroughSlot && ~didRatReach
    numScores = numScores + 1;
    trialScores(numScores) = 6;
end

% was the pellet still there after the first reach?
% to check this, find the last grasp associated with the first reach
reachEnds = find(reachData.reachEnds);
graspEnds = find(reachData.graspEnds);
num_reaches = length(reachEnds);

for i_reach = 1 : num_reaches
    
end

reachData.trialScores = unique(trialScores);