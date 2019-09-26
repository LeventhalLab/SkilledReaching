function reachData = identifyReaches(interp_trajectory,bodyparts,slot_z_wrt_pellet,pawPref,varargin)


minGraspProminence = 2;
minReachProminence = 10;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'mingraspprominence'
            minGrasprominence = varargin{iarg + 1};
        case 'minreachprominence'
            minReachProminence = varargin{iarg + 1};
            
    end
end

numFrames = size(interp_trajectory,1);
[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
% use digit 2 to look for reach termini

dig2_z = squeeze(interp_trajectory(:,3,digIdx(2)));
pd_z = squeeze(interp_trajectory(:,3,pawDorsumIdx));

% find local minima in the z-coordinate when the paw is outside the box

% find reaches that travel a long distance on the way out
[reachMins,~] = islocalmin(dig2_z,1,...
            'flatselection','first',...
            'minprominence',10,...
            'prominencewindow',[30,0],...
            'minseparation',20);   % when the reach extends and stops instead of retracting immediately, record the first point as reach termination
% exclude potential reaches where the paw immediately starts going forward
% again

% WORKING HERE...SEE FIGURE 1, 1ST "GRASP", WHICH SHOULD PROBABLY BE
% CLASSIFIED AS A REACH...
[reaches_to_keep,~] = islocalmin(dig2_z,1,...
            'minprominence',5,...
            'prominencewindow',[0,10],...
            'minseparation',20);   % when the reach extends and stops instead of retracting immediately, record the first point as reach termination
reachMins = reachMins & reaches_to_keep;
        
[graspMins,~] = islocalmin(dig2_z,1,...
            'flatselection','first',...
            'minprominence',2,...
            'prominencewindow',[30,0],...
            'minseparation',10); 
            
reachData.reachEnds = reachMins & (dig2_z < slot_z_wrt_pellet);
reachData.graspEnds = graspMins & (dig2_z < slot_z_wrt_pellet) & ~reachMins;
reachEnds_frame = find(reachData.reachEnds);
graspEnds_frame = find(reachData.graspEnds);

% find the paw dorsum maxima in between each reach termination
num_reaches = sum(reachData.reachEnds);
num_grasps = sum(reachData.graspEnds);

reachData.reachStarts = false(numFrames,1);
for i_reach = 1 : num_reaches
    % WORKING ON FINDING REACH ONSETS...
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
    % WORKING ON FINDING REACH ONSETS...
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
    interval_pd_z_max = max(pd_z(previous_grasp_frame:graspEnds_frame(i_grasp)));
    reachData.graspStarts(pd_z == interval_pd_z_max) = true;
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%