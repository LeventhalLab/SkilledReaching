function [boardPoints,foundValidPoints] = findDirectCheckerboards(img,directBorderMask,anticipatedBoardSize)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% INPUTS
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
        [boardPoints,boardSize] = detectCheckerboardPoints(curBoardImg);
    
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
            
%     
%     figure(1);imshow(curBoardImg);
%     hold on
%     scatter(boardPoints(:,1),boardPoints(:,2));
%     
%     validPix = curBoardMask(:);
%     curBoardImg = img .* repmat(uint8(curBoardMask),1,1,3);
%     
%     checkPix = img_gray(validPix);
%     checkThresh = graythresh(checkPix);
%     
%     whiteChecks = (double(img_gray)/255 > checkThresh) & curBoardMask;
%     blackChecks = (double(img_gray)/255 < checkThresh) & curBoardMask;
%     
%     checkGradient = gradientweight(img_gray) .* double(curBoardMask);
%     checkBorders = (checkGradient < gradientThresh) & curBoardMask;
%     
%     whiteChecks = whiteChecks & ~checkBorders;
%     blackChecks = blackChecks & ~checkBorders;
    
end
% boardPoints = zeros(prod(anticipatedBoardSize-1),2,numBoards);
% for iBoard = 1 : numBoards
%     
%     boardAndBorderMask = imfill(directBorderMask(:,:,iBoard),'holes');
%     curBoardMask = boardAndBorderMask & ~directBorderMask(:,:,iBoard);
%     validPix = curBoardMask(:);
%     curBoardImg = img .* repmat(uint8(curBoardMask),1,1,3);
%     
%     boardPoints(:,:,iBoard) = detectDirectCalibrationPoints(curBoardImg, curBoardMask, anticipatedBoardSize);
%     
% %     checkPix = img_gray(validPix);
% %     checkThresh = graythresh(checkPix);
% %     
% %     whiteChecks = (double(img_gray)/255 > checkThresh) & curBoardMask;
% %     blackChecks = (double(img_gray)/255 < checkThresh) & curBoardMask;
% %     
% %     checkGradient = gradientweight(img_gray) .* double(curBoardMask);
% %     checkBorders = (checkGradient < gradientThresh) & curBoardMask;
% %     
% %     whiteChecks = whiteChecks & ~checkBorders;
% %     blackChecks = blackChecks & ~checkBorders;
%     
% end

end

