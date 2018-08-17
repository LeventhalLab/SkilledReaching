function matchedPoints = matchMirrorPointsFromInitMatch(directPoints, mirrorPoints, initMatchIdx)
%
% INPUTS:
%   directPoints, mirrorPoints - m x 2 matrices where m is the number of
%       points and each row is an (x,y) pair representing undistorted
%       points
%   initMatchIdx - n x 2 array where n is the number of points that have
%       already been matched up. The first column contains the indices in
%       pointsToMatch(:,:,1) that match with the indices in the second
%       column/pointsToMatch(:,:,2)
%
%

numPts = size(directPoints,1);

if numPts ~= size(mirrorPoints,1)
    error('directPoints and mirrorPoints must have the same number of rows')
end

matchedPoints = zeros(numPts, 2, 2);

numKnownPts = size(initMatchIdx,1);
testLines = zeros(numKnownPts,3);
linePoints = zeros(2,2);

matchedPtIdx = NaN(numPts,2);
matchedPtIdx(1:numKnownPts,:) = initMatchIdx;

for ii = 1 : numKnownPts
    linePoints(1,:) = squeeze(directPoints(initMatchIdx(ii,1),:));   % direct view
    linePoints(2,:) = squeeze(mirrorPoints(initMatchIdx(ii,2),:));   % mirror view
    
    testLines(ii,:) = lineCoeffFromPoints(linePoints);
end

epiPt = findIntersection(testLines(1,:),testLines(2,:));   % can revise this later to account for multiple matched points so the
                                                           % epipole wouldn't be uniquely determined
                                                           
% now go through the remaining points and match them up based on whether
% they lie on the same epipolar line

remainingPts = true(numPts,2);
remainingPts(initMatchIdx(:,1),1) = false;
remainingPts(initMatchIdx(:,2),2) = false;

numMatchedPts = numKnownPts;
for ii = 1 : numPts
    
    if ~remainingPts(ii,1)
        continue;
    end
    
    currentPoint = directPoints(ii,:);
    
    % calculate the distance between the line defined by the current
    % unassigned point and the epipole, and all other unassigned points
    distFromLine = NaN(numPts,1);
    
    for jj = 1 : numPts
        
        if remainingPts(jj,2)
            testPoint = mirrorPoints(jj,:);
            distFromLine(jj) = distanceToLine(currentPoint, epiPt, testPoint);
        end
        
    end
    numMatchedPts = numMatchedPts + 1;
    matchedPtIdx(numMatchedPts,1) = ii;
    
    minDistIdx = find(distFromLine == min(distFromLine));
    matchedPtIdx(numMatchedPts,2) = minDistIdx;
    
end


for ii = 1 : numPts
    matchedPoints(ii,:,1) = directPoints(matchedPtIdx(ii,1),:);
    matchedPoints(ii,:,2) = mirrorPoints(matchedPtIdx(ii,2),:);
end

end