function [normalized_pd_trajectories,smoothed_pd_trajectories,interp_pd_trajectories, ...
    normalized_digit_trajectories, smoothed_digit_trajectories, interp_digit_trajectories] = ...
        interpolateTrajectories(allTrajectories,pawPartsList,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,pawPref,varargin)
%
% INPUTS
%   pdEstimate - 
%
% OUTPUTS
%   meanTrajectory

smoothWindow = 3;
num_pd_TrajectoryPoints = 100;
num_digit_TrajectoryPoints = 100;
start_z_pawdorsum = 46;    % where to start the normalized trajectory (z-dimension w.r.t. the pellet)
start_z_digits = 19;

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'num_pd_trajectorypoints'
            num_pd_TrajectoryPoints = varargin{iarg + 1};
        case 'num_digit_trajectorypoints'
            num_digit_TrajectoryPoints = varargin{iarg + 1};
        case 'start_z_pawdorsum'
            start_z_pawdorsum = varargin{iarg + 1};
        case 'start_z_digits'
            start_z_digits = varargin{iarg + 1};
        case 'smoothwindow'
            smoothWindow = varargin{iarg + 1};
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
smoothed_digit_trajectories = cell(numTrials,numTrackedDigitParts);
interp_digit_trajectories = cell(numTrials,numTrackedDigitParts);
normalized_digit_trajectories = zeros(numTrackedDigitParts,num_digit_TrajectoryPoints,3,numTrials);

% extract 3D points for paw dorsum trajectory
smoothed_pd_trajectories = cell(numTrials,1);
interp_pd_trajectories = cell(numTrials,1);
normalized_pd_trajectories = zeros(num_pd_TrajectoryPoints,3,numTrials);
% for iFig = 1 : 4
%     figure(iFig);
%     hold off
%     figure(iFig+4);
%     for ii = 1 : 3
%         subplot(3,1,ii)
%         hold off
%     end
% end


for iTrial = 1 : numTrials
    
    if all_firstPawDorsumFrame(iTrial) == all_paw_through_slot_frame(iTrial) || ...
          isnan(all_firstPawDorsumFrame(iTrial))  
        % couldn't find the paw dorsum behind the reaching slot prior to
        % the paw breaking through the slot
        normalized_pd_trajectories(:,:,iTrial) = NaN;
        smoothed_pd_trajectories{iTrial} = NaN;
        interp_pd_trajectories{iTrial} = NaN;
        continue;
    end
    curTrajectory = squeeze(allTrajectories(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,pawdorsum_idx,iTrial));

%     trialEstimate = squeeze(pdEstimates(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,iTrial));
    truncated_trajectory = find_trajectory_start_point(curTrajectory, start_z_pawdorsum);
    
    [normalized_pd_trajectories(:,:,iTrial),smoothed_pd_trajectories{iTrial},interp_pd_trajectories{iTrial}] = ...
        smoothTrajectory(truncated_trajectory, 'numtrajectorypoints', num_pd_TrajectoryPoints,'smoothwindow',smoothWindow);

%     figure(1)
%     plot3(smoothed_pd_trajectories(:,1,iTrial),smoothed_pd_trajectories(:,3,iTrial),smoothed_pd_trajectories(:,2,iTrial))
%     hold on
%     xlabel('x');ylabel('z');zlabel('y')
%     
%     figure(5)
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
        truncated_trajectory = find_trajectory_start_point(curTrajectory, start_z_digits);
        trajectory_test = ~isnan(truncated_trajectory(:,1));
        if sum(trajectory_test) < 2   % either zero or one valid points in truncated_trajectory
            normalized_digit_trajectories(iDigit,:,:,iTrial) = NaN;
            smoothed_digit_trajectories{iTrial,iDigit} = NaN;
            interp_digit_trajectories{iTrial,iDigit} = NaN;
        else
            [normalized_digit_trajectories(iDigit,:,:,iTrial),smoothed_digit_trajectories{iTrial,iDigit},interp_digit_trajectories{iTrial,iDigit}] = ...
                smoothTrajectory(truncated_trajectory, 'numtrajectorypoints', num_pd_TrajectoryPoints,'smoothwindow',smoothWindow);
        end
        
        % PIP next
        curTrajectory = squeeze(allTrajectories(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),:,pip_idx(iDigit),iTrial));
        truncated_trajectory = find_trajectory_start_point(curTrajectory, start_z_digits);
        trajectory_test = ~isnan(truncated_trajectory(:,1));
        if sum(trajectory_test) < 2   % either zero or one valid points in truncated_trajectory
            normalized_digit_trajectories(iDigit+4,:,:,iTrial) = NaN;
            smoothed_digit_trajectories{iTrial,iDigit+4} = NaN;
            interp_digit_trajectories{iTrial,iDigit+4} = NaN;
        else
            [normalized_digit_trajectories(iDigit+4,:,:,iTrial),smoothed_digit_trajectories{iTrial,iDigit+4},interp_digit_trajectories{iTrial,iDigit+4}] = ...
                smoothTrajectory(truncated_trajectory, 'numtrajectorypoints', num_pd_TrajectoryPoints,'smoothwindow',smoothWindow);
        end
        
        % digit tip last
        curTrajectory = squeeze(allTrajectories(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),:,digit_idx(iDigit),iTrial));
        truncated_trajectory = find_trajectory_start_point(curTrajectory, start_z_digits);
        trajectory_test = ~isnan(truncated_trajectory(:,1));
        if sum(trajectory_test) < 2   % either zero or one valid points in truncated_trajectory
            normalized_digit_trajectories(iDigit+8,:,:,iTrial) = NaN;
            smoothed_digit_trajectories{iTrial,iDigit+8} = NaN;
            interp_digit_trajectories{iTrial,iDigit+8} = NaN;
        else
            [normalized_digit_trajectories(iDigit+8,:,:,iTrial),smoothed_digit_trajectories{iTrial,iDigit+8},interp_digit_trajectories{iTrial,iDigit+8}] = ...
                smoothTrajectory(truncated_trajectory, 'numtrajectorypoints', num_pd_TrajectoryPoints,'smoothwindow',smoothWindow);
        end
        
%         figure(2)
%         plot3(smoothed_digit_trajectories(iDigit,:,1,iTrial),smoothed_digit_trajectories(iDigit,:,3,iTrial),smoothed_digit_trajectories(iDigit,:,2,iTrial));
%         hold on
%         
%         
%         figure(3)
%         plot3(smoothed_digit_trajectories(iDigit+4,:,1,iTrial),smoothed_digit_trajectories(iDigit+4,:,3,iTrial),smoothed_digit_trajectories(iDigit+4,:,2,iTrial));
%         hold on
%         
%         figure(4)
%         plot3(smoothed_digit_trajectories(iDigit+8,:,1,iTrial),smoothed_digit_trajectories(iDigit+8,:,3,iTrial),smoothed_digit_trajectories(iDigit+8,:,2,iTrial));
%         hold on
%         

    end
%     figure(2);
%     scatter3(0,0,0,25,'k','o','markerfacecolor','k')
%     xlabel('x');ylabel('z');zlabel('y')
%     hold off
%     figure(3);
%     scatter3(0,0,0,25,'k','o','markerfacecolor','k')
%     xlabel('x');ylabel('z');zlabel('y')
%     hold off
%     figure(4);
%     scatter3(0,0,0,25,'k','o','markerfacecolor','k')
%     xlabel('x');ylabel('z');zlabel('y')
%     hold off
    
end

end