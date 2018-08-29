function matchIdx = matchCheckerboardPoints(directChecks, mirrorChecks)
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

mirror_maxDistFromLine = 2;   % if a point is farther than this from an epipolar line, it can't be considered a match
direct_maxDistFromLine = 2;   % if a point is farther than this from an epipolar line, it can't be considered a match

num_points = size(mirrorChecks,1);
if num_points ~= size(directChecks,1)
    error('directChecks and mirrorChecks must have the same number of rows')
end

matchIdx = zeros(num_points,2);
% testMatch = zeros(num_points,2,2);
% assignedPoints = false(num_points, 2);
% if the top mirror, the left- and right-most points should match up
% if the left/right mirror, the top- and bottom-most points should match up
remaining_directChecks = directChecks;
remaining_mirrorChecks = mirrorChecks;
numMatches = 0;
while ~isempty(remaining_directChecks)
    supporting_lines = supportingLines(remaining_directChecks, remaining_mirrorChecks);
    
    for iLine = 1 : 2
        testPt1 = squeeze(supporting_lines(1,:,iLine));
        testPt2 = squeeze(supporting_lines(2,:,iLine));
        dirRow = find(findMatchingRows(testPt1, directChecks));
        if isempty(dirRow)
            mirRow = find(findMatchingRows(testPt1, mirrorChecks));
            dirRow = find(findMatchingRows(testPt2, directChecks));
            
            remaining_mirRow = find(findMatchingRows(testPt1, remaining_mirrorChecks));
            remaining_dirRow = find(findMatchingRows(testPt2, remaining_directChecks));
        else
            mirRow = find(findMatchingRows(testPt2, mirrorChecks));
            
            remaining_mirRow = find(findMatchingRows(testPt2, remaining_mirrorChecks));
            remaining_dirRow = find(findMatchingRows(testPt1, remaining_directChecks));
        end
        
        % have potential matches - is it possible that there is a better
        % match that lies along the same line (hidden by noise in how
        % accurately the points are marked?)
        num_remaining_points = size(remaining_directChecks,1);
        mirror_distFromLine = NaN(num_remaining_points,1);
        direct_distFromLine = NaN(num_remaining_points,1);
        for i_check = 1 : num_remaining_points
            testMirrorPoint = remaining_mirrorChecks(i_check,:);
            testDirectPoint = remaining_directChecks(i_check,:);
            mirror_distFromLine(i_check) = distanceToLine(testPt1, testPt2, testMirrorPoint);
            direct_distFromLine(i_check) = distanceToLine(testPt1, testPt2, testDirectPoint);
        end
        
        mirror_candidates = find(mirror_distFromLine < mirror_maxDistFromLine);
        direct_candidates = find(direct_distFromLine < direct_maxDistFromLine);
        
        if length(mirror_candidates) ~= length(direct_candidates) || ...
           length(mirror_candidates) == 1
            numMatches = numMatches + 1;

            matchIdx(numMatches,1) = dirRow;
            matchIdx(numMatches,2) = mirRow;

            remaining_directChecks = removeRow(remaining_directChecks, remaining_dirRow);
            remaining_mirrorChecks = removeRow(remaining_mirrorChecks, remaining_mirRow);
            continue;
        end
        
        % have multiple candidate matches along this supporting line
        mirrorDirectDistance = zeros(length(mirror_candidates));
        for i_dirPt = 1 : length(mirror_candidates)
            for i_mirPt = 1 : length(mirror_candidates)
                mirrorDirectDistance(i_dirPt,i_mirPt) = ...
                    norm(remaining_directChecks(direct_candidates(i_dirPt),:) - ...
                         remaining_mirrorChecks(mirror_candidates(i_mirPt),:));
            end
        end
        direct_rows_to_remove = zeros(1,length(mirror_candidates));
        mirror_rows_to_remove = zeros(1,length(mirror_candidates));
        for iMatch = 1 : length(mirror_candidates)
            % which direct/mirror points are closest together? (they're a match
            % due to mirror symmetry). Then second closest, third closest, etc.
            [m,n] = find(mirrorDirectDistance == min(min(mirrorDirectDistance)));

            numMatches = numMatches + 1;
            % find direct and mirror point indices from original array
            curDirPt = remaining_directChecks(direct_candidates(m),:);
            curMirPt = remaining_mirrorChecks(mirror_candidates(n),:);
            
            dirRow = find(findMatchingRows(curDirPt, directChecks));
            mirRow = find(findMatchingRows(curMirPt, mirrorChecks));
            
            matchIdx(numMatches,1) = dirRow;
            matchIdx(numMatches,2) = mirRow;

            % eliminate points that have already been assigned a match from the
            % distance/index matrices
            direct_rows_to_remove(iMatch) = direct_candidates(m);
            mirror_rows_to_remove(iMatch) = mirror_candidates(n);
            
            % can't pull the rows out from these arrays yet or it messes up
            % the curDirPt and curMirPt assignments above
%             remaining_directChecks = removeRow(remaining_directChecks, direct_candidates(m));
%             remaining_mirrorChecks = removeRow(remaining_mirrorChecks, mirror_candidates(n));
            
            keepRows = true(size(mirrorDirectDistance,1),1);
            keepRows(m) = false;
            keepCols = true(1,size(mirrorDirectDistance,2));
            keepCols(n) = false;
            direct_candidates = direct_candidates(keepRows);
            mirror_candidates = mirror_candidates(keepCols);

            mirrorDirectDistance = mirrorDirectDistance(keepRows,:);
            mirrorDirectDistance = mirrorDirectDistance(:, keepCols);
        end
        remaining_directChecks = removeRow(remaining_directChecks, direct_rows_to_remove);
        remaining_mirrorChecks = removeRow(remaining_mirrorChecks, mirror_rows_to_remove);
    end
end
%     
% 
% % find epipole based on these supporting lines
% testLines = zeros(2,3);
% for ii = 1 : size(testLines,1)
% %     linePoints(1,:) = squeeze(testMatch(ii,:,1));   % direct view
% %     linePoints(2,:) = squeeze(testMatch(ii,:,2));   % mirror view
%     
%     testLines(ii,:) = lineCoeffFromPoints(squeeze(supporting_lines(:,:,ii)));
% %     pts = lineToBorderPoints(testLines(ii,:),[h,w]);
% %     line(pts([1,3]),pts([2,4]));
% end
% epiPt = findIntersection(testLines(1,:),testLines(2,:));
% 
% % switch mirrorOrientation
% % 
% %     case 'top'
% %         direct_ltIdx = directChecks(:,1) == min(directChecks(:,1));
% %         direct_rtIdx = directChecks(:,1) == max(directChecks(:,1));
% %         mirror_ltIdx = mirrorChecks(:,1) == min(mirrorChecks(:,1));
% %         mirror_rtIdx = mirrorChecks(:,1) == max(mirrorChecks(:,1));
% %         
% %         try
% %         testMatch(1,:,1) = directChecks(direct_ltIdx,:);
% %         catch
% %             keyboard
% %         end
% %         testMatch(2,:,1) = directChecks(direct_rtIdx,:);
% %         testMatch(1,:,2) = mirrorChecks(mirror_ltIdx,:);
% %         testMatch(2,:,2) = mirrorChecks(mirror_rtIdx,:);
% %         
% %         assignedPoints(direct_ltIdx,1) = true;
% %         assignedPoints(direct_rtIdx,1) = true;
% %         assignedPoints(mirror_ltIdx,2) = true;
% %         assignedPoints(mirror_rtIdx,2) = true;
% %         
% %         matchIdx(1,1) = find(direct_ltIdx);
% %         matchIdx(2,1) = find(direct_rtIdx);
% %         matchIdx(1,2) = find(mirror_ltIdx);
% %         matchIdx(2,2) = find(mirror_rtIdx);
% %     case {'left','right'}
% %         direct_topIdx = directChecks(:,2) == min(directChecks(:,2));
% %         direct_botIdx = directChecks(:,2) == max(directChecks(:,2));
% %         mirror_topIdx = mirrorChecks(:,2) == min(mirrorChecks(:,2));
% %         mirror_botIdx = mirrorChecks(:,2) == max(mirrorChecks(:,2));
% %         
% %         testMatch(1,:,1) = directChecks(direct_topIdx,:);
% %         testMatch(2,:,1) = directChecks(direct_botIdx,:);
% %         testMatch(1,:,2) = mirrorChecks(mirror_topIdx,:);
% %         testMatch(2,:,2) = mirrorChecks(mirror_botIdx,:);
% %         
% %         assignedPoints(direct_topIdx,1) = true;
% %         assignedPoints(direct_botIdx,1) = true;
% %         assignedPoints(mirror_topIdx,2) = true;
% %         assignedPoints(mirror_botIdx,2) = true;
% %         
% %         matchIdx(1,1) = find(direct_topIdx);
% %         matchIdx(2,1) = find(direct_botIdx);
% %         matchIdx(1,2) = find(mirror_topIdx);
% %         matchIdx(2,2) = find(mirror_botIdx);
% % end
% % numMatchedPts = 2;
% % 
% % % find epipole based on these matched points
% % testLines = zeros(2,3);
% % linePoints = zeros(2,2);
% % for ii = 1 : size(testLines,1)
% %     linePoints(1,:) = squeeze(testMatch(ii,:,1));   % direct view
% %     linePoints(2,:) = squeeze(testMatch(ii,:,2));   % mirror view
% %     
% %     testLines(ii,:) = lineCoeffFromPoints(linePoints);
% % %     pts = lineToBorderPoints(testLines(ii,:),[h,w]);
% % %     line(pts([1,3]),pts([2,4]));
% % end
% % epiPt = findIntersection(testLines(1,:),testLines(2,:));
% 
% numMatchedPts = 0;
% for i_directCheck = 1 : num_points
% 
%     if assignedPoints(i_directCheck, 1)
%         % this point has already been assigned a match
%         continue;
%     end
%     curDirectPt = directChecks(i_directCheck,:);
%     % construct a line from the current point to the epipole
%     linePoints(1,:) = epiPt;
%     linePoints(2,:) = directChecks(i_directCheck,:);
% %     testLine = lineCoeffFromPoints(linePoints);
% %     pts = lineToBorderPoints(testLine,[h,w]);
% %     line(pts([1,3]),pts([2,4]));
%     
%     % calculate the distance from each mirror point to the line
%     mirror_distFromLine = NaN(num_points,1);
%     direct_distFromLine = NaN(num_points,1);
%     for i_check = 1 : num_points
%         testMirrorPoint = mirrorChecks(i_check,:);
%         testDirectPoint = directChecks(i_check,:);
%         mirror_distFromLine(i_check) = distanceToLine(curDirectPt, epiPt, testMirrorPoint);
%         direct_distFromLine(i_check) = distanceToLine(curDirectPt, epiPt, testDirectPoint);
%     end
%     
%     % find all candidate direct and mirror points to lie on this epipolar
%     % line
%     mirror_pt_idx = find(mirror_distFromLine < mirror_maxDistFromLine);
%     direct_pt_idx = find(direct_distFromLine < direct_maxDistFromLine);
%     
%     if (length(mirror_pt_idx) ~= length(direct_pt_idx)) || ...
%             isempty(mirror_pt_idx) || ...
%             length(mirror_pt_idx) == 1
%         % didn't find the same number of potential matches in both views or
%         % didn't find any potential matches or there was only one potential
%         % match. Take the closest point to the line and hope for the best
%         minDistIdx = find(mirror_distFromLine == min(mirror_distFromLine));
%         numMatchedPts = numMatchedPts + 1;
%         matchIdx(numMatchedPts,1) = i_directCheck;
%         matchIdx(numMatchedPts,2) = minDistIdx;
%         assignedPoints(i_directCheck, 1) = true;
%         assignedPoints(minDistIdx, 2) = true;
%         continue;
%     end
%     numPossMatches = length(mirror_pt_idx);
%     mirrorDirectDistance = zeros(numPossMatches);
%     for i_dirPt = 1 : numPossMatches
%         for i_mirPt = 1 : numPossMatches
%             mirrorDirectDistance(i_dirPt,i_mirPt) = norm(directChecks(direct_pt_idx(i_dirPt),:) - mirrorChecks(mirror_pt_idx(i_mirPt),:));
%         end
%     end
%     for iMatch = 1 : numPossMatches
%         % which direct/mirror points are closest together? (they're a match
%         % due to mirror symmetry). Then second closest, third closest, etc.
%         [m,n] = find(mirrorDirectDistance == min(min(mirrorDirectDistance)));
%         if ~assignedPoints(direct_pt_idx(m))
%             % make sure this point hasn't already been assigned a match
%             numMatchedPts = numMatchedPts + 1;
%             matchIdx(numMatchedPts,1) = direct_pt_idx(m);
%             matchIdx(numMatchedPts,2) = mirror_pt_idx(n);
%             assignedPoints(direct_pt_idx(m), 1) = true;
%             assignedPoints(mirror_pt_idx(n), 2) = true;
%         end
%         
%         % eliminate points that have already been assigned a match from the
%         % distance/index matrices
%         keepRows = true(size(mirrorDirectDistance,1),1);
%         keepRows(m) = false;
%         keepCols = true(1,size(mirrorDirectDistance,2));
%         keepCols(n) = false;
%         direct_pt_idx = direct_pt_idx(keepRows);
%         mirror_pt_idx = mirror_pt_idx(keepCols);
%         
%         mirrorDirectDistance = mirrorDirectDistance(keepRows,:);
%         mirrorDirectDistance = mirrorDirectDistance(:, keepCols);
%     end
%         
%         
%         
%         
% %     numMatchedPts = numMatchedPts + 1;
% %     matchIdx(numMatchedPts,1) = i_directCheck;
% %     
% %     minDistIdx = find(mirror_distFromLine == min(mirror_distFromLine));
% %     matchIdx(numMatchedPts,2) = minDistIdx;
%     
% end
% 
% end
