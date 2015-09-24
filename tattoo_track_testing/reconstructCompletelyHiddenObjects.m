function tracks = reconstructCompletelyHiddenObjects(tracks, bboxes, fundMat, imSize, BG_mask, varargin)
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

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'linemaskdistthresh',
            lineMaskDistThresh = varargin{iarg + 1};
    end
end

numDigits = length(tracks)-2;
obscuredView = false(numDigits, 2);
markersCalculated = false(numDigits, 2);
for iDigit = 1 : numDigits
    currentTrack = tracks(iDigit + 1);
    obscuredView(iDigit,:) = ~currentTrack.isvisible(1:2);
    markersCalculated(iDigit,:) = currentTrack.markersCalculated(1:2);
end
singleViewObscured = (sum(obscuredView,2)==1);
bothMarkersCalculated = (sum(markersCalculated,2)==2);

allSingleViewsUpdated = all(bothMarkersCalculated);
while ~allSingleViewsUpdated
    
    for iDigit = 1 : numDigits
        if singleViewObscured(iDigit)
            % is there a neighboring digit with all markers calculated?
            validNeighbor = hasNeighborBeenCalculated(iDigit, bothMarkersCalculated);
            if validNeighbor
                obscuredViewIdx = find(obscuredView(iDigit,:));
                visibleViewIdx = 3 - obscuredViewIdx;
%                 visible_bbox = bboxes(visibleViewIdx,:);
%                 obscured_bbox = bboxes(obscuredViewIdx,:);
                
                F = fundMat(:,:,visibleViewIdx);
                
                % MIGHT BE ABLE TO SIMPLIFY THIS IF WE ALWAYS USE THE
                % PREVIOUS DIGIT LOCATIONS TO FIND THE CLOSEST POINT FOR
                % THE NEW LOCATIONS
                tracks(iDigit+1) = predictCompletelyObscuredPoints(tracks(iDigit + 1), ...
                                                                   F, ...
                                                                   bboxes, ...
                                                                   imSize, ...
                                                                   BG_mask, ...
                                                                   lineMaskDistThresh);
                tracks(iDigit+1) = digit3Dpoints(trackingBoxParams, tracks(iDigit+1), bboxes);
                
                markersCalculated(iDigit,:) = tracks(iDigit+1).markersCalculated(1:2);
                singleViewObscured(iDigit) = false;
                
            end  % if validNeighbor
            
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
function obscuredTrack = predictCompletelyObscuredPoints(obscuredTrack, ...
                                                         F, ...
                                                         bboxes, ...
                                                         imSize, ...
                                                         BG_mask, ...
                                                         lineMaskDistThresh)

                                                     
obscuredView = find(~obscuredTrack.isvisible(1:2));
visibleView = 3 - obscuredView;
visible_pts_from_obscured_track = obscuredTrack.currentDigitMarkers(:,:,visibleView)';   % points identified in the view that is visible from the same track
% pts_from_visible_neighbor = visibleTrack.currentDigitMarkers(:,:,obscuredView)';         % points in the obscured view from the neighboring digit
prev_pts = obscuredTrack.previousDigitMarkers(:,:,obscuredView)';
for iPoint = 1 : size(visible_pts_from_obscured_track, 1)
    visible_pts_from_obscured_track(iPoint,:) = ...
        visible_pts_from_obscured_track(iPoint,:) + ...
        bboxes(visibleView,1:2);
%     pts_from_visible_neighbor(iPoint,:) = ...
%         pts_from_visible_neighbor(iPoint,:) + ...
%         bboxes(obscuredView,1:2);
end

% calculate epipolar lines
epiLines = epipolarLine(F, visible_pts_from_obscured_track);
% epiPts = lineToBorderPoints(epiLines, imSize);

predicted_points = zeros(size(visible_pts_from_obscured_track,1),2);

paw_mask = false(imSize);
paw_mask(bboxes(obscuredView,2) : bboxes(obscuredView,2) + bboxes(obscuredView,4),...
         bboxes(obscuredView,1) : bboxes(obscuredView,1) + bboxes(obscuredView,3)) = BG_mask{obscuredView};
     
for iPoint = 1 : size(predicted_points,1)
    overlapMask = lineMaskOverlap(paw_mask, epiLines(iPoint,:),'distThresh',lineMaskDistThresh);
    
    [y,x] = find(overlapMask);
    [~,nnidx] = findNearestNeighbor(prev_pts(iPoint,:),[x,y]);
    predicted_points(iPoint,:) = [x(nnidx),y(nnidx)];
%     predicted_points(iPoint,:) = findNearestPointOnLine(epiPts(iPoint,1:2),...
%                                                         epiPts(iPoint,3:4),...
%                                                         pts_from_visible_neighbor(iPoint,:));
                                                    
    % check that the predicted point is within the paw mask
	ptMask = false(imSize);
    ptMask(round(predicted_points(iPoint,2)),round(predicted_points(iPoint,1))) = true;
    overlap = ptMask & paw_mask;
    
    if ~any(overlap(:))    % predicted point is not within the paw mask
        paw_edge = bwmorph(paw_mask,'remove');
        [y, x] = find(paw_edge);
        [~,nnidx] = findNearestNeighbor(predicted_points(iPoint,:),[x,y]);
        predicted_points(iPoint,:) = [x(nnidx),y(nnidx)];
    end
    
    predicted_points(iPoint,:) = predicted_points(iPoint,:) - bboxes(obscuredView,1:2);
end

obscuredTrack.currentDigitMarkers(:,:,obscuredView) = predicted_points;
obscuredTrack.markersCalculated(1:2) = true;

end    % end function predictCompletelyObscuredPoints
                  