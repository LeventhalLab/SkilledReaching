function tracks = reconstructPartiallyHiddenObjects(tracks, bboxes, fundMat, imSize, BG_mask, varargin)
%
% INPUTS:
%   tracks - 2-element cell array containing the masks of the object within
%       a bounding box in each view
%   bboxes - 2 x 4 array containing the bounding boxes of mask1 and mask2
%       within their larger images. (row 1--> mask 1, row 2 --> mask2)
%   fundMat is the fundamental matrix going from view 1 to view 2
%   imSize - 1 x 2 vector containing the height and width of the image

F = fundMat(:,:,1);    % from view 1 to view 2

for iTrack = 2 : length(tracks)    % start with the digits
    
    % calculate the distance from the epipolar lines for each proximal/
    % centroid/distal point to its image point
    centerDigitMarkers = tracks(iTrack).digitMarkers(:,:,1)';
    centerDigitMarkers(:,1) = centerDigitMarkers(:,1) + bboxes(1,1);
    centerDigitMarkers(:,2) = centerDigitMarkers(:,2) + bboxes(1,2);
    
    mirrorDigitMarkers = tracks(iTrack).digitMarkers(:,:,2)';
    mirrorDigitMarkers(:,1) = mirrorDigitMarkers(:,1) + bboxes(2,1);
    mirrorDigitMarkers(:,2) = mirrorDigitMarkers(:,2) + bboxes(2,2);
    center_epiLines = epipolarLine(F, centerDigitMarkers);
    mirror_epiLines = epipolarLine(F', mirrorDigitMarkers);
    
    center_epiPts = lineToBorderPoints(center_epiLines, imSize);
    mirror_epiPts = lineToBorderPoints(mirror_epiLines, imSize);
    d = zeros(3,2);
    center_pts1 = center_epiPts(:,1:2);
    center_pts2 = center_epiPts(:,3:4);
    
    mirror_pts1 = mirror_epiPts(:,1:2);
    mirror_pts2 = mirror_epiPts(:,3:4);
    for iMarker = 1 : 3   % proximal, centroid, distal
        
        center_test_pt = tracks(iTrack).digitMarkers(:,iMarker,1)';
        center_test_pt(1) = center_test_pt(1) + bboxes(1,1);
        center_test_pt(2) = center_test_pt(2) + bboxes(1,2);
        
        mirror_test_pt = tracks(iTrack).digitMarkers(:,iMarker,2)';
        mirror_test_pt(1) = mirror_test_pt(1) + bboxes(2,1);
        mirror_test_pt(2) = mirror_test_pt(2) + bboxes(2,2);
        d(iMarker,1) = distanceToLine(center_pts1(iMarker,:), ...
                                      center_pts2(iMarker,:), ...
                                      mirror_test_pt);
        d(iMarker,2) = distanceToLine(mirror_pts1(iMarker,:), ...
                                      mirror_pts2(iMarker,:), ...
                                      center_test_pt);
    end
    
    % WORKING HERE... NOW HAVE A MEASURE OF HOW FAR EACH POINT IS FROM THE
    % EPIPOLAR LINE PROJECTED FROM THE OTHER VIEW; IF TOO FAR APART, ONE OF
    % THEM MUST BE PARTIALLY OBSCURED. HOW TO TELL? TRY ASSUMING THAT THE
    % REGION WHOSE PROJECTION INTO THE OTHER VIEW MORE COMPLETELY ENCLOSES
    % THE OTHER IS THE FULL VIEW. THEN NEED TO ESTIMATE WHERE THE PARTIALLY
    % HIDDEN POINTS REALLY ARE...
    
    centerMask = false(imSize);
    mirrorMask = false(imSize);
    centerMask(bboxes(1,2) : bboxes(1,2) + bboxes(1,4), ...
               bboxes(1,1) : bboxes(1,1) + bboxes(1,3)) = tracks(iTrack).digitmask1;
    mirrorMask(bboxes(1,2) : bboxes(1,2) + bboxes(1,4), ...
               bboxes(1,1) : bboxes(1,1) + bboxes(1,3)) = tracks(iTrack).digitmask2;
           
end
for iView = 1 : 2
    
    projMask = calcProjMask(masks{iView}, F{iView}, bboxes(iView,:), imSize);
    projMask = projMask(bboxes(2,2) : bboxes(2,2) + bboxes(2,4), ...
                        bboxes(2,1) : bboxes(2,1) + bboxes(2,3));
    
                    
% WORKING HERE - WANT TO SET THIS UP SO THAT:
%   1) NO POINTS INCLUDED IN A DIGIT OR PAW DORSUM MASK CAN BE OUTSIDE THE
%   ORIGINAL PAW MASK
%   2) "HIDDEN" POINTS ARE IDENTIFIED BY ASSUMING THAT THE LARGER BOUNDING
%   MASK CONTAINS THE REAL DIGIT 3D COORDINATES (AS LONG AS ITS PROJECTION
%   DOESN'T EXTEND OUTSIDE THE BACKGROUND SUBTRACTED MASKING)
%   3) NEED TO FIGURE OUT HOW TO CONSTRAIN OBJECTS SO THAT THEY DON'T GROW
%   TOO MUCH WHEN I TRY TO FILL OUT THE PROJECTION MASK IN DIRECTIONS THAT
%   AREN'T IMPORTANT (MAYBE 3D RECONSTRUCTION CONSTRAINGS ALL POINTS TO BE
%   WITHIN COME RADIUS OF EACH OTHER?)
%   4) GET AROUND OBSCURATION BY THE BOX BY KNOWING WHERE THAT WILL OCCUR,
%   AND WHEN THE BOUNDING BOX OF THE PAW REACHES THOSE BORDERS, EXTEND THE
%   BBOX THROUGH THAT REGION?
    projectionOverlap = projMask & viewMask{2}(:,:,ii);
    
    numPts = length(find(viewMask{2}(:,:,ii)));
    numOverlapPts = length(find(projectionOverlap));
    
    overlapFract(ii) = numOverlapPts / numPts;
    if overlapFract(ii) > minOverlap
        validOverlap(ii) = true;
    end
end