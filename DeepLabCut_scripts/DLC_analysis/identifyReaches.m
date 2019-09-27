function reachData = identifyReaches(interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref,varargin)

maxReach_Grasp_separation = 10;
minGraspProminence = 2;
maxPreGraspProminence = 10;
minReachProminence = 3;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'mingraspprominence'
            minGrasprominence = varargin{iarg + 1};
        case 'minreachprominence'
            minReachProminence = varargin{iarg + 1};
        case 'maxpregraspprominence'
            maxPreGraspProminence = varargin{iarg + 1};
            
    end
end

numFrames = size(interp_trajectory,1);
[~,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

dig2_z = squeeze(interp_trajectory(:,3,digIdx(2)));
pd_z = squeeze(interp_trajectory(:,3,pawDorsumIdx));

% find local minima in the z-coordinate when the paw is outside the box

% find reaches that travel a long distance on the way out
[reachMins,~] = islocalmin(pd_z,1,...
            'flatselection','first',...
            'minprominence',minReachProminence,...
            'prominencewindow',[100,0]);%,...
%             'minseparation',30);   % when the reach extends and stops instead of retracting immediately, record the first point as reach termination
% exclude potential reaches where the paw immediately starts going forward
% again

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
% [reaches_to_keep,~] = islocalmin(pd_z,1,...
%             'minprominence',3,...
%             'prominencewindow',[0,1000],...
%             'minseparation',20);   % when the reach extends and stops instead of retracting immediately, record the first point as reach termination
% find potential reach terminations that are included in reachMins, but NOT
% in reaches_to_keep. These are presumably points where maybe the digit
% moves backwards a little but doesn't really interrupt the forward
% trajectory
% reaches_to_exclude = mins_to_exclude | (reachMins & ~reaches_to_keep);
reachMins = reachMins & ~mins_to_exclude;
        
[graspMins,~] = islocalmin(dig2_z,1,...
            'flatselection','first',...
            'minprominence',minGraspProminence,...
            'prominencewindow',[30,0],...
            'minseparation',10); 
% exclude grasps where the paw immediately starts going forward
% again
grasps_to_keep = islocalmin(dig2_z,1,...
            'minprominence',3,...
            'prominencewindow',[0,1000],...
            'minseparation',20);
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
reachData.reachEnds = reachMins & (dig2_z < slot_z_wrt_pellet);
reachData.graspEnds = graspMins & (dig2_z < slot_z_wrt_pellet);
reachEnds_frame = find(reachData.reachEnds);
graspEnds_frame = find(reachData.graspEnds);

% find the paw dorsum maxima in between each reach termination
num_reaches = sum(reachData.reachEnds);

reachData.reachStarts = false(numFrames,1);
for i_reach = 1 : num_reaches
    % look in the interval from the previous reach (or trial start) to the
    % current reach
    if i_reach == 1
        startFrame = 1;
    else
        startFrame = reachEnds_frame(i_reach-1);
    end
    lastFrame = reachEnds_frame(i_reach);
    interval_pd_z_max = max(pd_z(startFrame:lastFrame));
    reachData.reachStarts(pd_z == interval_pd_z_max) = true;
end

% find the paw dorsum maxima in between each grasp termination
num_reaches = sum(reachData.reachEnds);
num_grasps = sum(reachData.graspEnds);

reachData.reachStarts = false(numFrames,1);
for i_reach = 1 : num_reaches
    % look in the interval from the previous reach (or trial start) to the
    % current reach
    if i_reach == 1
        startFrame = 1;
    else
        startFrame = reachEnds_frame(i_reach-1);
    end
    lastFrame = reachEnds_frame(i_reach);
    interval_pd_z_max = max(pd_z(startFrame:lastFrame));
    reachData.reachStarts(pd_z == interval_pd_z_max) = true;
end
reach_and_grasp_ends = reachData.reachEnds | reachData.graspEnds;
reach_and_grasp_endFrames = find(reach_and_grasp_ends);
reachData.graspStarts = false(numFrames,1);
for i_grasp = 1 : num_grasps
    
    current_grasp_idx = find(reach_and_grasp_endFrames == graspEnds_frame(i_grasp));
    if current_grasp_idx == 1   % this shouldn't happen - there should be a reach before the first grasp, but just in case...
        previous_grasp_frame = 1;
    else
        previous_grasp_frame = reach_and_grasp_endFrames(current_grasp_idx-1);
    end
    interval_dig2_z_max = max(dig2_z(previous_grasp_frame:graspEnds_frame(i_grasp)));
    reachData.graspStarts(dig2_z == interval_dig2_z_max) = true;
end
reachData.reach_to_grasp = reach_to_grasp & (dig2_z < slot_z_wrt_pellet);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%