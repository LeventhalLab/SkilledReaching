function digitMask = thresholdDigits(track, ...
                                     nextPoint, ...
                                     HSVthresh_parameters, ...
                                     hsv, ...
                                     beadMask, ...
                                     mask_bbox, ...
                                     prev_bbox, ...
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

    imSize = trackingBoxParams.imSize;
    
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
        if ~any(tempMask{iView}(:))
            digitMask{iView} = tempMask{iView};
            continue;
        end
        
        % figure out how much we predict the previous blob to have shifted
        cameraMatrixString = sprintf('P%d',iView);
        projected_point_norm = nextPoint_hom * trackingBoxParams.(cameraMatrixString);
        projected_point_hom = (trackingBoxParams.K' * projected_point_norm')';

        projected_nextPoint(iView,:) = bsxfun(@rdivide,...
                                              projected_point_hom(:,1:2),...
                                              projected_point_hom(:,3));

        fullPrevMask = false(imSize);
        if track.consecutiveInvisibleCount(iView) > 0 % no mask from the previous frame in this view for this digit
            for iPoint = 1 : 3
                x = round(track.currentDigitMarkers(1,iPoint,iView)) + prev_bbox(iView,1);
                y = round(track.currentDigitMarkers(2,iPoint,iView)) + prev_bbox(iView,2);
                fullPrevMask(y,x) = true;
            end
            fullPrevMask = connectBlobs(fullPrevMask);
            fullPrevMask = imdilate(fullPrevMask,strel('disk',2));
        else
            prevMaskStr = sprintf('digitmask%d',iView);
            % move the previous digit mask into the current bounding box
            fullPrevMask(prev_bbox(iView,2):prev_bbox(iView,2) + prev_bbox(iView,4), ...
                         prev_bbox(iView,1):prev_bbox(iView,1) + prev_bbox(iView,3)) = track.(prevMaskStr);
        end
        
        s_prev = regionprops(fullPrevMask,'centroid');
        projected_shift = round(projected_nextPoint(iView,:) - s_prev.Centroid);

        shifted_bbox_corner = mask_bbox(iView,1:2) - projected_shift;
        prevMask = fullPrevMask(shifted_bbox_corner(2):shifted_bbox_corner(2) + mask_bbox(iView,4), ...
                                shifted_bbox_corner(1):shifted_bbox_corner(1) + mask_bbox(iView,3));

        projected_nextPoint(iView,:) = projected_nextPoint(iView,:) - mask_bbox(iView,1:2);
        
        
        % first, any blobs that overlap with the previous mask should be
        % kept
        overlapMask = prevMask & tempMask{iView};
        if any(overlapMask(:))
            digitMask{iView} = imreconstruct(overlapMask,tempMask{iView});
        else   % what if there isn't any overlap?
            prev_xy = [s_prev.Centroid];
            
            s_new = regionprops(tempMask{iView},'centroid');
            new_xy = [s_new.Centroid];
            new_xy = reshape(new_xy,2,[])';
            
            xy_dist = bsxfun(@minus,new_xy,prev_xy);
            dist = sqrt(sum(xy_dist.^2,2));
            
            L = bwlabel(tempMask{iView});
            digitMask{iView} = false(size(tempMask{iView}));
            for ii = 1 : length(s_new)
                if dist(ii) < trackCheck.maxPixelsPerFrame    % how far the current blob can be from previous ones and still be considered
                        digitMask{iView} = digitMask{iView} | (L == ii);
                end
            end
        end
        digitMask{iView} = connectBlobs(digitMask{iView});
            
            
        % ASSUMING ABOVE CODE WORKS, NOW FIND NEW BLOBS THAT OVERLAP WITH
        % THE PREVIOUS MASK
        
        

% 
%             
% 
%             [~,minDistIdx] = sort(dist);
%             numBlobsToKeep = 1;
% 
%             % NEED A BETTER WAY TO DO THIS BASED ON MOVEMENT OF THE PREVOUS
%             % MASK...
% 
%             L = bwlabel(tempMask{iView});

%             for ii = 1 : numBlobsToKeep
%                 if dist(minDistIdx(ii)) < trackCheck.maxPixelsPerFrame    % how far the current blob can be from previous ones and still be considered
%                     digitMask{iView} = digitMask{iView} | (L == minDistIdx(ii));
%                 end
%             end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%