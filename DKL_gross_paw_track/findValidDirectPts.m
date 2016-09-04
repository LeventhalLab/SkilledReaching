function [ validDirectMask, validMirrorMask, pts_below_floor ] = findValidDirectPts( floorCoords, directMask, mirrorMask, boxCalibration, pawPref )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

h = size(directMask,1);w = size(directMask,2);

overlapThresh = 1.5;
validDirectMask = directMask;
validMirrorMask = mirrorMask;
K = boxCalibration.cameraParams.IntrinsicMatrix;

switch lower(pawPref)
    case 'left',
        valid_fc = floorCoords(2,:);
        fundMat = boxCalibration.srCal.F(:,:,2);
        P = boxCalibration.srCal.P(:,:,2);
    case 'right',
        valid_fc = floorCoords(1,:);
        fundMat = boxCalibration.srCal.F(:,:,1);
        P = boxCalibration.srCal.P(:,:,1);
end

[yd,xd] = find(directMask);
[yd,idx] = sort(yd,'descend');
xd = xd(idx);
epiLines = epipolarLine(fundMat,[xd,yd]);

[ym,xm] = find(mirrorMask);

lineVals = epiLines * [xm';ym';ones(1,length(xm))];
pts_below_floor = false;
for i_dpt = 1 : length(yd)
    
    overlap_pts = (abs(lineVals(i_dpt,:)) < overlapThresh);
    overlap_x = xm(overlap_pts);
    overlap_y = ym(overlap_pts);
    if any(overlap_pts)    % epipolar line for this point overlaps with the mirror view
        switch lower(pawPref)
            case 'left',
                overlap_x_val = max(overlap_x);   % most anterior point if left paw
            case 'right',
                overlap_x_val = min(overlap_x);   % most anterior point if right paw
        end
        overlap_idx = find(overlap_x == overlap_x_val,1,'first');
        test_pt = [overlap_x(overlap_idx),overlap_y(overlap_idx)];
        
        matched_pts = [xd(i_dpt),yd(i_dpt);test_pt];
        mpts_norm = normalize_points(matched_pts,K);
        
        [pt3d,~,~] = triangulate_DL(mpts_norm(1,:),mpts_norm(2,:),eye(4,3),P);
        if pt3d(2) > valid_fc(2)   % the highest this point in the direct view can be is still below floor level
            validDirectMask(yd(i_dpt),xd(i_dpt)) = false;
%             validMirrorMask(overlap_x,overlap_y) = false;
            pts_below_floor = true;
        else
            break;
        end
        
    else    % epipolar line for this point does not overlap with the mirror view
        validDirectMask(yd(i_dpt),xd(i_dpt)) = false;
    end
   
end

% cut off the mirror mask ONLY if some of the triangulated points are below
% the floor.
if pts_below_floor
    projMask = projMaskFromTangentLines(validDirectMask, fundMat, [1 1 w-1 h-1], [h,w]);
    validMirrorMask = validMirrorMask & projMask;
end

end