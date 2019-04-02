function [normalized_pd_trajectories,smoothed_pd_trajectories,interp_pd_trajectories, ...
    normalized_digit_trajectories, smoothed_digit_trajectories, interp_digit_trajectories] = ...
        interpolateTrajectories(allTrajectories,pawPartsList,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,pawPref,varargin)
%
% function to interpolate 3D paw and digit trajectories, accounting for
% missed frames/occlusions. Will divide each trajectory into evenly spaced
% segments.
%
% INPUTS
%   allTrajectories - numFrames x 3 x num bodyparts x numTrials array
%       containing paw/digit trajectories with respect to the pellet
%   pawPartsList - list of paw part names that are on the reaching paw
%   all_firstPawDorsumFrame - numTrials length vector containing the frame
%      in which the paw dorsum was first identified for each reach.
%   all_paw_through_slot_frame - numTrials length vector containing the
%       frame number where the paw first appeared through the slot
%   all_endPtFrame - numTrials length vector containing the frame where the
%       paw reached its maximum extension on the first reach
%   pawPref - 'left' or 'right'
%
% VARARGS
%   num_pd_trajectorypoints - number of points to divide the paw dorsum
%       trajectory into
%   num_digit_trajectorypoints - number of points to divide the digit
%       trajectories into
%   start_z_pawdorsum - farthest point from the pellet in the z-dimension
%       to start the paw trajectory. useful because some for some videos
%       the paw will be detected slightly earlier or later - this forces a
%       common starting point
%   start_z_digits - farthest point from the pellet in the z-dimension
%       to start the digit trajectories. useful because some for some
%       videos the digits will be detected slightly earlier or later - this
%       forces a common starting point
%   smoothwindow - smoothing window width for the trajectories
%   
% OUTPUTS
%   normalized_pd_trajectories - num_pd_trajectorypoints x 3 x
%      numTrials array containing trajectories that were interpolated,
%      smoothed, and divided into num_pd_trajectorypoints
%   smoothed_pd_trajectories - numTrials x 1 cell array containing smoothed
%       versions of interp_pd_trajectories
%   interp_pd_trajectories - numTrials x 1 cell array containing
%       trajectories with missing points interpolated. Only includes the
%       points from the first time the paw dorsum was detected to full
%       extension on the initial reach
%   normalized_digit_trajectories - number of digit points (usually 12 - 3
%      marks on each of 4 digits) x num_digit_trajectorypoints x 3 x
%      numTrials array containing trajectories that were interpolated,
%      smoothed, and divided into num_digit_trajectorypoints
%   smoothed_digit_trajectories - numTrials x number of digit points cell 
%       array containing smoothed versions of interp_pd_trajectories
%   interp_digit_trajectories - numTrials x number of digit points cell 
%       array containing trajectories with missing points interpolated.
%       Only includes points from once the digits are through the reaching
%       slot to full extension on the first reach

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

for iTrial = 1 : numTrials
    
    if all_firstPawDorsumFrame(iTrial) == all_paw_through_slot_frame(iTrial) || ...
          isnan(all_firstPawDorsumFrame(iTrial))  || ...
          all_firstPawDorsumFrame(iTrial) > all_endPtFrame(iTrial)
        % couldn't find the paw dorsum behind the reaching slot prior to
        % the paw breaking through the slot
        normalized_pd_trajectories(:,:,iTrial) = NaN;
        smoothed_pd_trajectories{iTrial} = NaN;
        interp_pd_trajectories{iTrial} = NaN;
        continue;
    end
    try
    curTrajectory = squeeze(allTrajectories(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,pawdorsum_idx,iTrial));
    catch
        keyboard
    end
    truncated_trajectory = find_trajectory_start_point(curTrajectory, start_z_pawdorsum);
    
    [normalized_pd_trajectories(:,:,iTrial),smoothed_pd_trajectories{iTrial},interp_pd_trajectories{iTrial}] = ...
        smoothTrajectory(truncated_trajectory, 'numtrajectorypoints', num_pd_TrajectoryPoints,'smoothwindow',smoothWindow);
    
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

    end
    
end

end