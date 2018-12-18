function [smoothed_pd_trajectories,smoothed_digit_trajectories] = interpolateTrajectories(allTrajectories,pawPartsList,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,pawPref,varargin)
%
% INPUTS
%   pdEstimate - 
%
% OUTPUTS
%   meanTrajectory

num_pd_TrajectoryPoints = 100;
num_digit_TrajectoryPoints = 100;
start_z_pawdorsum = 45;    % where to start the normalized trajectory (z-dimension w.r.t. the pellet)

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'num_pd_trajectorypoints'
            num_pd_TrajectoryPoints = varargin{iarg + 1};
        case 'num_digit_trajectorypoints'
            num_digit_TrajectoryPoints = varargin{iarg + 1};
        case 'start_z_pawdorsum'
            start_z_pawdorsum = varargin{iarg + 1};
    end
end

% general strategy:

% identify the start and end point for each paw part.
% For the paw dorsum, find the first value where the mirror view was
% clearly identified, and track it up to the slot. 

if iscategorical(pawPref)
    pawPref = char(pawPref);
end
numTrials = size(allTrajectories,4);
[mcp_idx,pip_idx,digit_idx,pawdorsum_idx,~,~,~] = ...
    group_DLC_bodyparts(pawPartsList,pawPref);

numTrackedDigitParts = sum([length(mcp_idx),length(pip_idx),length(digit_idx)]);
smoothed_digit_trajectories = zeros(numTrackedDigitParts,num_digit_TrajectoryPoints,3,numTrials);

% extract 3D points for paw dorsum trajectory
smoothed_pd_trajectories = zeros(num_pd_TrajectoryPoints,3,numTrials);
figure(1);
hold off
figure(2)
for ii = 1 : 3
    subplot(3,1,ii)
    hold off
end
for iTrial = 1 : numTrials
    
    curTrajectory = squeeze(allTrajectories(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,pawdorsum_idx,iTrial));
%     trialEstimate = squeeze(pdEstimates(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,iTrial));
    truncated_trajectory = find_trajectory_start_point(curTrajectory, start_z_pawdorsum);
    
    %   PROBLEM IS THAT THE FIRSTPAWDORSUMFRAME WAS INCORRECTLY IDENTIFIED
    %   FOR VID #9 (NAMED 010)
    smoothed_pd_trajectories(:,:,iTrial) = smoothTrajectory(truncated_trajectory, num_pd_TrajectoryPoints);

    % smooth the trajectory
%     figure(1)
%     plot3(smoothed_pd_trajectories(:,1,iTrial),smoothed_pd_trajectories(:,3,iTrial),smoothed_pd_trajectories(:,2,iTrial))
%     hold on
%     xlabel('x');ylabel('z');zlabel('y')
%     
%     figure(2)
%     for ii = 1 : 3
%         subplot(3,1,ii)
%         plot(smoothed_pd_trajectories(:,ii,iTrial))
%         hold on
%     end
    
    % for the digits, identify the first point after it breaks the slot
    % (recorded in firstSlotBreak) until max extension for the reach
    
    for iDigit = 1 : 4
        
        % MCP first
        curTrajectory = squeeze(allTrajectories(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),:,mcp_idx(iDigit),iTrial));
        smoothed_digit_trajectories(iDigit,:,:,iTrial) = smoothTrajectory(curTrajectory, num_digit_TrajectoryPoints);
        
        % PIP next
        curTrajectory = squeeze(allTrajectories(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),:,pip_idx(iDigit),iTrial));
        smoothed_digit_trajectories(iDigit+4,:,:,iTrial) = smoothTrajectory(curTrajectory, num_digit_TrajectoryPoints);
        
        % digit tip last
        curTrajectory = squeeze(allTrajectories(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),:,digit_idx(iDigit),iTrial));
        smoothed_digit_trajectories(iDigit+8,:,:,iTrial) = smoothTrajectory(curTrajectory, num_digit_TrajectoryPoints);
        
    end
    
end



end