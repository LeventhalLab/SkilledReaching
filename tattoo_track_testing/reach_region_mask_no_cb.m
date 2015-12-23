function [mirrorMask,centerMask] = reach_region_mask_no_cb(BGimg_ud, sr_ratInfo)
%
% usage:
%
% function to create a mirrorMask from the checkerboard and box front panel in
% the mirror views. The paw can't appear behind the checkerboard, at least
% not in front of the front panel
%
% INPUTS:
%   boxMarkers - 
%
% OUTPUTS:
%

switch lower(sr_ratInfo.ID)
    case 'r0027',
        leftMirrorTopEdge = 381;
        rightMirrorTopEdge = 386;

        leftMirrorBotEdge = 616;
        rightMirrorBotEdge = 621;

        leftMirrorRightEdge = 1;
        leftMirrorRightEdge = 162;

        rightMirrorLeftEdge = 1833;
        rightMirrorRightEdge = size(BGimg_ud,2);
        
        centerLeftEdge = 920;
        centerRightEdge = 1100;
        centerTopEdge = 1;
        centerBotEdge = size(BGimg_ud,1);
        
    otherwise,
        
        leftMirrorTopEdge = 381;
        leftMirrorTopEdge = 386;

        leftMirrorBotEdge = 616;
        leftMirrorBotEdge = 621;

        leftMirrorRightEdge = 1;
        leftMirrorRightEdge = 162;

        rightMirrorLeftEdge = 1833;
        rightMirrorRightEdge = size(BGimg_ud,2);
        
        centerLeftEdge = 920;
        centerRightEdge = 1100;
        centerTopEdge = 1;
        centerBotEdge = size(BGimg_ud,1);
        
end

mirrorMask = false(size(BGimg_ud));
centerMask = false(size(BGimg_ud));

mirrorMask(leftMirrorTopEdge:leftMirrorBotEdge,...
           leftMirrorLeftEdge:leftMirrorRightEdge) = true;
mirrorMask(rightMirrorTopEdge:rightMirrorBotEdge,...
           rightMirrorLeftEdge:rightMirrorRightEdge) = true;

       % WORKING HERE...
centerMask(centerLeftEdge,
% 
% % find the bottom of the checkerboard pattern - nothing above that can be
% % the paw, at least not in front of the refelction of the front panel
% [~,idx] = sort(boxMarkers.cbLocations.left_mirror_cb(:,2));
% num_cbMarkers = length(idx);
% 
% left_cb_top = boxMarkers.cbLocations.left_mirror_cb(idx(1),:);
% left_cb_bot = boxMarkers.cbLocations.left_mirror_cb(idx(num_cbMarkers-3:end),:);
% % find the leftmost and rightmost points
% [~,idx] = sort(left_cb_bot(:,1));
% left_cb_bot = left_cb_bot(idx,:);
% cb_mirrorMask = segregateImage(left_cb_bot([1,4],:), left_cb_top, imSize);
% 
% [~,idx] = sort(boxMarkers.frontPanel_x(1,:));
% fp_y = boxMarkers.frontPanel_y(1,idx(1:3));
% fp_x = boxMarkers.frontPanel_x(1,idx(1:3)); 
% [fp_y,ia,~] = unique(fp_y);
% fp_x = fp_x(ia);
% 
% fp_pts = [fp_x',fp_y'];
% fp_mirrorMask = segregateImage(fp_pts,left_cb_bot(1,:),imSize);
% 
% % mirrorMask out anything below the red beads
% left_mirror_red_beads = boxMarkers.beadLocations.left_mirror_red_beads;
% [~,idx] = sort(left_mirror_red_beads(:,2));
% rbead1 = left_mirror_red_beads(idx(2),:);
% 
% center_red_beads = boxMarkers.beadLocations.center_red_beads;
% [~,idx] = sort(center_red_beads(:,2));
% rbead2 = center_red_beads(idx(2),:);
% 
% rb_mirrorMask = segregateImage([rbead1;rbead2], left_cb_top, imSize);
% mirrorMask = fp_mirrorMask & ~cb_mirrorMask & rb_mirrorMask;
% 
% % now do the right mirror
% [~,idx] = sort(boxMarkers.cbLocations.right_mirror_cb(:,2));
% num_cbMarkers = length(idx);
% 
% right_cb_top = boxMarkers.cbLocations.right_mirror_cb(idx(1),:);
% right_cb_bot = boxMarkers.cbLocations.right_mirror_cb(idx(num_cbMarkers-3:end),:);
% % find the lefttmost and rightmost points
% [~,idx] = sort(right_cb_bot(:,1));
% right_cb_bot = right_cb_bot(idx,:);
% cb_mirrorMask = segregateImage(right_cb_bot([1,4],:), right_cb_top, imSize);
% 
% [~,idx] = sort(boxMarkers.frontPanel_x(2,:));
% fp_y = boxMarkers.frontPanel_y(2,idx(3:5));
% fp_x = boxMarkers.frontPanel_x(2,idx(3:5)); 
% [fp_y,ia,~] = unique(fp_y);
% fp_x = fp_x(ia);
% 
% fp_pts = [fp_x',fp_y'];
% fp_mirrorMask = segregateImage(fp_pts,right_cb_bot(4,:),imSize);
% 
% % mask out anything below the green beads
% right_mirror_green_beads = boxMarkers.beadLocations.right_mirror_green_beads;
% [~,idx] = sort(right_mirror_green_beads(:,2));
% gbead1 = right_mirror_green_beads(idx(2),:);
% 
% center_green_beads = boxMarkers.beadLocations.center_green_beads;
% [~,idx] = sort(center_green_beads(:,2));
% gbead2 = center_green_beads(idx(2),:);
% 
% gb_mirrorMask = segregateImage([gbead1;gbead2], right_cb_top, imSize);
% mirrorMask = mirrorMask | (fp_mirrorMask & ~cb_mirrorMask & gb_mirrorMask);
% 
% % mask out the center region
% % find the right edge of the left checkerboard
% left_cb_edge = max(boxMarkers.cbLocations.left_center_cb(:,1));
% right_cb_edge = min(boxMarkers.cbLocations.right_center_cb(:,1));
% centerMask = false(int16(imSize));
% centerMask(:, int16(left_cb_edge : right_cb_edge)) = true;