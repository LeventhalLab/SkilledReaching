function [Ps1, Ps2] = scaleCameraMatrices(boxMarkers, rat_metadata, P1, P2, worldPoints)

pawPref = lower(rat_metadata.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

switch pawPref
    case 'left',
        dMirrorIdx = 3;   % index of mirror with dorsal view of paw
        F_side = boxMarkers.F.right;
        mirrorPoints = boxMarkers.cbLocations.right_mirror_cb;
        centerPoints = boxMarkers.cbLocations.right_center_cb;
        numCBrows = boxMarkers.cbLocations.num_right_mirror_cb_rows;
    case 'right',
        dMirrorIdx = 1;   % index of mirror with dorsal view of paw
        F_side = boxMarkers.F.left;
        mirrorPoints = boxMarkers.cbLocations.left_mirror_cb;
        centerPoints = boxMarkers.cbLocations.left_center_cb;
        numCBrows = boxMarkers.cbLocations.num_left_mirror_cb_rows;
end
points_per_row = size(mirrorPoints,1) / numCBrows;

mirrorPoints(:,1) = mirrorPoints(:,1) - boxMarkers.register_ROI(dMirrorIdx,1) + 1;
% flip left/right
mirrorPoints(:,1) = boxMarkers.register_ROI(dMirrorIdx,3) - mirrorPoints(:,1) + 1;
mirrorPoints(:,2) = mirrorPoints(:,2) - boxMarkers.register_ROI(dMirrorIdx,2) + 1;

centerPoints(:,1) = centerPoints(:,1) - boxMarkers.register_ROI(2,1) + 1;
centerPoints(:,2) = centerPoints(:,2) - boxMarkers.register_ROI(2,2) + 1;

% sort points so they go left to right across the first row, then left to
% right across the second row, etc.
[~, sortIdx] = sort(mirrorPoints(:,2));
mirrorPoints = mirrorPoints(sortIdx,:);

[~, sortIdx] = sort(centerPoints(:,2));
centerPoints = centerPoints(sortIdx,:);
for iRow = 1 : numCBrows
    startIdx = (iRow-1) * points_per_row + 1;
    endIdx   = startIdx + points_per_row - 1;
    
    temp = mirrorPoints(startIdx:endIdx,:);
    [~, sortIdx] = sort(temp(:,1));
    mirrorPoints(startIdx:endIdx,:) = temp(sortIdx, :);
    
    temp = centerPoints(startIdx:endIdx,:);
    [~, sortIdx] = sort(temp(:,1));
    centerPoints(startIdx:endIdx,:) = temp(sortIdx, :); 
end

calculated_wPoints = triangulate(centerPoints, mirrorPoints, P1, P2);

end
    
