function [initPellet3D,pelletMissingFlag] = initPelletLocation(pawTrajectory,bodyparts,frameRate,firstSlotBreachFrame,pellet_reproj_error,pellet_direct_p,varargin)
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
%   firstSlotBreachFrame - frame at which paw first breaks the slot (probably
%       determined by the function findPawThroughSlotFrame)
%   pellet_reproj_error - numFrames x 2 array where the first row is the
%       reprojection error of the pellet in the direct view, second row is
%       the reprojection error in the mirror view
%
% VARARGS:
%   'timepriortoreach' - length of time to average the pellet position
%       backwards in time from the trigger event
%
% OUTPUTS:
%   initPellet3D - mean x,y,z coordinates of the pellet averaged over
%       timepriortoreach before the trigger event

maxReprojError = 20;    % if the pellet was misidentified in one of the views, the reprojection error will likely be large
min_pellet_direct_p = 0.90;

pelletMissingFlag = false;
    
if isnan(firstSlotBreachFrame)
    % this can happen if the paw is already through the slot at the start
    % of the video becuase the findPawThroughSlotFrame function looks for
    % the first time the paw breaks through the slot after the paw dorsum
    % is found behind the slot
    initPellet3D = [];
    return;
end

time_to_average_prior_to_reach = 0.1;

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'timepriortoreach'
            time_to_average_prior_to_reach = varargin{iarg + 1};
        case 'maxreprojerror'
            maxReprojError = varargin{iarg + 1};
    end
end

preTriggerFrame = firstSlotBreachFrame - round(time_to_average_prior_to_reach * frameRate);
if preTriggerFrame < 1
    % every now and then, the trigger is off and the paw actually broke
    % through the slot very early in the video (usually after
    % "bad-reaching" is established). In that case, ignore the pellet and
    % will rely on the average pellet location from the entire session in
    % subsquent analysis steps
    initPellet3D = [];
    return;
end
pelletIdx3D = strcmpi(bodyparts,'pellet');
pelletPts = squeeze(pawTrajectory(:,:,pelletIdx3D));

invalidPoints = (pellet_reproj_error(:,1) > maxReprojError)' | (pellet_reproj_error(:,2) > maxReprojError)';
pelletPts(invalidPoints,:) = NaN;
% zeros in the pawTrajectory array represent points where the pellet wasn't
% visible in at least one view
initPelletPts = pelletPts(preTriggerFrame:firstSlotBreachFrame,:);
validPelletPts = initPelletPts(~isnan(initPelletPts(:,1)),:);

if isempty(validPelletPts)
    initPellet3D = [];
    try
        if length(pellet_direct_p) < preTriggerFrame
            % rare event where the video was truncated before the paw got
            % through the slot. Just ignore this trial
            pelletMissingFlag = true;
        elseif all(pellet_direct_p(preTriggerFrame:firstSlotBreachFrame) < min_pellet_direct_p)
            pelletMissingFlag = true;
        end
    catch
        keyboard
    end
else
    initPellet3D = mean(validPelletPts,1);
end

end