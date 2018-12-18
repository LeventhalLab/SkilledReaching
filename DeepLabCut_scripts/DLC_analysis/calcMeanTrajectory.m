function [smoothed_pd_trajectories,smoothed_digit_trajectories] = calcMeanTrajectory(allTrajectories,pawPartsList,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,pawPref,varargin)
%
% INPUTS
%   pdEstimate - 
%
% OUTPUTS
%   meanTrajectory

num_pd_TrajectoryPoints = 100;
num_digit_TrajectoryPoints = 100;
start_z = 45;    % where to start the normalized trajectory (z-dimension w.r.t. the pellet)

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'num_pd_trajectorypoints'
            num_pd_TrajectoryPoints = varargin{iarg + 1};
        case 'num_digit_trajectorypoints'
            num_digit_TrajectoryPoints = varargin{iarg + 1};
        case 'start_z'
            start_z = varargin{iarg + 1};
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

% find the smallest z-coordinate at which the paw dorsum is first detected
% init_z = zeros(numTrials,1);
% for iTrial = 1 : numTrials
%     init_z(iTrial) = max(allTrajectories(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),3,pawdorsum_idx,iTrial));
% end
% min_init_z = min(init_z);

for iTrial = 1 : numTrials
    
    curTrajectory = squeeze(allTrajectories(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,pawdorsum_idx,iTrial));
%     trialEstimate = squeeze(pdEstimates(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,iTrial));

    truncated_trajectory = find_trajectory_start_point(curTrajectory, start_z);
    smoothed_pd_trajectories(:,:,iTrial) = smoothTrajectory(truncated_trajectory, num_pd_TrajectoryPoints);

    figure(1)
    plot3(smoothed_pd_trajectories(:,1,iTrial),smoothed_pd_trajectories(:,3,iTrial),smoothed_pd_trajectories(:,2,iTrial))
    hold on
    xlabel('x');ylabel('z');zlabel('y')
    
    figure(2)
    for ii = 1 : 3
        subplot(3,1,ii)
        plot(smoothed_pd_trajectories(:,ii,iTrial))
        hold on
    end
    
    % for the digits, identify the first point after it breaks the slot
    % (recorded in firstSlotBreak) until max extension for the reach
    
    % do the MCPs first
    
end

end