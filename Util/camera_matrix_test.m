%%
pawPref = lower(rat_metadata.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

switch pawPref
    case 'left',
        dMirrorIdx = 3;   % index of mirror with dorsal view of paw
        F_side = boxMarkers.F.right;
        mirrorPoints = boxMarkers.cbLocations.right_mirror_cb;
        centerPoints1 = boxMarkers.cbLocations.right_center_cb;
        centerPoints2 = boxMarkers.cbLocations.left_center_cb;
    case 'right',
        dMirrorIdx = 1;   % index of mirror with dorsal view of paw
        F_side = boxMarkers.F.left;
        mirrorPoints = boxMarkers.cbLocations.left_mirror_cb;
        centerPoints1 = boxMarkers.cbLocations.left_center_cb;
        centerPoints2 = boxMarkers.cbLocations.right_center_cb;
end

mirrorPoints(:,1) = mirrorPoints(:,1) - boxMarkers.register_ROI(dMirrorIdx,1) + 1;
% flip left/right
mirrorPoints(:,1) = boxMarkers.register_ROI(dMirrorIdx,3) - mirrorPoints(:,1) + 1;
mirrorPoints(:,2) = mirrorPoints(:,2) - boxMarkers.register_ROI(dMirrorIdx,2) + 1;

centerPoints1(:,1) = centerPoints1(:,1) - boxMarkers.register_ROI(2,1) + 1;
centerPoints1(:,2) = centerPoints1(:,2) - boxMarkers.register_ROI(2,2) + 1;

centerPoints2(:,1) = centerPoints2(:,1) - boxMarkers.register_ROI(2,1) + 1;
centerPoints2(:,2) = centerPoints2(:,2) - boxMarkers.register_ROI(2,2) + 1;

% [cPoints1, ~] = clockwisePointCorrespondence(centerPoints1);
% [cPoints2, ~] = clockwisePointCorrespondence(centerPoints2);

[cPoints1, ~] = row_wisePointCorrespondence(centerPoints1);
[cPoints2, worldPoints] = row_wisePointCorrespondence(centerPoints2);
% [mPoints, worldPoints]  = clockwisePointCorrespondence(mirrorPoints);

cPoints = zeros(size(cPoints1,1),size(cPoints1,2),size(cPoints1,3)*2);
cPoints(:,:,1:2) = cPoints1;
cPoints(:,:,3:4) = cPoints2;

%%
% find the top left square corners
[~, sortIdx] = sort(mirrorPoints(:,2));
mirrorPoints = mirrorPoints(sortIdx,:);

[~, sortIdx] = sort(centerPoints1(:,2));
centerPoints1 = centerPoints1(sortIdx,:);

mirrorRow = zeros(4,2,4);
centerRow = zeros(4,2,4);
for iRow = 1 : 4
    startIdx = (iRow - 1) * 4 + 1;
    temp = mirrorPoints(startIdx:startIdx + 3, :);
    % now arrange from left to right
    [~,sortIdx] = sort(temp(:,1));
    mirrorRow(:,:,iRow) = temp(sortIdx,:);
    
    temp = centerPoints1(startIdx:startIdx + 3, :);
    [~,sortIdx] = sort(temp(:,1));
    centerRow(:,:,iRow) = temp(sortIdx,:);
end

% convert checkerboard corner points into camera view coordinates
imPoints = zeros(4,2,4,2);    % 4 points, 2 coords (x,y), 4 "images", 2 "cameras"

% top row checkerboard
imPoints(1:2,:,1,1) = centerRow(1:2,:,1);   % camera view 1 (direct view)
imPoints(3:4,:,1,1) = centerRow(1:2,:,2);

imPoints(1:2,:,1,2) = mirrorRow(1:2,:,1);   % camera view 2 (mirror view)
imPoints(3:4,:,1,2) = mirrorRow(1:2,:,2);

% middle row checkerboard square
imPoints(1:2,:,2,1) = centerRow(3:4,:,1);   % camera view 1 (direct view)
imPoints(3:4,:,2,1) = centerRow(3:4,:,2);

imPoints(1:2,:,2,2) = mirrorRow(3:4,:,1);   % camera view 2 (mirror view)
imPoints(3:4,:,2,2) = mirrorRow(3:4,:,2);

% bottom left checkerboard square
imPoints(1:2,:,3,1) = centerRow(1:2,:,3);   % camera view 1 (direct view)
imPoints(3:4,:,3,1) = centerRow(1:2,:,4);

imPoints(1:2,:,3,2) = mirrorRow(1:2,:,3);   % camera view 2 (mirror view)
imPoints(3:4,:,3,2) = mirrorRow(1:2,:,4);

% bottom right checkerboard square
imPoints(1:2,:,4,1) = centerRow(3:4,:,3);   % camera view 1 (direct view)
imPoints(3:4,:,4,1) = centerRow(3:4,:,4);

imPoints(1:2,:,4,2) = mirrorRow(3:4,:,3);   % camera view 2 (mirror view)
imPoints(3:4,:,4,2) = mirrorRow(3:4,:,4);

worldPoints2 = [00 00
                08 00
                00 08
                08 08];

imPoints1(1:4,:,1) = centerRow
worldPoints1 = [00 00
                08 00
                16 00
                24 00
                00 08
                08 08
                16 08
                24 08];
                



[cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(squeeze(imPoints(:,:,:,1)), worldPoints);
%%
[stereoParams, imagesUsed, estimationErrors] = estimateCameraParameters(imPoints, worldPoints);
               