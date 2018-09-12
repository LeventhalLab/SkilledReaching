function trialOutcome = determineTrialOutcome(pawTrajectory,bodyparts,direct_pts,direct_bp,direct_p,ROIs,frameRate,frameTimeLimits,triggerTime)
%
% 

% find index of pellet in bodyparts list in direct view and 3D
% reconstruction. Assume the bodypart label for the pellet is "pellet"

p_cutoff = 0.95;   % assume p values greater than 0.95 indicate that we know where the pellet is
time_to_average_prior_to_reach = 0.1;

% figure out the trigger frame
triggerFrame = round((triggerTime + frameTimeLimits(1)) * frameRate);
preTriggerFrame = triggerFrame - round(time_to_average_prior_to_reach * frameRate);

pelletIdx3D = strcmpi(bodyparts,'pellet');
pelletIdx_direct = strcmpi(direct_bp,'pellet');

pelletTrajectory = squeeze(pawTrajectory(:,:,pelletIdx3D));
pelletDirectPts = squeeze(direct_pts(pelletIdx_direct,:,:));

pellet_p = squeeze(direct_p(pelletIdx_direct,:));

pelletFrames = find(pellet_p > p_cutoff);
validPreTriggerFrames = pelletFrames(pelletFrames > preTriggerFrame & pelletFrames < triggerFrame);

preReach_pellet_locations = pelletDirectPts(validPreTriggerFrames,:);

end