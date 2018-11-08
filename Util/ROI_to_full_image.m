function corrected_coordinates = ROI_to_full_image(pts, ROI, cameraParams)

if size(pts,2) ~= 2
    if size(pts,1) == 2
        pts = pts';
    else
        error('pts must be an m x 2 array or 2 x m array');
    end
end

pts(:,1) = pts(:,1) + ROI(1) - 1;
pts(:,2) = pts(:,2) + ROI(2) - 1;

corrected_coordinates = undistortPoints(pts, cameraParams);
