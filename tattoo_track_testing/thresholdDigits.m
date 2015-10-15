function digitMask = thresholdDigits(track, ...
                                     nextPoint, ...
                                     HSVthresh_parameters, ...
                                     hsv, ...
                                     numSameColorObjects, ...
                                     beadMask, ...
                                     mask_bbox, ...
                                     trackingBoxParams, ...
                                     trackCheck)
%
% INPUTS:
%   meanHSV - 3 element vector with mean hue, saturation, and value values,
%       respectively for the target region
%   stdHSV - 3 element vector with standard deviation of the hue, 
%       saturation, and value values, respectively for the target region
%   HSVthresh_parameters - structure with the following fields:
%       .min_thresh - 3 element vector containing mininum distance h/s/v
%           thresholds must be from their respective means
%       .num_stds - 3 element vector containing number of standard
%           deviations away from the mean h/s/v values to set threshold.
%           The threshold is set as whichever is further from the mean -
%           min_thresh or num_stds * std
%   hsv - 2-element cell array containing the enhanced hsv image of the paw
%       within the bounding box for the direct view (index 1) and mirror
%       view (index 2)
%   paw_img - 2-element cell array containing the original rgb image of the
%       paw within the bounding box for the direct view (index 1) and 
%       mirror view (index 2)
%   numSameColorObjects - scalar, number of digits that have the same color
%       tattoo as the current digit
%   digitBlob - cell array of blob objects containing blob parameters for
%       the direct view (index 1) and mirror view (index 2)
%   beadMask - 
%
% OUTPUTS:
%   digitMask - 1 x 2 cell array containing the mask for the direct
%       (center) and mirror views, respectively


% consider adjusting this algorithm to include knowledge from the previous
% frame

    meanHSV = track.meanHSV;
    stdHSV  = track.stdHSV;
    
    min_thresh = HSVthresh_parameters.min_thresh;
    max_thresh = HSVthresh_parameters.max_thresh;
    num_stds   = HSVthresh_parameters.num_stds;
    
    HSVlimits = zeros(2,6);
    digitMask = cell(1,2);
    tempMask = cell(1,2);
    % threshold the current image
    for iView = 1 : 2
        % construct HSV limits vector from track, HSVthresh_parameters
        HSVlimits(iView,1) = meanHSV(iView,1);            % hue mean
        HSVlimits(iView,2) = max(min_thresh(1), stdHSV(iView,1) * num_stds(1));  % hue range
        HSVlimits(iView,2) = min(max_thresh(1), HSVlimits(iView,2));  % hue range

        s_range = max(min_thresh(2), stdHSV(iView,2) * num_stds(2));
        s_range = min(max_thresh(2), s_range);
        HSVlimits(iView,3) = max(0.001, meanHSV(iView,2) - s_range);    % saturation lower bound
        HSVlimits(iView,4) = min(1.000, meanHSV(iView,2) + s_range);    % saturation upper bound

        v_range = max(min_thresh(3), stdHSV(iView,3) * num_stds(3));
        v_range = min(max_thresh(3), v_range);
        HSVlimits(iView,5) = max(0.001, meanHSV(iView,3) - v_range);    % saturation lower bound
        HSVlimits(iView,6) = min(1.000, meanHSV(iView,3) + v_range);    % saturation upper bound    
        
        % threshold the image
        tempMask{iView} = HSVthreshold(hsv{iView}, ...
                                HSVlimits(iView,:));

        tempMask{iView} = tempMask{iView} & ~beadMask{iView};

        if ~any(tempMask{iView}(:)); continue; end

        SE = strel('disk',2);
        tempMask{iView} = imopen(tempMask{iView}, SE);
        tempMask{iView} = imclose(tempMask{iView}, SE);
        tempMask{iView} = imfill(tempMask{iView}, 'holes');
    end

    % now, need to decide which blobs, if any, to keep
    
    % first, predict where the blobs should be based on recent history
    currentTrack = track.id;
    nextPoint = nextPoint / trackingBoxParams.scale;
    nextPoint_hom = [nextPoint, ones(size(nextPoint,1),1)];
    projected_nextPoint = zeros(2,2);
    for iView = 1 : 2
        cameraMatrixString = sprintf('P%d',iView);
        projected_point_norm = nextPoint_hom * trackingBoxParams.(cameraMatrixString);
        projected_point_hom = (trackingBoxParams.K' * projected_point_norm')';
        
        projected_nextPoint(iView,:) = bsxfun(@rdivide,...
                                              projected_point_hom(:,1:2),...
                                              projected_point_hom(:,3));
                                          
        projected_nextPoint(iView,:) = projected_nextPoint(iView,:) - mask_bbox(iView,1:2);
        
        s = regionprops(tempMask{iView},'centroid');
        xy = [s.Centroid];
        xy = reshape(xy,2,[])';
        
        xy_dist = bsxfun(@minus,xy,projected_nextPoint(iView,:));
        dist = sqrt(sum(xy_dist.^2,2));
        
        [~,minDistIdx] = sort(dist);
        numBlobsToKeep = min(length(s), numSameColorObjects);
        
        L = bwlabel(tempMask{iView});
        digitMask{iView} = false(size(tempMask{iView}));
        for ii = 1 : numBlobsToKeep
            if dist(minDistIdx(ii)) < trackCheck.maxPixelsPerFrame    % how far the current blob can be from previous ones and still be considered
                digitMask{iView} = digitMask{iView} | (L == minDistIdx(ii));
            end
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%