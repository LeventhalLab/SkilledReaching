function reachData = calculateKinematics(reachData,interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref,frameRate)

% INPUTS
%   reachData - structure with the following fields:
%   
%   interp_trajectory
%   bodyparts
%   slot_z_wrt_pellet
%   pawPref
%   frameRate
%
% OUTPUTS

[~,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
pd_trajectory = squeeze(interp_trajectory(:,:,pawDorsumIdx));
dig2_trajectory = squeeze(interp_trajectory(:,:,digIdx(2)));

num_reaches = length(reachData.reachEnds);

reachData.pdEndPoints = zeros(num_reaches,3);
reachData.slotBreachFrame = zeros(num_reaches,1);
reachData.firstDigitKinematicsFrame = zeros(num_reaches,1);
for i_reach = 1 : num_reaches

    reach_startFrame = reachData.reachStarts(i_reach);
    grasp_startFrame = reachData.reachStarts(i_reach);
    reach_endFrame = reachData.reachEnds(i_reach);
%     grasp_endFrame = reachData.reach_to_grasp_end(i_reach);
    
    % add in pathlength later?
    
    % paw dorsum trajectory
    reachData.pd_trajectory{i_reach} = pd_trajectory(reach_startFrame:reach_endFrame,:);
    
    % velocity profile
    pd_v = diff(reachData.pd_trajectory{i_reach},1,1) * frameRate;
    pd_v = sqrt(sum(pd_v.^2,2));
    reachData.pd_v{i_reach} = pd_v;
    
    reachData.dig2_trajectory{i_reach} = dig2_trajectory(reach_startFrame:reach_endFrame,:);
    try
    reachData.slotBreachFrame(i_reach) = grasp_startFrame + find(reachData.dig2_trajectory{i_reach}(:,3) < slot_z_wrt_pellet,1) - 1;
    catch
        keyboard
    end

    dig2_v = diff(reachData.dig2_trajectory{i_reach},1,1) * frameRate;
    dig2_v = sqrt(sum(dig2_v.^2,2));
    reachData.dig2_v{i_reach} = dig2_v;
    
    % reach endpoints
    reachData.pdEndPoints(i_reach,:) = pd_trajectory(reach_endFrame,:);
    reachData.dig2_endPoints(i_reach,:) = dig2_trajectory(reach_endFrame,:);   % should this be reach_endFrame or grasp_endFrame? probably doesn't matter much
    
    % paw orientation
%     [reachData.orientation{i_reach},firstValidFrame] = ...
%         determinePawOrientation(interp_trajectory(startFrame:grasp_endFrame,:,:),bodyparts,pawPref);
    [reachData.orientation{i_reach},firstValidFrame] = ...
        determinePawOrientation(interp_trajectory(reachData.slotBreachFrame(i_reach):reach_endFrame,:,:),bodyparts,pawPref);
    reachData.firstDigitKinematicsFrame(i_reach) = firstValidFrame + reachData.slotBreachFrame(i_reach) - 1;
    
    % aperture
%     [reachData.aperture{i_reach},~] = ...
%         determinePawAperture(interp_trajectory(startFrame:grasp_endFrame,:,:),bodyparts,pawPref);
    [reachData.aperture{i_reach},~] = ...
        determinePawAperture(interp_trajectory(reachData.slotBreachFrame(i_reach):reach_endFrame,:,:),bodyparts,pawPref);
    
    % trajectories divided up into equal segments by pathlength
    % maybe do this separately
    
    
end