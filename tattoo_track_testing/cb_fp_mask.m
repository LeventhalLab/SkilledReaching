function mask = cb_fp_mask(boxMarkers, imSize)
%
% usage:
%
% function to create a mask from the checkerboard and box front panel in
% the mirror views. The paw can't appear behind the checkerboard, at least
% not in front of the front panel
%
% INPUTS:
%   boxMarkers - 
%
% OUTPUTS:
%

% find the bottom of the checkerboard pattern - nothing above that can be
% the paw, at least not in front of the refelction of the front panel
[~,idx] = sort(boxMarkers.cbLocations.left_mirror_cb(:,2));
num_cbMarkers = length(idx);

left_cb_top = boxMarkers.cbLocations.left_mirror_cb(idx(1),:);
left_cb_bot = boxMarkers.cbLocations.left_mirror_cb(idx(num_cbMarkers-3:end),:);
% find the leftmost and rightmost points
[~,idx] = sort(left_cb_bot(:,1));
left_cb_bot = left_cb_bot(idx,:);
cb_mask = segregateImage(left_cb_bot([1,4],:), left_cb_top, imSize);

[~,idx] = sort(boxMarkers.frontPanel_x(1,:));
fp_y = boxMarkers.frontPanel_y(1,idx(1:3));
fp_x = boxMarkers.frontPanel_x(1,idx(1:3)); 
[fp_y,ia,~] = unique(fp_y);
fp_x = fp_x(ia);

fp_pts = [fp_x',fp_y'];
fp_mask = segregateImage(fp_pts,left_cb_bot(1,:),imSize);

mask = fp_mask & cb_mask;



% now do the right mirror
[~,idx] = sort(boxMarkers.cbLocations.right_mirror_cb(:,2));
num_cbMarkers = length(idx);

right_cb_top = boxMarkers.cbLocations.right_mirror_cb(idx(1),:);
right_cb_bot = boxMarkers.cbLocations.right_mirror_cb(idx(num_cbMarkers-3:end),:);
% find the lefttmost and rightmost points
[~,idx] = sort(right_cb_bot(:,1));
right_cb_bot = right_cb_bot(idx,:);
cb_mask = segregateImage(right_cb_bot([1,4],:), right_cb_top, imSize);

[~,idx] = sort(boxMarkers.frontPanel_x(2,:));
fp_y = boxMarkers.frontPanel_y(2,idx(3:5));
fp_x = boxMarkers.frontPanel_x(2,idx(3:5)); 
[fp_y,ia,~] = unique(fp_y);
fp_x = fp_x(ia);

fp_pts = [fp_x',fp_y'];
fp_mask = segregateImage(fp_pts,right_cb_bot(4,:),imSize);

mask = mask | (fp_mask & cb_mask);