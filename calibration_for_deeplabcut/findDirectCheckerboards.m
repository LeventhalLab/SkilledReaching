function [directBoardPoints,foundValidPoints] = findDirectCheckerboards(img,directBorderMask,anticipatedBoardSize)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% INPUTS
%   img - full calibration image
%   directBorderMask - 
%   anticipatedBoardSize - 2 x 1 vector containing the anticipated
%       checkerboard size INCLUDING the outer edge (recall that
%       detectCheckerboardPoints will find the interior points but returns
%       boardSize that includes the outer edge)
% OUTPUTS

% hullOverlapThresh = 0.8;
minCornerStep = 0.01;
minCornerMetric = 0.15;   % algorithm default
maxDetectAttempts = 10;
minCheckerboardFract = prod(anticipatedBoardSize-2)/prod(anticipatedBoardSize) - 0.05;%0.25;
% assuming all checks are the same size, the ratio of the area of the
% detected board (which excludes the outer checks)

% strelSize = 15;

numBoards = size(directBorderMask,3);
% img_gray = rgb2gray(img);

% gradientThresh = 0.1;
h = size(img,1);
w = size(img,2);
foundValidPoints = false(1,numBoards);
directBoardPoints = NaN(prod(anticipatedBoardSize-1), 2, numBoards);
for iBoard = 1 : numBoards
    
    curBoardMask = imfill(directBorderMask(:,:,iBoard),'holes') & ~directBorderMask(:,:,iBoard);
%     curBoardMask = imclose(curBoardMask,strel('disk',strelSize));
%     curBoardMask = imopen(curBoardMask,strel('disk',strelSize));
    
    numBoardMaskPoints = sum(curBoardMask(:));
    
    curBoardImg = img .* repmat(uint8(curBoardMask),1,1,3);
    
    numCheckDetectAttempts = 0;
    while ~foundValidPoints(iBoard) && (numCheckDetectAttempts <= maxDetectAttempts)
%         [boardPoints,boardSize] = detectCheckerboardPoints(curBoardImg,...
%             'mincornermetric',minCornerMetric);
        [boardPoints,boardSize] = detectCheckerboardPoints(curBoardImg,'mincornermetric',minCornerMetric);
        
        figure(4)
        imshow(img);
        hold on
        scatter(boardPoints(:,1),boardPoints(:,2));
    
        % check that these are valid image points
        % first, does boardSize match anticipatedBoardSize?
        if ~(all(anticipatedBoardSize == boardSize) || ...
             all(anticipatedBoardSize == fliplr(boardSize)))
            % anticipatedBoardSize does NOT match boardSize
            
            % adjust so the algorithm is more or less sensitive as needed            
            if prod(boardSize) > prod(anticipatedBoardSize)
                % detected too many points
                minCornerMetric = minCornerMetric - minCornerStep;
            else
                minCornerMetric = minCornerMetric + minCornerStep;
            end
            numCheckDetectAttempts = numCheckDetectAttempts + 1;
            continue;
        end
        
        % boardSize matches anticipatedBoardSize, so now figure out if
        % they're appropriately spaced/in about the right position relative
        % to the borders
        
        % find the convex hull of the identified checkerboard points
        cvHull = convhull(boardPoints(:,1),boardPoints(:,2));
        hullMask = poly2mask(boardPoints(cvHull,1),boardPoints(cvHull,2),h,w);
        
        % check that hullMask is contained entirely within curBoardMask
        testMask = curBoardMask & ~hullMask;
        testStat = regionprops(testMask,'eulernumber');
        
        % euler number should be 0
        if testStat.EulerNumber ~= 0
            minCornerMetric = minCornerMetric - minCornerStep;
            numCheckDetectAttempts = numCheckDetectAttempts + 1;
            continue;
        end
        
        hullSize = sum(hullMask(:));
        
%         smoothedHull = imclose(hullMask,strel('disk',strelSize));
%         smoothedHull = imopen(smoothedHull,strel('disk',strelSize));
        % now check to see if the convex hull of the checkerboard points is
        % more or less evenly spaced from the inner edge of the border
%         thickenedHull = thickenToEdge(smoothedHull, curBoardMask);
        
        % "thickenedHull" should closely match with curBoardMask if the
        % convex hull of checkerboard points is evenly spaced from the
        % inner edge of the border
%         testMask = thickenedHull & curBoardMask;
%         numOverlapPoints = sum(testMask(:));
        
        testRatio = hullSize / numBoardMaskPoints;
        % assuming all checks are the same size, should be 
        
        if testRatio < minCheckerboardFract
            % try increasing mincornermetric - too many false positives?
            minCornerMetric = minCornerMetric + minCornerStep;
            numCheckDetectAttempts = numCheckDetectAttempts + 1;
            continue;
        end
        
        foundValidPoints(iBoard) = true;
        
    end
            
    if foundValidPoints(iBoard)
        directBoardPoints(:,:,iBoard) = boardPoints;
    else
        keyboard
    end
end

end

