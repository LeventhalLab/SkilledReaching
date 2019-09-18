function [reachTrajectories, reachEndFrames] = collectReachTrajectories(trialOutcomes,trajectories,all_reachFrameIdx,i_bodypart,bodyparts,validOutcomes,pawPref)
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

for iTrial = 1 : length(validTrials)
    
    reachEndFrames{iTrial} = determineTrialReachEndFrames(all_reachFrameIdx{validTrials(iTrial)},bodyparts,pawPref);
    fullTrajectory = squeeze(trajectories(:,:,i_bodypart,validTrials(iTrial)));
    [frameRange,interp_trajectory] = smoothSingleTrajectory(fullTrajectory,'windowlength',windowLength,'smoothmethod',smoothMethod);

end

reachTrajectories = [];



end