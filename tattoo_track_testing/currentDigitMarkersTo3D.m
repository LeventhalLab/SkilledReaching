function markers3D = currentDigitMarkersTo3D(currentDigitMarkers, trackingBoxParams, mask_bbox)
%
% INPUTS:
%   currentDigitMarkers - nx2xmx2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is the site along each digit
%       (that is, proximal, centroid, distal, etc.), 4th dimension is the
%       view (1 = direct, 2 = mirror)
%   mask_bbox - 2 x 4 array, where each row is a standard bounding box
%       vector [x,y,w,h]
%
% OUTPUTS:
%   markers3D - n x 3 x 3 array; first index is the digit number (index to
%       pinky), second is the site on the digit (proximal to distal), third
%       is (x,y,z)
%
P1 = trackingBoxParams.P1;
P2 = trackingBoxParams.P2;
numDigits = size(currentDigitMarkers,1);
matched_points = zeros(size(currentDigitMarkers,3),2,2);

markers3D = zeros(numDigits,size(currentDigitMarkers,3),3);    % 4 digits by 3 sites by (x,y,z) coordinates
for iDigit = 1 : numDigits
    skipDigit = false;
    for iView = 1 : 2
        if all(squeeze(currentDigitMarkers(iDigit,:,:,iView)) == 0)
            skipDigit = true;
            break
        end

        for iSite = 1 : size(currentDigitMarkers,3)
            matched_points(iSite,:,iView) = squeeze(currentDigitMarkers(iDigit,:,iSite,iView));
        end
        matched_points(:,1,iView) = matched_points(:,1,iView) + mask_bbox(iView,1);
        matched_points(:,2,iView) = matched_points(:,2,iView) + mask_bbox(iView,2);
        matched_points(:,:,iView) = normalize_points(squeeze(matched_points(:,:,iView)), ...
                                                     trackingBoxParams.K);
    end
    if skipDigit; continue; end    % digit isn't visible in both views
    
    [points3d,~,~] = triangulate_DL(squeeze(matched_points(:,:,1)), ...
                                    squeeze(matched_points(:,:,2)), ...
                                    P1, P2);
    markers3D(iDigit,:,:) = points3d * trackingBoxParams.scale;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%