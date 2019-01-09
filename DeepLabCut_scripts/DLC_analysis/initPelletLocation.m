function initPellet3D = initPelletLocation(pawTrajectory,bodyparts,frameRate,triggerFrame, varargin)
%
% determine the 3D location of the pellet on the pedestal - i.e., the reach
% target
%
% INPUTS:
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   frameRate - frame rate in frames per second
%   triggerFrame - frame at which paw first breaks the slot (probably
%       determined by the function findPawThroughSlotFrame)
%
% VARARGS:
%   'timepriortoreach' - length of time to average the pellet position
%       backwards in time from the trigger event
%
% OUTPUTS:
%   initPellet3D - mean x,y,z coordinates of the pellet averaged over
%       timepriortoreach before the trigger event


% OLD INPUT:
%   frameTimeLimits - time of initial and final frames with respect to the
%       trigger event (generally, when the paw is detected by LabView).
%       Use negative times to indicate times before the trigger event
%       (e.g., the first entry should be negative if the first frame is
%       before the trigger event)

if isnan(triggerFrame)
    % this can happen if the paw is already through the slot at the start
    % of the video becuase the findPawThroughSlotFrame function looks for
    % the first time the paw breaks through the slot after the paw dorsum
    % is found behind the slot
    initPellet3D = [];
    return;
end

time_to_average_prior_to_reach = 0.1;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'timepriortoreach'
            time_to_average_prior_to_reach = varargin{iarg + 1};
    end
end

% figure out the trigger frame
% triggerFrame = round(-frameTimeLimits(1) * frameRate);

preTriggerFrame = triggerFrame - round(time_to_average_prior_to_reach * frameRate);
if preTriggerFrame < 1
    % every now and then, the trigger is off and the paw actually broke
    % through the slow very early in the video (usually after
    % "bad-reaching" is established). In that case, ignore the pellet and
    % will rely on the average pellet location from the entire session in
    % subsquent analysis steps
    initPellet3D = [];
    return;
end
pelletIdx3D = strcmpi(bodyparts,'pellet');

pelletPts = squeeze(pawTrajectory(:,:,pelletIdx3D));

% zeros in the pawTrajectory array represent points where the pellet wasn't
% visible in at least one view
initPelletPts = pelletPts(preTriggerFrame:triggerFrame,:);
validPelletPts = initPelletPts(initPelletPts(:,1)~=0,:);

if isempty(validPelletPts)
    initPellet3D = [];
else
    initPellet3D = mean(validPelletPts,1);
end

end