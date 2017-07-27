function [ newVolume ] = volume_from_silhouettes( silhouette1, silhouette2, boxCalibration )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

K = boxCalibration.cameraParams.IntrinsicMatrix;

mask_ext = cell(1,2);
ext_pts = cell(1,2);
mask_ext{1} = bwmorph(silhouette1,'remove');
mask_ext{2} = bwmorph(silhouette2,'remove');

% for each point around the edge of the direct view silhouette, find the
% front and back limit based on where the epipolar line intersects the
% silhouette in the mirror view
num_direct_pts = size(mask_ext{1},1);
borderPts = cell(1,2);

for iView = 1 : 2
    otherView = 3 - iView;
    borderPts{iView} = zeros(num_direct_pts*2,2);
    epiLines = epipolarLine(fundmat, mask_ext{iView});   % start with the direct view
    
    [y,x] = find(mask_ext{iView});
    s = regionprops(mask_ext{iView},'Centroid');
    ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
    
    for i_pt = 1 : num_direct_pts
        borderIdx = (i_pt-1) * 2; % store the first border point at borderIdx; store the second one at borderIdx + 1
        
        lineValue = epiLines(ii,1) * ext_pts{otherView}(:,1) + ...
            epiLines(ii,2) * ext_pts{otherView}(:,2) + epiLines(ii,3);
    
        [intersect_idx, isLocalExtremum] = detectCircularZeroCrossings(lineValue);