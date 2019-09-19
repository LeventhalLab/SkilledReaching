function [reachTrajectories, validTrials, reachEndFrames] = collectReachTrajectories(trialOutcomes,trajectories,all_reachFrameIdx,bodyparts,validOutcomes,pawPref,slot_z,all_initPellet3D)
%
% INPUTS
%
% OUTPUTS
%   reachTrajectories

windowLength = 10;
smoothMethod = 'gaussian';

numTrials = length(trialOutcomes);
% extract the indices of valid trials for which to calculate reach
% trajectories
validTrials = ismember(trialOutcomes,validOutcomes);
validTrials = find(validTrials);
numValidTrials = length(validTrials);

frameRange_pd = zeros(numValidTrials,2);
frameRange_dig = zeros(numValidTrials,2,4);
numFrames = size(trajectories,1);
num_bodyparts = size(trajectories,3);
interp_trajectories = NaN(numFrames,3,num_bodyparts,numValidTrials);
dorsum_through_slot_frame = zeros(numValidTrials,1);
first_paw_dorsum_frame = zeros(numValidTrials,1);

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

for iTrial = 1 : numValidTrials
    
    % WORKING HERE - REPLACE WITH CALL TO EXTRACTSINGLETRIALKINEMATICS
    reachEndFrames{iTrial} = determineTrialReachEndFrames(all_reachFrameIdx{validTrials(iTrial)},bodyparts,pawPref);
    fullTrajectory = squeeze(trajectories(:,:,pawDorsumIdx,validTrials(iTrial)));
    [frameRange_pd(iTrial,:),interp_trajectory] = ...
        smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);
    
    interp_trajectories(frameRange_pd(iTrial,1):frameRange_pd(iTrial,2),:,pawDorsumIdx,iTrial) = interp_trajectory;
    initPellet_z = all_initPellet3D(validTrials(iTrial),3);
    slot_z_wrt_pellet = slot_z - initPellet_z;    

    interp_z = squeeze(interp_trajectories(:,3,pawDorsumIdx,iTrial));
    dorsum_through_slot_frame(iTrial) = find(interp_z < slot_z_wrt_pellet,1,'first');
    paw_dorsum_max = max(interp_z(1:dorsum_through_slot_frame(iTrial)-1));
    first_paw_dorsum_frame(iTrial) = find((interp_z(1:dorsum_through_slot_frame(iTrial)-1) == paw_dorsum_max),1,'last');
    
    % calculate digit tip trajectories
    for iDig = 1 : 4
        
        fullTrajectory = squeeze(trajectories(:,:,digIdx(iDig),validTrials(iTrial)));
        [frameRange_dig(iTrial,:,iDig),interp_trajectory] = ...
            smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);
        interp_trajectories(frameRange_dig(iTrial,1,iDig):frameRange_dig(iTrial,2,iDig),:,digIdx(iDig),iTrial) = interp_trajectory;
    end
end

reachTrajectories = [];



end