function firstPawDorsumFrame = findFirstPawDorsumFrame(trajectory,mirror_p,mirror_bp,paw_through_slot_frame,pawPref,varargin)

pThresh = 0.95;

if nargin == 6
    pThresh = varargin{1};
end

[~,~,~,mirror_pawdorsum_idx,~,~,~] = group_DLC_bodyparts(mirror_bp,pawPref);

pawDorsum_p = mirror_p(mirror_pawdorsum_idx,1:paw_through_slot_frame)';

% find the first frame before the paw_through_slot_frame where mirror_p >
% pThresh and a valid trajectory point was found (so there must have also
% been at least some points found in the direct view)
valid3d = ~isnan(trajectory(1:paw_through_slot_frame,1,mirror_pawdorsum_idx));
 
firstPawDorsumFrame = find(pawDorsum_p > pThresh & valid3d,1);

if isempty(firstPawDorsumFrame)
    firstPawDorsumFrame = paw_through_slot_frame;
end