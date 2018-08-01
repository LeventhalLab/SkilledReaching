function [boardPoints] = findDirectCheckerboards(img,directBorderMask,anticipatedBoardSize)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

numBoards = size(directBorderMask,3);
img_gray = rgb2gray(img);

gradientThresh = 0.1;
h = size(img,1);
w = size(img,2);
for iBoard = 1 : numBoards
    
    curBoardMask = imfill(directBorderMask(:,:,iBoard),'holes') & ~directBorderMask(:,:,iBoard);
    curBoardImg = img .* repmat(uint8(curBoardMask),1,1,3);
    
    foundValidPoints = false;
    while ~foundValidPoints
        [imagePoints,boardSize] = detectCheckerboardPoints(curBoardImg);
    
        % check that these are valid image points
        % first, does boardSize match anticipatedBoardSize?
        if ~(all(anticipatedBoardSize == boardSize) || ...
             all(anticipatedBoardSize == fliplr(boardSize)))
            % anticipatedBoardSize does NOT match boardSize
            
            % do something here to update how it will look for checkerboard
            % points
            continue;
        end
        
        % boardSize matches anticipatedBoardSize, so now figure out if
        % they're appropriately spaced/in about the right position relative
        % to the borders
        
        % find the convex hull of the identified checkerboard points
        cvHull = convhull(imagePoints(:,1),imagePoints(:,2));
        hullMask = poly2mask(imagePoints(cvHull,1),imagePoints(cvHull,2),h,w);
        
        % now check to see if the convex hull of the checkerboard points is
        % more or less evenly spaced from the inner edge of the border
        
    end
            
    
    figure;imshow(curBoardImg);
    hold on
    scatter(imagePoints(:,1),imagePoints(:,2));
    
    validPix = curBoardMask(:);
    curBoardImg = img .* repmat(uint8(curBoardMask),1,1,3);
    
    checkPix = img_gray(validPix);
    checkThresh = graythresh(checkPix);
    
    whiteChecks = (double(img_gray)/255 > checkThresh) & curBoardMask;
    blackChecks = (double(img_gray)/255 < checkThresh) & curBoardMask;
    
    checkGradient = gradientweight(img_gray) .* double(curBoardMask);
    checkBorders = (checkGradient < gradientThresh) & curBoardMask;
    
    whiteChecks = whiteChecks & ~checkBorders;
    blackChecks = blackChecks & ~checkBorders;
    
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

