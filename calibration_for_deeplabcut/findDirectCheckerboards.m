<<<<<<< HEAD
function [boardPoints] = findDirectCheckerboards(img,directBorderMask,boardSize)
=======
function [boardPoints] = findDirectCheckerboards(img,directBorderMask,anticipatedBoardSize)
>>>>>>> 363fc4784b2116b41dc66594009feea8f6b6fff5
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

numBoards = size(directBorderMask,3);
img_gray = rgb2gray(img);

gradientThresh = 0.1;
<<<<<<< HEAD

for iBoard = 1 : numBoards
    
    curBoardMask = imfill(directBorderMask(:,:,iBoard),'holes') & ~directBorderMask(:,:,iBoard);
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
=======
boardPoints = zeros(prod(anticipatedBoardSize-1),2,numBoards);
for iBoard = 1 : numBoards
    
    boardAndBorderMask = imfill(directBorderMask(:,:,iBoard),'holes');
    curBoardMask = boardAndBorderMask & ~directBorderMask(:,:,iBoard);
    validPix = curBoardMask(:);
    curBoardImg = img .* repmat(uint8(curBoardMask),1,1,3);
    
    boardPoints(:,:,iBoard) = detectDirectCalibrationPoints(curBoardImg, curBoardMask, anticipatedBoardSize);
    
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
>>>>>>> 363fc4784b2116b41dc66594009feea8f6b6fff5
    
end

end

