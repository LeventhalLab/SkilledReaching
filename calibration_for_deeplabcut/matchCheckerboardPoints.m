function matchIdx = matchCheckerboardPoints(directChecks, mirrorChecks, mirrorOrientation)
%
% INPUTS:
%   directChecks, mirrorChecks - m x 2 arrays containing the checkerboard
%       points
%   mirrorOrientation - cell array containing the strings "top", "left", or
%       "right"
%
% OUTPUTS:
%   matchIdx


%%%%%%%%%%take out these lines later - for debugging
% h=1024;
% w=2040;
%%%%%%%%%%take out these lines later - for debugging

num_points = size(mirrorChecks,1);
if num_points ~= size(directChecks,1)
    error('directChecks and mirrorChecks must have the same number of rows')
end

matchIdx = zeros(num_points,2);
testMatch = zeros(num_points,2,2);
assignedPoints = false(num_points, 2);
% if the top mirror, the left- and right-most points should match up
% if the left/right mirror, the top- and bottom-most points should match up
switch mirrorOrientation

    case 'top'
        direct_ltIdx = directChecks(:,1) == min(directChecks(:,1));
        direct_rtIdx = directChecks(:,1) == max(directChecks(:,1));
        mirror_ltIdx = mirrorChecks(:,1) == min(mirrorChecks(:,1));
        mirror_rtIdx = mirrorChecks(:,1) == max(mirrorChecks(:,1));
        
        try
        testMatch(1,:,1) = directChecks(direct_ltIdx,:);
        catch
            keyboard
        end
        testMatch(2,:,1) = directChecks(direct_rtIdx,:);
        testMatch(1,:,2) = mirrorChecks(mirror_ltIdx,:);
        testMatch(2,:,2) = mirrorChecks(mirror_rtIdx,:);
        
        assignedPoints(direct_ltIdx,1) = true;
        assignedPoints(direct_rtIdx,1) = true;
        assignedPoints(mirror_ltIdx,2) = true;
        assignedPoints(mirror_rtIdx,2) = true;
        
        matchIdx(1,1) = find(direct_ltIdx);
        matchIdx(2,1) = find(direct_rtIdx);
        matchIdx(1,2) = find(mirror_ltIdx);
        matchIdx(2,2) = find(mirror_rtIdx);
    case {'left','right'}
        direct_topIdx = directChecks(:,2) == min(directChecks(:,2));
        direct_botIdx = directChecks(:,2) == max(directChecks(:,2));
        mirror_topIdx = mirrorChecks(:,2) == min(mirrorChecks(:,2));
        mirror_botIdx = mirrorChecks(:,2) == max(mirrorChecks(:,2));
        
        testMatch(1,:,1) = directChecks(direct_topIdx,:);
        testMatch(2,:,1) = directChecks(direct_botIdx,:);
        testMatch(1,:,2) = mirrorChecks(mirror_topIdx,:);
        testMatch(2,:,2) = mirrorChecks(mirror_botIdx,:);
        
        assignedPoints(direct_topIdx,1) = true;
        assignedPoints(direct_botIdx,1) = true;
        assignedPoints(mirror_topIdx,2) = true;
        assignedPoints(mirror_botIdx,2) = true;
        
        matchIdx(1,1) = find(direct_topIdx);
        matchIdx(2,1) = find(direct_botIdx);
        matchIdx(1,2) = find(mirror_topIdx);
        matchIdx(2,2) = find(mirror_botIdx);
end
numMatchedPts = 2;

% find epipole based on these matched points
testLines = zeros(2,3);
linePoints = zeros(2,2);
for ii = 1 : size(testLines,1)
    linePoints(1,:) = squeeze(testMatch(ii,:,1));   % direct view
    linePoints(2,:) = squeeze(testMatch(ii,:,2));   % mirror view
    
    testLines(ii,:) = lineCoeffFromPoints(linePoints);
%     pts = lineToBorderPoints(testLines(ii,:),[h,w]);
%     line(pts([1,3]),pts([2,4]));
end
epiPt = findIntersection(testLines(1,:),testLines(2,:));

for i_directCheck = 1 : num_points

    if assignedPoints(i_directCheck, 1)
        % this point has already been assigned a match
        continue;
    end
    curDirectPt = directChecks(i_directCheck,:);
    % construct a line from the current point to the epipole
    linePoints(1,:) = epiPt;
    linePoints(2,:) = directChecks(i_directCheck,:);
%     testLine = lineCoeffFromPoints(linePoints);
%     pts = lineToBorderPoints(testLine,[h,w]);
%     line(pts([1,3]),pts([2,4]));
    
    % calculate the distance from each mirror point to the line
    distFromLine = NaN(num_points,1);
    for i_mirrorCheck = 1 : num_points
        testMirrorPoint = mirrorChecks(i_mirrorCheck,:);
        distFromLine(i_mirrorCheck) = distanceToLine(curDirectPt, epiPt, testMirrorPoint);
    end
    
    numMatchedPts = numMatchedPts + 1;
    matchIdx(numMatchedPts,1) = i_directCheck;
    
    minDistIdx = find(distFromLine == min(distFromLine));
    matchIdx(numMatchedPts,2) = minDistIdx;
    
end

end
