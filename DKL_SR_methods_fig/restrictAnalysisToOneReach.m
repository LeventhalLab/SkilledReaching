function [single_reach_points, new_alignmentFrame] = restrictAnalysisToOneReach(aligned_traj, triggerFrame, minTrajHeight, varargin)
%
% function to find just one reach (in cases there was more than one reach
% for a video) and only take points from when the paw got high enough to
% approach the slot

interp_nans = true;
for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'interp_nans',
            interp_nans = varargin{iarg + 1};
    end
end
numTrajectories = size(aligned_traj,3);
frameLimits = zeros(numTrajectories,2);   % each row contains the first and last frame for the reach trajectory

interpTraj = nan(size(aligned_traj));
for iTraj = 1 : numTrajectories
    
    y_values = squeeze(aligned_traj(:,2,iTraj));
    % find the first frame for analysis
    
    tempStartFrame = find(y_values(1:triggerFrame) > minTrajHeight,1,'last') + 1;
    if isempty(tempStartFrame)    % y values never got above minTrajHeight before the reach, so
                                  % find the first y value > 0
        tempStartFrame = find(y_values(1:triggerFrame) > 0,1,'first');
    end
    if isempty(tempStartFrame)    % if still haven't found a start frame, take the first
                                  % y-value that isn't a NaN before the
                                  % trigger frame
        tempStartFrame = find(isnan(y_values(triggerFrame:-1:1)),1,'first') + 1;
    end
    tempEndFrame = find(y_values(triggerFrame:end) > minTrajHeight,1,'first') + triggerFrame - 2;
    if isempty(tempEndFrame)    % y values never get above minTrajHeight after the reach, so
                                % find the last y value that isn't a NaN
        tempEndFrame = find(y_values(triggerFrame:end) > 0,1,'last') + triggerFrame - 1;
    end
    frameLimits(iTraj,1) = tempStartFrame;
    frameLimits(iTraj,2) = tempEndFrame;
    
    if interp_nans
        for ii = 1 : 3
            interpTraj(:,ii,iTraj) = ...
                naninterp(aligned_traj(:,ii,iTraj));
        end
    end
end

% frameDiffToAlignedFrame = zeros(numTrajectories,2);
% frameDiffToAlignedFrame(:,1) = triggerFrame - frameLimits(:,1);  % number of frames before trigger frame to include for each reach
% frameDiffToAlignedFrame(:,2) = frameLimits(:,2) - triggerFrame;  % number of frames after trigger frame to include for each reach

firstStartFrame = min(frameLimits(:,1));
lastEndFrame = max(frameLimits(:,2));

newTrajLength = lastEndFrame - firstStartFrame + 1;

single_reach_points = NaN(newTrajLength,3,numTrajectories);
new_alignmentFrame = triggerFrame - firstStartFrame + 1;

for iTraj = 1 : numTrajectories
    
    newStartFrame = new_alignmentFrame - (triggerFrame - frameLimits(iTraj,1));
    newEndFrame = new_alignmentFrame + (frameLimits(iTraj,2) - triggerFrame);
    
    if interp_nans
        single_reach_points(newStartFrame : newEndFrame, :, iTraj) = ...
            interpTraj(frameLimits(iTraj,1) : frameLimits(iTraj,2), :, iTraj);
    else
        single_reach_points(newStartFrame : newEndFrame, :, iTraj) = ...
            aligned_traj(frameLimits(iTraj,1) : frameLimits(iTraj,2), :, iTraj);
    end
    
end

end