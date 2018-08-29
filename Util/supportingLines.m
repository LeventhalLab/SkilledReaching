function [supporting_lines] = supportingLines(pts1, pts2)
%
% function to find the supporting lines for 2 blobs/collections of points
if islogical(pts1)
    edgePts = bwmorph(pts1,'remove');
    [y,x] = find(edgePts);
    pts1 = [x,y];
end
if islogical(pts2)
    edgePts = bwmorph(pts2,'remove');
    [y,x] = find(edgePts);
    pts2 = [x,y];
end

allPts = [pts1;pts2];
fullCVHull = convhull(allPts(:,1),allPts(:,2));

% loop through points and see if we find two adjacent points that belong to
% different blobs
num_hullPoints = size(fullCVHull,1);
numLinesFound = 0;
supporting_lines = zeros(2,2,2); % each (:,:,p) array contains [x1,y1;x2,y2] coordinates that define the endpoints of a supporting line
cvPts = zeros(2,2);  % 
for ii = 1 : num_hullPoints - 1
    
    % note the first and last points found by the convhull function
    % will be the same point
    cvPts(1,:) = allPts(fullCVHull(ii),:);
    cvPts(2,:) = allPts(fullCVHull(ii+1),:);
    blobIdx = zeros(1,2);

    % which blobs do adjacent cvPts belong to?
    maxPointsPerBlob = max(size(pts1,1),size(pts2,1));
    for jj = 1 : maxPointsPerBlob
        if jj <= size(pts1,1)
            if norm(cvPts(1,:) - pts1(jj,:)) == 0
                blobIdx(1) = 1;
            end
            if norm(cvPts(2,:) - pts1(jj,:)) == 0
                blobIdx(2) = 1;
            end
        end
        if jj <= size(pts2,1)
            if norm(cvPts(1,:) - pts2(jj,:)) == 0
                blobIdx(1) = 2;
            end
            if norm(cvPts(2,:) - pts2(jj,:)) == 0
                blobIdx(2) = 2;
            end
        end
    end
    if blobIdx(1) ~= blobIdx(2)
        % these 2 points define one of the supporting lines
        numLinesFound = numLinesFound + 1;
        supporting_lines(:,:,numLinesFound) = cvPts;
    end
        
    
    
end