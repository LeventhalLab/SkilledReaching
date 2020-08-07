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

% maxReach_Grasp_separation = 25;
minGraspSeparation = 25;
minGraspProminence = 2;
% maxPreGraspProminence = 10;
minReachProminence = 10;
max_digit_paw_sep = 40;   % max distance allowed between tip of second digit and paw

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
%         case 'mingraspprominence'
%             minGrasprominence = varargin{iarg + 1};
        case 'minreachprominence'
            minReachProminence = varargin{iarg + 1};
%         case 'maxpregraspprominence'
%             maxPreGraspProminence = varargin{iarg + 1};
        case 'mingraspseparation'
            minGraspSeparation = varargin{iarg + 1};
            
    end
end

numFrames = size(interp_trajectory,1);
[~,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

dig1_traj = squeeze(interp_trajectory(:,:,digIdx(1)));
dig2_traj = squeeze(interp_trajectory(:,:,digIdx(2)));
dig4_traj = squeeze(interp_trajectory(:,:,digIdx(4)));
pd_traj = squeeze(interp_trajectory(:,:,pawDorsumIdx));

dig1_z = dig1_traj(:,3);
dig2_z = dig2_traj(:,3);
dig4_z = dig4_traj(:,3);
pd_z = pd_traj(:,3);

% find reaches that travel a long distance on the way out.
% currently, based on finding maximum extent of digit 2
[reachMins,~] = islocalmin(dig2_z,1,...
            'flatselection','first',...
            'minprominence',minReachProminence,...
            'prominencewindow',[150,0]);%,...
%             'minseparation',minGraspSeparation);

% exclude reaches where the paw immediately starts going forward
% again. Again, based on digit 2
reaches_to_keep = islocalmin(dig2_z,1,...
            'minprominence',1,...
            'prominencewindow',[0,1000],...
            'minseparation',minGraspSeparation);
reachMins = reachMins & reaches_to_keep;
        
[graspMins,~] = islocalmin(dig2_z,1,...
            'flatselection','first',...
            'minprominence',minGraspProminence,...
            'prominencewindow',[150,0],...
            'minseparation',minGraspSeparation); 
% exclude grasps where the paw immediately starts going forward
% again
grasps_to_keep = islocalmin(dig2_z,1,...
            'minprominence',1,...
            'prominencewindow',[0,1000],...
            'minseparation',minGraspSeparation);
graspMins = graspMins & grasps_to_keep;

% exclude reaches  and grasps where the paw dorsum is too far from digit 2 tip - this
% sometimes happens if the rat reaches with the wrong paw and it is
% misidentified as the "preferred" paw
% find the digit tip farthest from the box
dig1_pd_diff = dig1_traj - pd_traj;
dig2_pd_diff = dig2_traj - pd_traj;
dig4_pd_diff = dig4_traj - pd_traj;
dig1_pd_dist = sqrt(sum(dig1_pd_diff.^2,2));
dig2_pd_dist = sqrt(sum(dig2_pd_diff.^2,2));
dig4_pd_dist = sqrt(sum(dig4_pd_diff.^2,2));

dig_pd_dist = min([dig1_pd_dist,dig2_pd_dist,dig4_pd_dist],[],2);
excludeFrames = dig_pd_dist > max_digit_paw_sep;
reachMins = reachMins & ~excludeFrames;
graspMins = graspMins & ~excludeFrames;

% make sure that both digits 1 and 4 locations are known/estimated at the
% end of each grasp. They may be missing if the digits aren't all the
% way through the slot at reach termination. Essentially, make sure all
% digits are through the slot
areDigitsThroughSlot = (dig1_z < slot_z_wrt_pellet) | (dig2_z < slot_z_wrt_pellet) | (dig4_z < slot_z_wrt_pellet);

% comment the line immediately below back in to restore to the version as
% of 20200628 -DL
% areDigitsThroughSlot = (dig1_z < slot_z_wrt_pellet) & (dig2_z < slot_z_wrt_pellet) & (dig4_z < slot_z_wrt_pellet);
% areDigitsThroughSlot = (dig2_z < slot_z_wrt_pellet) & (dig4_z < slot_z_wrt_pellet);
reachData.reachEnds = find(reachMins & areDigitsThroughSlot);
reachData.graspEnds = find(graspMins & areDigitsThroughSlot);

% find the paw dorsum maxima in between each reach termination
reachStarts = false(numFrames,1);
num_reaches = length(reachData.reachEnds);
removeReachEndFlag = false(num_reaches,1);
for i_reach = 1 : num_reaches
    % look in the interval from the previous reach (or trial start) to the
    % current reach
    if i_reach == 1
        startFrame = 1;
    else
        startFrame = reachData.reachEnds(i_reach-1);
    end
    lastFrame = reachData.reachEnds(i_reach);

    interval_dig2_z_max = max(dig2_z(startFrame:lastFrame));
    interval_pd_z_max = max(pd_z(startFrame:lastFrame));
    if isnan(interval_pd_z_max)   % paw dorsum wasn't found before this reach end point; can happen if rat reaches with wrong paw first
        % invalidate this reach
        removeReachEndFlag(i_reach) = true;
    end
%     reachStarts(dig2_z == interval_dig2_z_max) = true;
    reachStarts(pd_z == interval_pd_z_max) = true;

end
reachData.reachEnds = reachData.reachEnds(~removeReachEndFlag);    
reachData.reachStarts = find(reachStarts);
% find the digit 2 maxima in between each grasp termination
num_grasps = length(reachData.graspEnds);

% reach_and_grasp_ends = unique(sort([reachData.reachEnds;reachData.graspEnds]));
graspStarts = false(numFrames,1);
for i_grasp = 1 : num_grasps
    
%     current_grasp_idx = reachData.graspEnds(i_grasp);
%     current_grasp_idx = find(reach_and_grasp_ends == reachData.graspEnds(i_grasp));
    if i_grasp == 1   % this shouldn't happen - there should be a reach before the first grasp, but just in case...
        previous_grasp_frame = 1;
    else
        previous_grasp_frame = reachData.graspEnds(i_grasp-1);
    end
    interval_dig2_z_max = max(dig2_z(previous_grasp_frame:reachData.graspEnds(i_grasp)));
    graspStarts(dig2_z == interval_dig2_z_max) = true;
end
reachData.graspStarts = find(graspStarts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%