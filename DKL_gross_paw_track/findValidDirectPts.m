function [ validDirectMask ] = findValidDirectPts( floorCoords, directMask, mirrorMask, boxCalibration, pawPref )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

overlapThresh = 0.01;
validDirectMask = directMask;

switch lower(pawPref)
    case 'left',
        valid_fc = floorCoords(2,:);
        fundMat = boxCalibration.srCal.F(:,:,2);
    case 'right',
        valid_fc = floorCoords(1,:);
        fundMat = boxCalibration.srCal.F(:,:,1);
end

[yd,xd] = find(directMask);
epiLines = epipolarLine(fundMat,[xd,yd]);

[ym,xm] = find(mirrorMask);

lineVals = epiLines * [xm';ym';ones(1,length(xm))];
for i_dpt = 1 : length(yd)
    
    overlap_pts = (lineVals(i_dpt,:) < overlapThresh);
    if ~isempty(overlap_pts)    % epipolar line for this point overlaps with the mirror view
        switch lower(pawPref)
            case 'left',
                overlap_x_val = max(xm(overlap_pts));   % most anterior point if left paw
            case 'right',
                overlap_x_val = min(xm(overlap_pts));   % most anterior point if right paw
        end
        overlap_idx = find(xm == overlap_xval,1,'first');
        test_pt = [xm(overlap_idx),ym(overlap_idx)];
    else    % epipolar line for this point does not overlap with the mirror view
        validDirectMask(yd,xd) = false;
    end
    
    % WORKING HERE...
%     
%     % find overlap of current point with mask in mirror
%     valid_x = []; valid_y = [];
%     for i_mpt = 1 : length(ym)
%         lineVal = lines(1) * xm(i_mpt) + 
    
    
end