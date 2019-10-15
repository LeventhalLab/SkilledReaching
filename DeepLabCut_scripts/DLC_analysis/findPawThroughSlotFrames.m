function [part_through_slot_frames,firstSlotBreachFrame,firstPawPastSlotFrame,didPawStartThroughSlot] = findPawThroughSlotFrames(trajectories, slot_z)
%
% find the frames at which each paw part breached the reaching slot
%
% INPUTS
%   trajectories - numFrames x 3 x numBodyparts array. Each numFrames x 3
%       matrix contains x,y,z points for each bodypart. Only include
%       bodyparts on the reaching paw. trajectories is with the origin at 
%       the camera, not the pellet
%   
% OUTPUTS
%   paw_through_slot_frames - all frames where the paw part goes from
%       behind the slot to in front of it

num_bodyparts = size(trajectories,3);
numFrames = size(trajectories,1);
part_through_slot_frames = cell(num_bodyparts,1);
firstSlotBreachFrame = numFrames;
first_paw_past_slot_frame = NaN(num_bodyparts,1);
didPawStartThroughSlot = false;

for i_part = 1 : num_bodyparts
    
    % find all frames where the bodypart transitions from behind the
    % reaching slot (z > slot_z) to in front of the reaching slot (z <
    % slot_z)
    z_coords = squeeze(trajectories(:,3,i_part));
    z_coords_wrt_slot = z_coords - slot_z;
    
    part_through_slot_frames{i_part} = findZeroCrossings(z_coords_wrt_slot,'crossingdirection','decreasing') + 1;
    % find the first frame where this part of the paw is in front of the slot
    if ~isempty(part_through_slot_frames{i_part}) 
        first_paw_past_slot_frame(i_part) = find(z_coords_wrt_slot < 0,1,'first');
        firstSlotBreachFrame = min(firstSlotBreachFrame,min(part_through_slot_frames{i_part}));
    end
end

% find the first frame where any part of the paw is in front of the slot
firstPawPastSlotFrame = min(first_paw_past_slot_frame);
if firstPawPastSlotFrame < 10 %firstSlotBreachFrame   
    % if the paw was through the slot before the first time it passed from
    % inside to outside the box, assume paw started outside the box
    didPawStartThroughSlot = true;
    
    % was the non-reaching paw identified through the slot?
end
end