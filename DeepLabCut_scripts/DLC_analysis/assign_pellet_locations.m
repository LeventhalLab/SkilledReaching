function assign_pellet_locations(direct_pts, mirror_pts, direct_p, mirror_p, bodyparts, F)
%
% INPUTS:
%   direct_pts: 
%   mirror_pts:
%   F: 3 x 3 x 3 array

% function to reassign pellet points to the same pellet in each frame

num_frames = size(direct_pts, 1);
num_views = 2;    % direct, mirror. Eventually use all 3 views at the same time

pellet_idx = find(contains(bodyparts, 'pellet'));
pellet_names = bodyparts{pellet_idx};
num_pellet_ids = length(pellet_idx);

direct_pellet_p = direct_p(pellet_idx,:);

final_pellet_pts = zeros(num_frames, 3, num_pellet_ids, num_views);
pellet_p = zeros(num_frames, num_pellet_ids, num_views);

for i_frame = 1 : num_frames
    
    % which views and which pellets have a high probability of being
    % correctly identified
    
    for i_view = 1 : num_views
        
        
    