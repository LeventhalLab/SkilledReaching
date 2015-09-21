function tracks = reconstructPartiallyHiddenObjects(tracks, bboxes, fundMat, imSize, BG_mask, varargin)
%
% INPUTS:
%   tracks - 2-element cell array containing the masks of the object within
%       a bounding box in each view
%   bboxes - 2 x 4 array containing the bounding boxes of mask1 and mask2
%       within their larger images. (row 1--> mask 1, row 2 --> mask2)
%   fundMat is the fundamental matrix going from view 1 to view 2
%   imSize - 1 x 2 vector containing the height and width of the image



F = cell(1,2);
F{1} = fundMat;    % from view 1 to view 2
F{2} = fundMat';   % from view 2 to view 1

validOverlap = false(numObjects, 1);
overlapFract = zeros(1,2);

for iTrack = 2 : length(tracks)    % start with the digits
    
    centerMask = tracks(iTrack).digitmask1;
    mirrorMask = tracks(iTrack).digitmask2;
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