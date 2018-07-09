function [boardPoints] = findDirectCheckerboards(img,directBorderMask,anticipatedBoardSize)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

numBoards = size(directBorderMask,3);
img_gray = rgb2gray(img);

gradientThresh = 0.1;
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
    
end

end

