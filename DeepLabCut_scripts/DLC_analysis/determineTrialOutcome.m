function trialOutcome = determineTrialOutcome(pawTrajectory,bodyparts,direct_pts,direct_bp,direct_p,ROIs,frameRate,frameTimeLimits,triggerTime)
%
% INPUTS
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   direct_pts - number of body parts x number of frames x 2
%       array
%   direct_bp - cell array containing lists of body parts descriptors that
%       matches the direct_pts array
%   direct_p - number of body parts x number of frames array
%       containing p-values for how confident DLC is that a body part was
%       correctly identified
%   ROIs - 2 x 4 array where each row defines a region of interest as:
%       [left,top,width,height]. First row is for the direct view, second
%       row is for the mirror view (which mirror depends on paw preference)
%
% OUTPUTS
%   trialOutcome reflecting Alex's scoring algorithm
%
% Alex's standard scoring algorithm
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
%
%  for now, only identifying 4's and 0's




p_cutoff = 0.95;   % assume p values greater than 0.95 indicate that we know where the pellet is
thresholdPelletMovement = 100;
trialOutcome = -1;   % return -1 if can't make a guess at the outcome

time_to_average_prior_to_reach = 0.1;

% figure out the trigger frame
triggerFrame = round((-frameTimeLimits(1)) * frameRate);
preTriggerFrame = triggerFrame - round(time_to_average_prior_to_reach * frameRate);

% find index of pellet in bodyparts list in direct view and 3D
% reconstruction. Assume the bodypart label for the pellet is "pellet"

% not using the 3D data yet
% pelletIdx3D = strcmpi(bodyparts,'pellet');
pelletIdx_direct = strcmpi(direct_bp,'pellet');

% not using pelletTrajectory in 3D yet, but could be added to try and
% identify correct trials
% pelletTrajectory = squeeze(pawTrajectory(:,:,pelletIdx3D));
pelletDirectPts = squeeze(direct_pts(pelletIdx_direct,:,:));

pellet_p = squeeze(direct_p(pelletIdx_direct,:));

pelletFrames = find(pellet_p > p_cutoff);
% if the pellet is never found with high probability, assume there was no
% pellet brought in front of the reaching slot
if isempty(pelletFrames)
    trialOutcome = 0;
    return;
end

% find the average location of the pellet in the direct view in a time when
% the delivery arm should be all the way up, but the rat can't have moved
% it yet
% identify the frames of interest in which DLC had high confidence in the
% pellet location
validPreTriggerFrames = pelletFrames(pelletFrames > preTriggerFrame & pelletFrames < triggerFrame);

% calculate the mean pellet location just prior to paw coming through the
% slot
preReach_pellet_locations = pelletDirectPts(validPreTriggerFrames,:);
mean_preReachLocation =  mean(preReach_pellet_locations);

% find pellet in all frames after the trigger frame
validPostTriggerFrames = pelletFrames(pelletFrames > triggerFrame);
postReach_pellet_locations = pelletDirectPts(validPostTriggerFrames,:);

pre_post_diff = postReach_pellet_locations - repmat(mean_preReachLocation,size(postReach_pellet_locations,1),1);
maxDist = max(sqrt(pre_post_diff(:,1).^2 + pre_post_diff(:,2).^2));
if maxDist > thresholdPelletMovement
    trialOutcome = 4;
    return;
end

% can probably detect if the pellet never moved from the pedestal - see if
% the pellet is still in the same place at the end?

end