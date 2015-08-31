function [mp] = matchBoxMarkers(boxMarkers, varargin)
%
% usage: 
%
% INPUTS:
%   boxMarkers - 
%
% OUTPUTS:

pointsPerRow = 4;    % for the checkerboard detection

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'pointsperrow',
            pointsPerRow = varargin{iarg + 1};
    end
end

mp  = zeros(22,2,4);    % mp(:,:,1) - left mirror markers
                        % mp(:,:,2) - left direct view markers
                        % mp(:,:,3) - right direct view markers
                        % mp(:,:,4) - right mirror markers
                        
% match beads in the mirrors with beads in the direct view
mp(1:2,:,1) = boxMarkers.beadLocations.left_mirror_red_beads;
mp(3:4,:,1) = boxMarkers.beadLocations.left_mirror_top_blue_beads;
mp(5:6,:,1) = boxMarkers.beadLocations.left_mirror_shelf_blue_beads;

mp(1:2,:,2) = boxMarkers.beadLocations.center_red_beads;
mp(3:4,:,2) = boxMarkers.beadLocations.center_top_blue_beads;
mp(5:6,:,2) = boxMarkers.beadLocations.center_shelf_blue_beads;

mp(1:2,:,3) = boxMarkers.beadLocations.center_green_beads;
mp(3:4,:,3) = boxMarkers.beadLocations.center_top_blue_beads;
mp(5:6,:,3) = boxMarkers.beadLocations.center_shelf_blue_beads;

mp(1:2,:,4) = boxMarkers.beadLocations.right_mirror_green_beads;
mp(3:4,:,4) = boxMarkers.beadLocations.right_mirror_top_blue_beads;
mp(5:6,:,4) = boxMarkers.beadLocations.right_mirror_shelf_blue_beads;

left_mirror_cb(:,1) = boxMarkers.cbLocations.left_mirror_cb(:,1);
left_mirror_cb(:,2) = boxMarkers.cbLocations.left_mirror_cb(:,2);
right_mirror_cb(:,1) = boxMarkers.cbLocations.right_mirror_cb(:,1);
right_mirror_cb(:,2) = boxMarkers.cbLocations.right_mirror_cb(:,2);
left_center_cb(:,1) = boxMarkers.cbLocations.left_center_cb(:,1);
left_center_cb(:,2) = boxMarkers.cbLocations.left_center_cb(:,2);
right_center_cb(:,1) = boxMarkers.cbLocations.right_center_cb(:,1);
right_center_cb(:,2) = boxMarkers.cbLocations.right_center_cb(:,2);

num_cb_points = size(left_center_cb,1);
startMatchPoint = 7;    % 6 bead marker points before starting the checkerboard matching
endMatchPoint   = startMatchPoint + num_cb_points - 1;

% sort checkerboard points in the mirror views so they go left to right
% across the first row, then left to right across the second row, etc.

% sort checkerboard points in the direct views so they go right to left
% across the first row, then left to right across the second row, etc.

% the sort ensures that the point correspondences are correct
[~, sortIdx] = sort(left_mirror_cb(:,2));
left_mirror_cb = left_mirror_cb(sortIdx,:);

[~, sortIdx] = sort(right_mirror_cb(:,2));
right_mirror_cb = right_mirror_cb(sortIdx,:);

[~, sortIdx] = sort(left_center_cb(:,2));
left_center_cb = left_center_cb(sortIdx,:);

[~, sortIdx] = sort(right_center_cb(:,2));
right_center_cb = right_center_cb(sortIdx,:);

numRows = num_cb_points / pointsPerRow;
if numRows ~= round(numRows)
    error('must have same number of points in each checkerboard row')
end
for iRow = 1 : numRows
    startIdx = (iRow-1)*pointsPerRow + 1;
    endIdx   = iRow*pointsPerRow;
    temp = left_mirror_cb(startIdx:endIdx,:);
    [~,sortIdx] = sort(temp(:,1),'ascend');
    left_mirror_cb(startIdx:endIdx,:) = temp(sortIdx,:);
    
    temp = right_mirror_cb(startIdx:endIdx,:);
    [~,sortIdx] = sort(temp(:,1),'ascend');
    right_mirror_cb(startIdx:endIdx,:) = temp(sortIdx,:);
    
    temp = left_center_cb(startIdx:endIdx,:);
    [~,sortIdx] = sort(temp(:,1),'descend');
    left_center_cb(startIdx:endIdx,:) = temp(sortIdx,:);
    
    temp = right_center_cb(startIdx:endIdx,:);
    [~,sortIdx] = sort(temp(:,1),'descend');
    right_center_cb(startIdx:endIdx,:) = temp(sortIdx,:);
end

mp(startMatchPoint:endMatchPoint,:,1) = left_mirror_cb;
mp(startMatchPoint:endMatchPoint,:,2) = left_center_cb;
mp(startMatchPoint:endMatchPoint,:,3) = right_center_cb;
mp(startMatchPoint:endMatchPoint,:,4) = right_mirror_cb;

