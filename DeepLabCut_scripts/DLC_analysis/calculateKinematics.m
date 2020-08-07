function reachData = calculateKinematics(reachData,interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref,frameRate)
%
% determine reach kinematics for each reach within a trial
%
% INPUTS
%   reachData - structure with the following fields:
%         .reachEnds - vector containing frames at which each
%            reach terminates (based on digit 2)
%         .graspEnds - vector containing frames at which each
%            grasp terminates. Grasps occur at the end of each reach, but
%            could also be identified if the rat makes another grasp
%            without retracting its paw
%         .reachStarts - vector containing frames at which each
%            reach starts (based on paw dorsum)
%         .graspStarts = [];
%         .pdEndPoints = [];
%         .slotBreachFrame = [];
%         .firstDigitKinematicsFrame = [];
%         .pd_trajectory = {};
%         .pd_v = {};
%         .max_pd_v = [];
%         .dig_trajectory - 
%         .dig2_v = {};
%         .max_dig2_v = [];
%         .dig2_endPoints = [];
%         .orientation = {};
%         .aperture = {};
%         .trialScores = [];
%         .trialNumbers = [];
%         .slot_z_wrt_pellet = [];
%   interp_trajectory
%   bodyparts
%   slot_z_wrt_pellet
%   pawPref
%   frameRate
%
% OUTPUTS
%   reachData - 
%

[~,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
pd_trajectory = squeeze(interp_trajectory(:,:,pawDorsumIdx));
dig_trajectory = squeeze(interp_trajectory(:,:,digIdx));

num_reaches = length(reachData.reachEnds);

reachData.pdEndPoints = zeros(num_reaches,3);
reachData.slotBreachFrame = zeros(num_reaches,1);
reachData.firstDigitKinematicsFrame = zeros(num_reaches,1);
reachData.max_pd_v = zeros(num_reaches,1);
reachData.max_dig2_v = zeros(num_reaches,1);
reachData.segmented_pd_trajectory = {};


reachData.pd_trajectory = {};
reachData.pd_pathlength = NaN(num_reaches,1);
reachData.segmented_pd_trajectory = {};
reachData.pd_v = {};
reachData.max_pd_v = [];
reachData.dig_trajectory = {};
reachData.dig_pathlength = NaN(num_reaches,4);
reachData.segmented_dig_trajectory = {};
reachData.dig2_v = {};
reachData.max_dig2_v = [];
reachData.dig_endPoints = [];
reachData.orientation = {};
reachData.aperture = {};
reachData.trialScores = [];
reachData.trialNumbers = [];
reachData.slot_z_wrt_pellet = [];

for i_reach = 1 : num_reaches

    reach_startFrame = reachData.reachStarts(i_reach);
    grasp_startFrame = reachData.reachStarts(i_reach);
    reach_endFrame = reachData.reachEnds(i_reach);
%     grasp_endFrame = reachData.reach_to_grasp_end(i_reach);
    
    % paw dorsum trajectory
    reachData.pd_trajectory{i_reach} = pd_trajectory(reach_startFrame:reach_endFrame,:);
    reachData.pd_pathlength(i_reach) = trajectory_pathlength(reachData.pd_trajectory{i_reach});
    % velocity profile
    pd_v = diff(reachData.pd_trajectory{i_reach},1,1) * frameRate;
    pd_v = sqrt(sum(pd_v.^2,2));
    reachData.pd_v{i_reach} = pd_v;
    
    if ~isempty(pd_v)
        reachData.max_pd_v(i_reach) = max(pd_v);
    end
    
    reachData.dig_trajectory{i_reach} = dig_trajectory(reach_startFrame:reach_endFrame,:,:);
    for i_dig = 1 : 4
        reachData.dig_pathlength(i_reach,i_dig) = trajectory_pathlength(squeeze(dig_trajectory(:,:,i_dig)));
    end
    % find the last frame before the paw breaches the frame for this grasp
    % (looking at the second digit)
    last_frame_behind_slot = find(squeeze(reachData.dig_trajectory{i_reach}(:,3,2)) > slot_z_wrt_pellet,1,'last');
    if isempty(last_frame_behind_slot)
        % digit 2 must have started on the outside of the box during this
        % reach/grasp
        last_frame_behind_slot = 0;
    end
    reachData.slotBreachFrame(i_reach) = grasp_startFrame + last_frame_behind_slot;

    dig2_traj = squeeze(reachData.dig_trajectory{i_reach}(:,:,2));
    dig2_v = diff(dig2_traj,1,1) * frameRate;
    dig2_v = sqrt(sum(dig2_v.^2,2));
    reachData.dig2_v{i_reach} = dig2_v;
    if ~isempty(dig2_v)
        reachData.max_dig2_v(i_reach) = max(dig2_v);
    end
    
    % reach endpoints
    reachData.pdEndPoints(i_reach,:) = pd_trajectory(reach_endFrame,:);
    for i_dig = 1 : 4
        cur_dig_traj = squeeze(reachData.dig_trajectory{i_reach}(:,:,i_dig));
        reachData.dig_endPoints(i_reach,i_dig,:) = cur_dig_traj(end,:);  
    end
    
    % paw orientation
    [reachData.orientation{i_reach},firstValidFrame] = ...
        determinePawOrientation(interp_trajectory(reachData.slotBreachFrame(i_reach):reach_endFrame,:,:),bodyparts,pawPref);
    if isempty(firstValidFrame)    % no defined paw orientation for this reach
        reachData.firstDigitKinematicsFrame(i_reach) = []
    else
        reachData.firstDigitKinematicsFrame(i_reach) = firstValidFrame + reachData.slotBreachFrame(i_reach) - 1;
    end
    
    % aperture
    [reachData.aperture{i_reach},~] = ...
        determinePawAperture(interp_trajectory(reachData.slotBreachFrame(i_reach):reach_endFrame,:,:),bodyparts,pawPref);
    
end