function reachData = identifyReaches(reachData,interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref,varargin)
%
% INPUTS
%   reachData
%   interp_trajectory
%   bodyparts
%   slot_z_wrt_pellet
%   pawPref - 'left' or 'right'
%
% OUTPUTS
%   reachData

maxReach_Grasp_separation = 20;
minGraspSeparation = 20;
minGraspProminence = 2;
maxPreGraspProminence = 10;
minReachProminence = 10;

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'mingraspprominence'
            minGrasprominence = varargin{iarg + 1};
        case 'minreachprominence'
            minReachProminence = varargin{iarg + 1};
        case 'maxpregraspprominence'
            maxPreGraspProminence = varargin{iarg + 1};
        case 'mingraspseparation'
            minGraspSeparation = varargin{iarg + 1};
            
    end
end

numFrames = size(interp_trajectory,1);
[~,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

dig1_z = squeeze(interp_trajectory(:,3,digIdx(1)));
dig2_z = squeeze(interp_trajectory(:,3,digIdx(2)));
dig4_z = squeeze(interp_trajectory(:,3,digIdx(4)));
pd_z = squeeze(interp_trajectory(:,3,pawDorsumIdx));

% find reaches that travel a long distance on the way out
[reachMins,~] = islocalmin(pd_z,1,...
            'flatselection','first',...
            'minprominence',minReachProminence,...
            'prominencewindow',[100,0],...
            'minseparation',minGraspSeparation);

% exclude reaches where the paw immediately starts going forward
% again. 
reaches_to_keep = islocalmin(pd_z,1,...
            'minprominence',3,...
            'prominencewindow',[0,1000],...
            'minseparation',minGraspSeparation);
reachMins = reachMins & reaches_to_keep;
% find local maxima in pd_z; if one of them is too close to the next
% minimum, exclude that minimum as a potential reach
[reachMaxes,~] = islocalmax(pd_z,1);
reachMax_idx = find(reachMaxes);
reachMin_idx = find(reachMins);
mins_to_exclude = false(size(reachMins));
for i_min = 1 : length(reachMin_idx)
    % how far is the local max just before the current local min from that
    % local min in the z-direction? if it's too small, then exclude that
    % local min
	prev_max_idx = find(reachMax_idx < reachMin_idx(i_min),1,'last');
    if pd_z(reachMax_idx(prev_max_idx)) - pd_z(reachMin_idx(i_min)) < minReachProminence
        mins_to_exclude(reachMin_idx(i_min)) = true;
    end
end

reachMins = reachMins & ~mins_to_exclude;
        
[graspMins,~] = islocalmin(dig2_z,1,...
            'flatselection','first',...
            'minprominence',minGraspProminence,...
            'prominencewindow',[30,0],...
            'minseparation',minGraspSeparation); 
% exclude grasps where the paw immediately starts going forward
% again
grasps_to_keep = islocalmin(dig2_z,1,...
            'minprominence',3,...
            'prominencewindow',[0,1000],...
            'minseparation',minGraspSeparation);
graspMins = graspMins & grasps_to_keep;

% find grasps associated with reaches
num_reaches = sum(reachMins);
reachFrames = find(reachMins);
isReachRegion = false(size(reachMins));
for i_reach = 1 : num_reaches
    startFrame = max(reachFrames(i_reach)-maxReach_Grasp_separation,1);
    endFrame = min(reachFrames(i_reach)+maxReach_Grasp_separation,length(reachMins));
    isReachRegion(startFrame:endFrame) = true;
end
reach_to_grasp = isReachRegion & graspMins;
% exclude grasps where the paw moves forward a lot prior to the grasp, but
% isn't associated with a reach
grasps_to_exclude = islocalmin(dig2_z,1,...
            'flatselection','first',...
            'minprominence',maxPreGraspProminence,...
            'prominencewindow',[100,0]);
grasps_to_exclude = grasps_to_exclude & ~reach_to_grasp;
graspMins = graspMins & ~grasps_to_exclude;

% exclude reaches not associated with a grasp
isReachToGraspRegion = false(size(reach_to_grasp));
reach_to_grasp_frames = find(reach_to_grasp);
num_reach_to_grasp = sum(reach_to_grasp);
for i_reach_to_grasp = 1 : num_reach_to_grasp
    startFrame = max(reach_to_grasp_frames(i_reach_to_grasp)-maxReach_Grasp_separation,1);
    endFrame = min(reach_to_grasp_frames(i_reach_to_grasp)+maxReach_Grasp_separation,length(reachMins));
    isReachToGraspRegion(startFrame:endFrame) = true;
end
reachMins = reachMins & isReachToGraspRegion;

% make sure that both digits 1 and 4 locations are known/estimated at the
% end of each reach/grasp. They may be missing if the digits aren't all the
% way through the slot at reach termination. Essentially, make sure all
% digits are through the slot
areDigitsThroughSlot = (dig1_z < slot_z_wrt_pellet) & (dig2_z < slot_z_wrt_pellet) & (dig4_z < slot_z_wrt_pellet);
reachData.reachEnds = find(reachMins & areDigitsThroughSlot);
reachData.graspEnds = find(graspMins & areDigitsThroughSlot);
% the first grasp must occur with or after the first reach
if ~isempty(reachData.reachEnds)
    reachData.graspEnds = reachData.graspEnds(reachData.graspEnds > reachData.reachEnds(1) - maxReach_Grasp_separation);
end

% find the paw dorsum maxima in between each reach termination
reachStarts = false(numFrames,1);
num_reaches = length(reachData.reachEnds);
for i_reach = 1 : num_reaches
    % look in the interval from the previous reach (or trial start) to the
    % current reach
    if i_reach == 1
        startFrame = 1;
    else
        startFrame = reachData.reachEnds(i_reach-1);
    end
    lastFrame = reachData.reachEnds(i_reach);

    interval_pd_z_max = max(pd_z(startFrame:lastFrame));
    reachStarts(pd_z == interval_pd_z_max) = true;
end
reachData.reachStarts = find(reachStarts);
% find the paw dorsum maxima in between each grasp termination
num_grasps = length(reachData.graspEnds);

reach_and_grasp_ends = unique(sort([reachData.reachEnds;reachData.graspEnds]));
graspStarts = false(numFrames,1);
for i_grasp = 1 : num_grasps
    
    current_grasp_idx = find(reach_and_grasp_ends == reachData.graspEnds(i_grasp));
    if current_grasp_idx == 1   % this shouldn't happen - there should be a reach before the first grasp, but just in case...
        previous_grasp_frame = 1;
    else
        previous_grasp_frame = reach_and_grasp_ends(current_grasp_idx-1);
    end
    interval_dig2_z_max = max(dig2_z(previous_grasp_frame:reachData.graspEnds(i_grasp)));
    try
    graspStarts(dig2_z == interval_dig2_z_max) = true;
    catch
        keyboard
    end
end
reachData.graspStarts = find(graspStarts);
reach_to_grasp = reach_to_grasp & areDigitsThroughSlot;

% make sure each reach_to_grasp is associated with a reach. Generally, this
% shouldn't be an issue, but might occasionally happen if the digits aren't
% all the way through the slot when the reach is complete based on the paw
% dorsum trajectory, but not based on the digit trajectories (or vice
% versa)

% make sure there is one and only one "reach_to_grasp" point associated
% with each reach
num_reaches = length(reachData.reachEnds);
grasps_to_keep = false(size(reach_to_grasp));
for i_reach = 1 : num_reaches
    isReachRegion = false(size(reach_to_grasp));
    try
    reachRegionStartFrame = max(1,reachData.reachEnds(i_reach)-maxReach_Grasp_separation);
    reachRegionEndFrame = min(numFrames,reachData.reachEnds(i_reach)+maxReach_Grasp_separation);
    isReachRegion(reachRegionStartFrame:reachRegionEndFrame) = true;
    catch
        keyboard
    end
    poss_reach_to_grasp = reach_to_grasp & isReachRegion;
    if sum(poss_reach_to_grasp) > 1   % more than one candidate grasp
        % pick the grasp closest to the paw dorsum reach endpoint
        poss_reach_to_grasp_frames = find(poss_reach_to_grasp);
        time_to_grasp = abs(poss_reach_to_grasp_frames - reachData.reachEnds(i_reach));
        grasp_to_keep_idx = find(time_to_grasp == min(time_to_grasp),1);
        grasps_to_keep(poss_reach_to_grasp_frames(grasp_to_keep_idx)) = true;
    elseif ~any(poss_reach_to_grasp)   % no candidate grasps for this reach - can happen if digits 1 and 4 aren't identified
                                   % remove this reach from the list
        reachData.reachEnds(i_reach) = NaN;
        reachData.reachStarts(i_reach) = NaN;
    else   % there is exactly one reach_to_grasp associated with this reach
        grasps_to_keep = grasps_to_keep | poss_reach_to_grasp;
    end 
end
reach_to_grasp = reach_to_grasp & grasps_to_keep;
reachData.reachEnds = reachData.reachEnds(~isnan(reachData.reachEnds));
reachData.reachStarts = reachData.reachStarts(~isnan(reachData.reachStarts));


% make sure there is one and only one reach for each reach_to_grasp frame
reachBoolean = false(size(reach_to_grasp));
reachBoolean(reachData.reachEnds) = true;
reach_to_grasp_frames = find(reach_to_grasp);
reaches_to_keep = false(size(reach_to_grasp));
for i_reach_to_grasp = 1 : length(reach_to_grasp_frames)
    isReachToGraspRegion = false(size(reach_to_grasp));
    reach_to_grasp_regionStartFrame = max(1,reach_to_grasp_frames(i_reach_to_grasp)-maxReach_Grasp_separation);
    reach_to_grasp_regionEndFrame = min(numFrames,reach_to_grasp_frames(i_reach_to_grasp)+maxReach_Grasp_separation);
    isReachToGraspRegion(reach_to_grasp_regionStartFrame:reach_to_grasp_regionEndFrame) = true;
    
    poss_reach = reachBoolean & isReachToGraspRegion;
    if sum(poss_reach) > 1   % more than one candidate reach
        % pick the reach closest to the grasp endpoint; throw out the other
        poss_reach_frames = find(poss_reach);
        time_to_grasp = abs(poss_reach_frames - reach_to_grasp_frames(i_reach_to_grasp));
        reach_to_keep_idx = find(time_to_grasp == min(time_to_grasp),1);
        reaches_to_keep(poss_reach_frames(reach_to_keep_idx)) = true;  
    elseif ~any(poss_reach)   % no reach close enough to be associated with this grasp
        reach_to_grasp(reach_to_grasp_frames(i_reach_to_grasp)) = false;
    else   % there is exactly one reach associated with this reach_to_grasp
        reaches_to_keep = reaches_to_keep | poss_reach;
    end
end

reachBoolean = reachBoolean & reaches_to_keep;
preservedReachIdx = ismember(reachData.reachEnds,find(reaches_to_keep));
reachData.reachEnds = find(reachBoolean);
reachData.reachStarts = reachData.reachStarts(preservedReachIdx);

reachData.reach_to_grasp = find(reach_to_grasp & areDigitsThroughSlot);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%