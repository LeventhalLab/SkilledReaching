function mirrorChecks = findMirrorCheckerboards(img, directBorderMask, directBorderChecks, mirror_hsvThresh, anticipatedBoardSize, ROIs, cameraParams)
%
% INPUTS:
%   cameraParams - camera parameters structure

minCornerStep = 0.01;
minCornerMetric = 0.15;   % algorithm default
maxDetectAttempts = 10;

diffThresh = 0.1;
threshStepSize = 0.01;

SEsize = 3;
SE = strel('disk',SEsize);
minCheckerboardArea = 5000;
maxCheckerboardArea = 20000;

h = size(img,1);
w = size(img,2);

img_stretch = decorrstretch(img);
% figure(1); imshow(img_stretch);
img_hsv = rgb2hsv(img_stretch);

numBoards = size(directBorderMask,3);

initSeedMasks = false(h,w,3);
denoisedMasks = false(h,w,3);
meanHSV = zeros(3,2,3);    % 3 colors by 2 regions by 3 values
stdHSV = zeros(3,2,3);

imgMask = false(h,w,3);
foundValidPoints = false(1,numBoards);
mirrorBoardPoints = NaN(prod(anticipatedBoardSize-1), 2, numBoards);
for iBoard = 1 : numBoards

    mirrorMask = false(h,w);
    mirrorMask(ROIs(iBoard+1,2):ROIs(iBoard+1,2)+ROIs(iBoard+1,4)-1, ...
               ROIs(iBoard+1,1):ROIs(iBoard+1,1)+ROIs(iBoard+1,3)-1) = true;
    mirrorView_hsv = img_hsv .* repmat(double(mirrorMask),1,1,3);
    
    initSeedMasks(:,:,iBoard) = HSVthreshold(img_hsv, mirror_hsvThresh(iBoard,:)) & mirrorMask;
    denoisedMasks(:,:,iBoard) = imopen(squeeze(initSeedMasks(:,:,iBoard)), SE);
    denoisedMasks(:,:,iBoard) = imclose(squeeze(denoisedMasks(:,:,iBoard)), SE);
    
    mirrorBorderMask = squeeze(denoisedMasks(:,:,iBoard));
    [meanHSV(iBoard,1,:),stdHSV(iBoard,1,:)] = calcHSVstats(img_hsv, mirrorBorderMask);
    
    mirrorView_hsvDist = calcHSVdist(mirrorView_hsv, squeeze(meanHSV(iBoard,1,:)));
    
    mirrorViewGray = mean(mirrorView_hsvDist(:,:,1:2),3);
    
    currentThresh = diffThresh;
    foundValidBorder = false;
    while ~foundValidBorder
        mirrorBorder = mirrorViewGray < currentThresh;
        mirrorBorder = imopen(mirrorBorder, SE);
        mirrorBorder = imclose(mirrorBorder, SE);
        
        L = bwlabel(mirrorBorder);
        if ~any(L(:))   % if nothing detected
            currentThresh = currentThresh + threshStepSize;
            continue;
        end
        
        for iObj = 1 : max(L(:))
            regionstats = regionprops(L == iObj,'euler');
            if regionstats.EulerNumber == 0   % a candidate border - there is one hole
                mirrorBorder_filled = imfill(mirrorBorder,'holes');
                testImg = mirrorBorder_filled & ~mirrorBorder;   % where the checkerboard should be
                teststats = regionprops(testImg,'area');
                A = teststats.Area;
                
                if A > minCheckerboardArea && A < maxCheckerboardArea
                    foundValidBorder = true;
                    mirrorBorder = (L == iObj);
                    break;
                end
            end
        end
        currentThresh = currentThresh + threshStepSize;

    end
    
    % now find the checkerboard
    curBoardMask = imfill(mirrorBorder,'holes');
	curBoardImg = img .* repmat(uint8(curBoardMask),1,1,3);
    numCheckDetectAttempts = 0;
    number_of_points_match = false;
    while ~number_of_points_match && (numCheckDetectAttempts <= maxDetectAttempts)
%         [boardPoints,boardSize] = detectCheckerboardPoints(curBoardImg,...
%             'mincornermetric',minCornerMetric);
        [boardPoints,boardSize] = detectCheckerboardPoints(curBoardImg);
    
        % check that these are valid image points
        % does boardSize match anticipatedBoardSize?
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
        
        number_of_points_match = true;
        
    end
    if ~number_of_points_match
        continue
    end
    
    % match the found points with direct checkerboard points (if found)
    direct_undistorted = undistortPoints(squeeze(directBorderChecks(:,:,iBoard)),cameraParams);
    mirror_undistorted = undistortPoints(boardPoints,cameraParams);
    
    switch iBoard
        case 1
            mirrorView = 'top';
        case 2
            mirrorView = 'left';
        case 3
            mirrorView = 'right';
    end
    initMatchIdx = findInitMatches(direct_undistorted, mirror_undistorted, mirrorView);
    matchedPoints = matchMirrorPointsFromInitMatch(direct_undistorted, mirror_undistorted, initMatchIdx);
    
    % WORKING HERE...
    
    
    
    if foundValidPoints(iBoard)
        mirrorBoardPoints(:,:,iBoard) = boardPoints;
    end
end


end