function tracks = reconstructCompletelyHiddenObjects(tracks, ...
                                                     bboxes, ...
                                                     prev_bboxes, ...
                                                     fundMat, ...
                                                     imSize, ...
                                                     BG_mask, ...
                                                     trackingBoxParams, ...
                                                     varargin)
%
% INPUTS:
%   tracks - the full list of tracks objects
%   bboxes - 2 x 4 array containing the bounding boxes of mask1 and mask2
%       within their larger images. (row 1--> mask 1, row 2 --> mask2)
%   fundMat - 3 x 3 x 2 matrix, where fundMat(:,:,1) is the fundamental
%       matrix going from the direct view to the mirror view;
%       fundMat(:,:,2) is the fundamental matrix going from the mirror view
%       to the direct view
%   imSize - 1 x 2 vector containing the height and width of the image
%   BG_mask - 1 x 3 cell array containing the background mask in the
%       center, dorsum mirror, and palm mirror, respectively. The mask only
%       contains the corresponding bounding boxes defined by bboxes
% VARARGs:
%
% OUTPUTS:
%   tracks - 

lineMaskDistThresh = 3;
maxIterations = 6;

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'linemaskdistthresh',
            lineMaskDistThresh = varargin{iarg + 1};
    end
end

numDigits = length(tracks)-3;
obscuredView = false(numDigits, 2);
markersCalculated = false(numDigits, 2);
for iDigit = 1 : numDigits
    currentTrack = tracks(iDigit + 1);
    obscuredView(iDigit,:) = ~currentTrack.isvisible(1:2);
    markersCalculated(iDigit,:) = currentTrack.markersCalculated(1:2);
end
singleViewObscured = (sum(obscuredView,2)==1);
bothViewsObscured = (sum(obscuredView,2)==2);
bothMarkersCalculated = (sum(markersCalculated,2)==2);

allSingleViewsUpdated = all(bothMarkersCalculated);
numIterations = 0;
while ~allSingleViewsUpdated
    numIterations = numIterations + 1;
    
    for iDigit = 1 : numDigits
        if singleViewObscured(iDigit)
            % is there a neighboring digit with all markers calculated?
            validNeighbor = hasNeighborBeenCalculated(iDigit, bothMarkersCalculated);
            if validNeighbor || numIterations == maxIterations
                obscuredViewIdx = find(obscuredView(iDigit,:));
                visibleViewIdx = 3 - obscuredViewIdx;
                
                if visibleViewIdx == 1
                    F = fundMat(:,:,1);
                else
                    F = fundMat(:,:,1)';
                end
                
                % MIGHT BE ABLE TO SIMPLIFY THIS IF WE ALWAYS USE THE
                % PREVIOUS DIGIT LOCATIONS TO FIND THE CLOSEST POINT FOR
                % THE NEW LOCATIONS
                tracks(iDigit+1) = predictCompletelyObscuredPoints(tracks, ...
                                                                   iDigit + 1, ...
                                                                   F, ...
                                                                   bboxes, ...
                                                                   prev_bboxes, ...
                                                                   imSize, ...
                                                                   BG_mask, ...
                                                                   lineMaskDistThresh);
                tracks(iDigit+1) = digit3Dpoints(trackingBoxParams, tracks(iDigit+1), bboxes);
                
                markersCalculated(iDigit,:) = tracks(iDigit+1).markersCalculated(1:2);
                bothMarkersCalculated = (sum(markersCalculated,2)==2);
                
                singleViewObscured(iDigit) = false;
                
            end  % if validNeighbor
            
        elseif bothViewsObscured(iDigit)
            % guess where this digit moved based on how everything else
            % moved
            validNeighbor = hasNeighborBeenCalculated(iDigit, bothMarkersCalculated);
            
            if validNeighbor || numIterations == maxIterations
                
                anticipatedPoints = predict_3DDigitMovement(tracks, ...
                                                            iDigit + 1, ...
                                                            trackingBoxParams, ...
                                                            bothMarkersCalculated);
            else
                continue;
            end
            
            for iView = 1 : 2
                anticipatedPoints(:,:,iView) = bsxfun(@minus,...
                                                       squeeze(anticipatedPoints(:,:,iView)), ...
                                                       squeeze(bboxes(iView,1:2)));
                tracks(iDigit+1).currentDigitMarkers(:,:,iView) = anticipatedPoints(:,:,iView)';
            end
            
            tracks(iDigit+1).markersCalculated(1:2) = true;
            
            tracks(iDigit+1) = digit3Dpoints(trackingBoxParams, tracks(iDigit+1), bboxes);
            
            markersCalculated(iDigit,:) = tracks(iDigit+1).markersCalculated(1:2);
            bothMarkersCalculated = (sum(markersCalculated,2)==2);
            
            bothViewsObscured(iDigit) = false;
        end
        
    end
    
    bothMarkersCalculated = (sum(markersCalculated,2)==2);
    allSingleViewsUpdated = all(bothMarkersCalculated);
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function validNeighbor = hasNeighborBeenCalculated(iDigit, bothMarkersCalculated)

validNeighbor = 0;
numDigits = length(bothMarkersCalculated);

switch iDigit
    case 1,
        if bothMarkersCalculated(iDigit + 1)
            validNeighbor = iDigit + 1;
        end
    case numDigits,
        if bothMarkersCalculated(iDigit - 1)
            validNeighbor = iDigit - 1;
        end
    otherwise,
        if bothMarkersCalculated(iDigit + 1)
            validNeighbor = iDigit + 1;
        elseif bothMarkersCalculated(iDigit - 1)
            validNeighbor = iDigit - 1;
        end
end
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obscuredTrack = predictCompletelyObscuredPoints(tracks, ...
                                                         obscuredTrackIdx, ...
                                                         F, ...
                                                         bboxes, ...
                                                         prev_bboxes, ...
                                                         imSize, ...
                                                         BG_mask, ...
                                                         lineMaskDistThresh)


obscuredTrack = tracks(obscuredTrackIdx);
obscuredView = find(~obscuredTrack.isvisible(1:2));
visibleView = 3 - obscuredView;

visible_pts_from_obscured_track = obscuredTrack.currentDigitMarkers(:,:,visibleView)';   % points identified in the view that is visible from the same track

pointsPerDigit = size(visible_pts_from_obscured_track,1);

% anticipatedPoints = zeros(pointsPerDigit, 2);
for iPoint = 1 : pointsPerDigit
    visible_pts_from_obscured_track(iPoint,:) = ...
        visible_pts_from_obscured_track(iPoint,:) + ...
        bboxes(visibleView,1:2) - 1;
%     prev_obscured_pts(iPoint,:) = prev_obscured_pts(iPoint,:) + prev_bboxes(obscuredView,1:2) - 1;
%     anticipatedPoints(iPoint,:) = prev_obscured_pts(iPoint,:) + ...
%                                   meanMovement;
end

anticipatedPoints = predictDigitMovement(tracks, ...
                                         obscuredTrackIdx, ...
                                         bboxes, ...
                                         prev_bboxes);
anticipatedPoints = squeeze(anticipatedPoints(:,:,obscuredView));
% calculate epipolar lines
epiLines = epipolarLine(F, visible_pts_from_obscured_track);

predicted_points = zeros(size(visible_pts_from_obscured_track,1),2);

paw_mask = false(imSize);
paw_mask(bboxes(obscuredView,2) : bboxes(obscuredView,2) + bboxes(obscuredView,4),...
         bboxes(obscuredView,1) : bboxes(obscuredView,1) + bboxes(obscuredView,3)) = BG_mask{obscuredView};

% old_paw_mask = paw_mask;
     
for iPoint = 1 : size(anticipatedPoints,1)
    paw_mask(round(anticipatedPoints(iPoint,2)), ...
             round(anticipatedPoints(iPoint,1))) = true;
    paw_mask = connectBlobs(paw_mask);
end
% make sure that paw_mask includes anticipatedPoints
paw_mask = imdilate(paw_mask,strel('disk',3));

for iPoint = 1 : size(predicted_points,1)
    
%     old_overlapMask = lineMaskOverlap(old_paw_mask, epiLines(iPoint,:),'distThresh',lineMaskDistThresh);
%     if ~any(old_overlapMask(:))
%         disp('hold here')
%     end
    overlapMask = false(imSize);
    while ~any(overlapMask(:))
        overlapMask = lineMaskOverlap(paw_mask, epiLines(iPoint,:),'distThresh',lineMaskDistThresh);
        paw_mask = imdilate(paw_mask,strel('disk',1));
    end
    
    [y,x] = find(overlapMask);
    [~,nnidx] = findNearestNeighbor(anticipatedPoints(iPoint,:),[x,y]);
    predicted_points(iPoint,:) = [x(nnidx),y(nnidx)];

    predicted_points(iPoint,:) = predicted_points(iPoint,:) - bboxes(obscuredView,1:2) + 1;
end

obscuredTrack.currentDigitMarkers(:,:,obscuredView) = predicted_points';
obscuredTrack.markersCalculated(1:2) = true;

end    % end function predictCompletelyObscuredPoints
                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function anticipatedPoints = predictDigitMovement(tracks, ...
                                                  obscuredTrackIdx, ...
                                                  bboxes, ...
                                                  prev_bboxes)

obscuredTrack = tracks(obscuredTrackIdx);
obscuredView = ~obscuredTrack.isvisible(1:2);

pointsPerDigit = size(obscuredTrack.currentDigitMarkers,2);

anticipatedPoints = zeros(pointsPerDigit, 2, 2);

for iView = 1 : 2
    prev_obscured_pts = obscuredTrack.previousDigitMarkers(:,:,iView)';
    markersDiff = NaN(pointsPerDigit * 4,2);
    
    % calculate the mean movement of points that are visible in the current
    % view
    for iDigit = 2 : length(tracks) - 1
        if iDigit == obscuredTrackIdx; continue; end
        if ~obscuredView(iView); continue; end
        if tracks(iDigit).markersCalculated(iView)    % we have markers for the current digit
            currentPoints  = tracks(iDigit).currentDigitMarkers(:,:,iView)';
            previousPoints = tracks(iDigit).previousDigitMarkers(:,:,iView)';
            for iPoint = 1 : pointsPerDigit
                currentPoints(iPoint,:)  = currentPoints(iPoint,:) + bboxes(iView,1:2) - 1;
                previousPoints(iPoint,:) = previousPoints(iPoint,:) + prev_bboxes(iView,1:2) -1 ;
            end
            startPt = (iDigit-2) * pointsPerDigit + 1;
            endPt = startPt + 2;
            markersDiff(startPt:endPt,:) = currentPoints - previousPoints;
        end
    end
    
    meanMovement = nanmean(markersDiff,1);
    
    for iPoint = 1 : pointsPerDigit
        prev_obscured_pts(iPoint,:) = prev_obscured_pts(iPoint,:) + prev_bboxes(iView,1:2) - 1;
        anticipatedPoints(iPoint,:, iView) = prev_obscured_pts(iPoint,:) + ...
                                             meanMovement;
    end
    
    temp = squeeze(anticipatedPoints(:,:,iView));
    if all(isnan(temp(:)))    % no digits were visible in this view, may be passing behind front panel
        for iPoint = 1 : 3
            anticipatedPoints(iPoint,:,iView) = prev_obscured_pts(iPoint,:) - prev_bboxes(iView,1:2) + bboxes(iView,1:2);
        end
    end    
    
end

end % function predictDigitMovement

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function anticipatedPoints = predict_3DDigitMovement(tracks, ...
                                                     obscuredTrackIdx, ...
                                                     trackingBoxParams, ...
                                                     bothMarkersCalculated)
                                                
obscuredTrack = tracks(obscuredTrackIdx);
obscuredView = find(~obscuredTrack.isvisible(1:2));

pointsPerDigit = size(obscuredTrack.currentDigitMarkers,2);
anticipatedPoints = zeros(pointsPerDigit, 2, 2);
anticipated_3Dloc = NaN(4,pointsPerDigit,3);   % digit ID by location (prox,centroid,distal) x (x,y,z) predicted location
% Where was the obscured digit in 3-D space compared to the neighboring
% digits?
for iTrack = 2 : 5
    if iTrack == obscuredTrackIdx; continue; end
    if ~bothMarkersCalculated(iTrack - 1); continue; end
    
    dig3Ddisplacement = tracks(obscuredTrackIdx).prev_markers3D - ...
                        tracks(iTrack).prev_markers3D;
	anticipated_3Dloc(iTrack-1,:,:) = tracks(iTrack).markers3D + dig3Ddisplacement;
end

mean_3Dloc = squeeze(nanmean(anticipated_3Dloc,1));
mean_3Dloc = mean_3Dloc / trackingBoxParams.scale;

% now project back into direct and mirror views
mean_3Dloc_hom = [mean_3Dloc, ones(size(mean_3Dloc,1),1)];

direct_view_pts_norm = mean_3Dloc_hom * trackingBoxParams.P1;
direct_view_pts_hom = (trackingBoxParams.K' * direct_view_pts_norm')';
anticipatedPoints(:,:,1) = bsxfun(@rdivide,direct_view_pts_hom(:,1:2),direct_view_pts_hom(:,3));

mirror_view_pts_norm = mean_3Dloc_hom * trackingBoxParams.P2;
mirror_view_pts_hom = (trackingBoxParams.K' * mirror_view_pts_norm')';
anticipatedPoints(:,:,2) = bsxfun(@rdivide,mirror_view_pts_hom(:,1:2),mirror_view_pts_hom(:,3));

end    % function predict_3DDigitMovement