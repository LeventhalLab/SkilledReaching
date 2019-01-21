function trajectoryLengths = calculateTrajectoryLengths(normalized_pd_trajectories,normalized_digit_trajectories,slot_z)

numTrials = size(normalized_pd_trajectories,3);
numDigits = size(normalized_digit_trajectories,1);
for iTrial = 1 : numTrials
    
    pd_trajectory = squeeze(normalized_pd_trajectories(:,:,iTrial));
    pd_z = squeeze(pd_trajectory(:,3));
    
    pd_pre_slot = pd_trajectory(pd_z > slot_z,:);
    pd_post_slot = pd_trajectory(pd_z < slot_z,:);
    
    trajectoryLengths(iTrial).pd_pre_slot = calcPathLength(pd_pre_slot);
    trajectoryLengths(iTrial).pd_post_slot = calcPathLength(pd_post_slot);
    
    trajectoryLengths(iTrial).digit_traj_length = zeros(numDigits,1);
    for iDigit = 1 : numDigits
        
        curDigitTrajectory = squeeze(normalized_digit_trajectories(iDigit,:,:,iTrial));
        trajectoryLengths(iTrial).digit_traj_length(iDigit) = ...
            calcPathLength(curDigitTrajectory);
        
    end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pathLength = calcPathLength(X)
%
% calculate pathlength of a trajectory contained in X, an m x (2 or 3)
% matrix where each row in an x,y,(z) pair (triple)
%

d = diff(X);
pathLength = sqrt(sum(d.^2,2));

pathLength = sum(pathLength);

end