function [interp_trajectories] = extractSingleTrialKinematics(trajectory,bodyparts,slot_z,initPellet3D,pawPref,varargin)

windowLength = 10;
smoothMethod = 'gaussian';

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'windowlength'
            windowLength = varargin{iarg+1};
        case 'smoothmethod'
            smoothMethod = varargin{iarg+1};
    end
end

frameRange_pd = zeros(numValidTrials,2);
frameRange_dig = zeros(numValidTrials,2,4);
numFrames = size(trajectories,1);
num_bodyparts = size(trajectories,3);
interp_trajectories = NaN(numFrames,3,num_bodyparts,numValidTrials);

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

fullTrajectory = squeeze(trajectories(:,:,pawDorsumIdx));
[frameRange_pd(iTrial,:),interp_trajectory] = ...
    smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);

interp_trajectories(frameRange_pd(iTrial,1):frameRange_pd(iTrial,2),:,pawDorsumIdx,iTrial) = interp_trajectory;
initPellet_z = all_initPellet3D(validTrials(iTrial),3);
slot_z_wrt_pellet = slot_z - initPellet_z;   

% calculate digit tip trajectories
for iDig = 1 : 4
    fullTrajectory = squeeze(trajectories(:,:,digIdx(iDig),validTrials(iTrial)));
    [frameRange_dig(iTrial,:,iDig),interp_trajectory] = ...
        smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);
    interp_trajectories(frameRange_dig(iTrial,1,iDig):frameRange_dig(iTrial,2,iDig),:,digIdx(iDig),iTrial) = interp_trajectory;
end