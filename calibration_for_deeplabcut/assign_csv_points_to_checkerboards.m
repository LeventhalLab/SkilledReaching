function [new_directChecks, new_mirrorChecks] = assign_csv_points_to_checkerboards(directBorderMask, mirrorBorderMask, ROIs, newPoints, anticipatedBoardSize, mirrorOrientation)
%
% INPUTS
%   directBorderMask - h x w x number of checkerboards array where each 
%       h x w plane contains the border of one of the checkerboards in the
%       direct view
%   mirrorBorderMask - same as directBorderMask for mirror views.
%       Assumption is that directBorderMask(:,:,1) is the red (top) border,
%       (:,:2) is the green (left) border, (:,:,3) is the blue (right)
%       border
%   ROIs - regions of interest in which to find the direct view of the
%       cube, and each mirror view in the format [x,y,w,h] where x is the
%       left x-coordinate, y is the top y-coordinate, and w and h are the 
%       width and height, respectively. First row is for direct cube view, 
%       second row top mirror, third row left mirror, fourth row right 
%       mirror
%   newPoints - m x 2 array where each row is an (x,y) pair for a marked
%       point
%
% OUTPUTS
%   new_directChecks, new_mirrorChecks


%     figure(1)
%     imshow(directBorderMask(:,:,1) | directBorderMask(:,:,2) | directBorderMask(:,:,3) | ...
%         mirrorBorderMask(:,:,1) | mirrorBorderMask(:,:,2) | mirrorBorderMask(:,:,3));
%     hold on





num_newPoints = size(newPoints, 1);
numDirectBoards = size(directBorderMask,3);   % this is one binary array instead of the cell structure that holds one array for each different image
new_directChecks = NaN(prod(anticipatedBoardSize-1), 2, numDirectBoards);
numMirrorBoards = size(mirrorBorderMask,3);
new_mirrorChecks = NaN(prod(anticipatedBoardSize-1), 2, numMirrorBoards);

if isempty(newPoints)
    % no new points identified, leave new_directChecks and new_mirrorChecks
    % as all NaN's, which will 
    return;
end

num_newChecks = zeros(max(numDirectBoards,numMirrorBoards), 2); 
% for counting up how many points have been found for each checkerboard for
% indexing purposes
% first column for direct view, second column for mirror views

filledDirectMask = false(size(directBorderMask));
filledMirrorMask = false(size(mirrorBorderMask));
for iBoard = 1 : numDirectBoards
    filledDirectMask(:,:,iBoard) = imfill(directBorderMask(:,:,iBoard),'holes');
end
mirror_ROIpolygons = zeros(4,2,numMirrorBoards);
for iBoard = 1 : numMirrorBoards
    filledMirrorMask(:,:,iBoard) = imfill(mirrorBorderMask(:,:,iBoard),'holes');
    % top left
    mirror_ROIpolygons(1,1,iBoard) = ROIs(iBoard+1,1);
    mirror_ROIpolygons(1,2,iBoard) = ROIs(iBoard+1,2);
    
    % top right
    mirror_ROIpolygons(2,1,iBoard) = ROIs(iBoard+1,1) + ROIs(iBoard+1,3) - 1;
    mirror_ROIpolygons(2,2,iBoard) = ROIs(iBoard+1,2);
    
    % bottom right
    mirror_ROIpolygons(3,1,iBoard) = ROIs(iBoard+1,1) + ROIs(iBoard+1,3) - 1;
    mirror_ROIpolygons(3,2,iBoard) = ROIs(iBoard+1,2) + ROIs(iBoard+1,4) - 1;
    
    % bottom left
    mirror_ROIpolygons(4,1,iBoard) = ROIs(iBoard+1,1);
    mirror_ROIpolygons(4,2,iBoard) = ROIs(iBoard+1,2) + ROIs(iBoard+1,4) - 1;
end

% which directBorderMasks were found?
foundDirectMask = false(1, numDirectBoards);
for iBoard = 1 : numDirectBoards
    tempMask = squeeze(directBorderMask(:,:,iBoard));
    if any(tempMask(:))
        foundDirectMask(iBoard) = true;
    end
end
missingOneDirectMask = false;
if sum(~foundDirectMask) == 1
    % only one direct checkerboard mask wasn't found, so if a point isn't
    % assigned to one of the other masks, it must be this one
    missingOneDirectMask = true;
end
missingDirectMask = find(~foundDirectMask);
for i_pt = 1 : num_newPoints
    
    % is this point enclosed in any of the direct or mirror border masks?
    testPoint = round(newPoints(i_pt,:));
    
    
%     scatter(testPoint(1),testPoint(2))
    
    
    testPoint(testPoint == 0) = 1;   % sometimes the point is right on the edge of the image and gets assigned a zero coordinate
    pointAssigned = false;
    for iBoard = 1 : numDirectBoards
        % recall first index is y, second is x in the masks
        try
            filledDirectMask(testPoint(2),testPoint(1),iBoard);
        catch
            keyboard
        end
        if filledDirectMask(testPoint(2),testPoint(1),iBoard)
            pointAssigned = true;
            num_newChecks(iBoard,1) = num_newChecks(iBoard,1) + 1;
            new_directChecks(num_newChecks(iBoard,1), 1, iBoard) = testPoint(1);
            new_directChecks(num_newChecks(iBoard,1), 2, iBoard) = testPoint(2);
            break;
        end
    end
    if pointAssigned; continue; end
    
    for iBoard = 1 : numMirrorBoards
        if filledMirrorMask(testPoint(2),testPoint(1),iBoard)
            pointAssigned = true;
            num_newChecks(iBoard,2) = num_newChecks(iBoard,2) + 1;
            new_mirrorChecks(num_newChecks(iBoard,2), 1, iBoard) = testPoint(1);
            new_mirrorChecks(num_newChecks(iBoard,2), 2, iBoard) = testPoint(2);
            break;
        end
    end
    if pointAssigned; continue; end
    % point wasn't enclosed in any of the found masks - can we figure out
    % where it is based on its location w.r.t. the borders that were found?

    % mirrors are easy - is it in the relevant ROI?
    for iBoard = 1 : numMirrorBoards
        if inpolygon(testPoint(1),testPoint(2),...
                     squeeze(mirror_ROIpolygons(:,1,iBoard)), squeeze(mirror_ROIpolygons(:,2,iBoard)))
            pointAssigned = true;
            num_newChecks(iBoard,2) = num_newChecks(iBoard,2) + 1;
            new_mirrorChecks(num_newChecks(iBoard,2), 1, iBoard) = testPoint(1);
            new_mirrorChecks(num_newChecks(iBoard,2), 2, iBoard) = testPoint(2);
            break;
        end
    end
    if pointAssigned; continue; end
    
    % point must be in one of the direct view checkerboards for whom the
    % border couldn't be identified
    if missingOneDirectMask
        % point must belong to the one direct mask that wasn't found
        num_newChecks(missingDirectMask,1) = num_newChecks(missingDirectMask,1) + 1;
        new_directChecks(num_newChecks(missingDirectMask,1), 1, missingDirectMask) = testPoint(1);
        new_directChecks(num_newChecks(missingDirectMask,1), 2, missingDirectMask) = testPoint(2);
        continue;
    end
    
    % point belongs to one of two missing direct masks. which one?
    try
    knownMaskString = mirrorOrientation{foundDirectMask};
    catch
        keyboard
    end
    knownMask = squeeze(directBorderMask(:,:,foundDirectMask));
    [y,x] = find(knownMask);
    bot_y = max(y);
    bot_x = x(find(y == bot_y, 1));
    switch knownMaskString
        case 'top'
            % find the lowest point in the top mask. anything to the left
            % of this point should be in the left checkerboard; anything to
            % the right should be in the right checkerboard
            if testPoint(1) < bot_x
                directBoardIdx = find(strcmp(mirrorOrientation,'left'));
            else
                directBoardIdx = find(strcmp(mirrorOrientation,'right'));
            end

        case 'left'
            top_y = min(y);
            top_x = x(find(y == top_y, 1));
            
            topDist = norm(testPoint - [top_x,top_y]);
            botDist = norm(testPoint - [bot_x,bot_y]);
            
            if topDist < botDist
                directBoardIdx = find(strcmp(mirrorOrientation,'top'));
            else
                directBoardIdx = find(strcmp(mirrorOrientation,'right'));
            end

        case 'right'
            top_y = min(y);
            top_x = x(find(y == top_y, 1));
            
            topDist = norm(testPoint - [top_x,top_y]);
            botDist = norm(testPoint - [bot_x,bot_y]);
            
            if topDist < botDist
                directBoardIdx = find(strcmp(mirrorOrientation,'top'));
            else
                directBoardIdx = find(strcmp(mirrorOrientation,'left'));
            end
    end
    num_newChecks(directBoardIdx,1) = num_newChecks(directBoardIdx,1) + 1;
    new_directChecks(num_newChecks(directBoardIdx,1), 1, directBoardIdx) = testPoint(1);
    new_directChecks(num_newChecks(directBoardIdx,1), 2, directBoardIdx) = testPoint(2);
    
end

end