function trialOutcome = determineTrialOutcome(pawTrajectory,bodyparts,direct_pts,direct_bp,direct_p,ROIs)
%
% 

% find index of pellet in bodyparts list in direct view and 3D
% reconstruction. Assume the bodypart label for the pellet is "pellet"

p_cutoff = 0.95;   % assume p values greater than 0.95 indicate that we know where the pellet is

pelletIdx3D = find(strcmpi(bodyparts,'pellet'));
pelletIdx_direct = find(strcmpi(direct_bp,'pellet'));

pelletTrajectory = squeeze(pawTrajectory(:,:,pelletIdx3D));
pelletDirectPts = squeeze(direct_pts(pelletIdx_direct,:,:));

