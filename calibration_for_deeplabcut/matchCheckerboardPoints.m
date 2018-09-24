function matchIdx = matchCheckerboardPoints(directChecks, mirrorChecks)
%
% function to match checkerboard points in the direct and mirror views.
% 
% INPUTS:
%   directChecks, mirrorChecks - m x 2 arrays containing the checkerboard
%       points
%   mirrorOrientation - cell array containing the strings "top", "left", or
%       "right"
%
% OUTPUTS:
%   matchIdx - 


%%%%%%%%%%take out these lines later - for debugging
% h=1024;
% w=2040;
%%%%%%%%%%take out these lines later - for debugging

mirror_maxDistFromLine = 3;   % if a point is farther than this from an epipolar line, it can't be considered a match
direct_maxDistFromLine = 5;   % if a point is farther than this from an epipolar line, it can't be considered a match

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
    
    if size(remaining_directChecks,1) == 1
        % only one point left
        numMatches = numMatches + 1;
        mirRow = find(findMatchingRows(remaining_mirrorChecks, mirrorChecks));
        dirRow = find(findMatchingRows(remaining_directChecks, directChecks));
        
        matchIdx(numMatches,1) = dirRow;
        matchIdx(numMatches,2) = mirRow;
        
        remaining_directChecks = [];
        remaining_mirrorChecks = [];
        
        continue;
    end
            
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
