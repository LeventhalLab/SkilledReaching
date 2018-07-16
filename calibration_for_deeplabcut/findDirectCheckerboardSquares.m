function [whiteMask, blackMask, errorFlag] = findDirectCheckerboardSquares(img, borderMask, anticipatedBoardSize, varargin)
% threshStep = 0.02;
% curWhiteThresh = 0.5;
% curBlackThresh = 0.5;
% maxIterations = 20;

errorFlag = false;

gradientThresh = 0.4;
minSolidity = 0.85;
minArea = 50;
maxArea = 500;
for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'minarea'
            minArea = varargin{iarg + 1};
        case 'minsolidity'
            minSolidity = varargin{iarg + 1};
        case 'threshstep'
            threshStep = varargin{iarg + 1};
    end
end
num_antic_regions = prod(anticipatedBoardSize) / 2;

openSize = 1;
for iView = 1 : 3
    curBorderMask = squeeze(borderMask(:,:,iView));
    curBoardMask = imfill(curBorderMask,'holes') & ~curBorderMask;
    testGray = rgb2gray(img) .* uint8(curBoardMask);
    q = gradientweight(testGray) .* double(curBoardMask);
    
    interChecks = q < gradientThresh & curBoardMask;
    q_adj = imadjust(q);
    q_masked = q_adj .* double(curBoardMask);
    r = q_masked > gradientThresh;
    
    checkProps = [];

    while numel(checkProps) ~= prod(anticipatedBoardSize)
        r_open = imopen(r,strel('square',openSize));
        checkProps = regionprops(r_open,'Centroid','Area');
        openSize = openSize + 1;
    end
    
    r_inv = ~r_open & curBoardMask;
    

    
end


erodeSize = 0;
seedMap = false(size(r));
numValidRegions = 0;
tooManyErosions = false;
while numValidRegions ~= prod(anticipatedBoardSize)
    s=imerode(r,strel('disk',erodeSize));
    s = s & ~interChecks;
    s = imclose(s,strel('disk',2));
    s = imopen(s,strel('disk',2));
    checkProps = regionprops(s,'solidity','area');
    numRegions = length(checkProps);
    
    L = bwlabel(s);
    foundNewSeed = false;
    for iRegion = 1 : numRegions
        if checkProps(iRegion).Area > minArea && ...
                checkProps(iRegion).Area < maxArea && ...
                checkProps(iRegion).Solidity > minSolidity
            seedMap = seedMap | L == iRegion;
            
            % may have to make sure seedmap doesn't have connected regions
            % from previous seedmap...
            
            foundNewSeed = true;
        end
    end
    
    % eliminate this seed region from where we're looking (and surrounding
    % area to clean up potential noise)
    r = r & ~imdilate(seedMap,strel('disk',4));
    r = imopen(r,strel('disk',1));
    r = imclose(r,strel('disk',1));
    
    
    
    % WHAT IF THIS LEADS TO CONNECTED REGIONS BEING FOUND BY ELIMINATING
    % PREVIOUSLY FOUND REGIONS?
    seed_L = bwlabel(seedMap);
    numValidRegions = max(seed_L(:));
    if ~foundNewSeed
        % only increase the erosion size if we didn't find any new seeds on
        % the last run
        erodeSize = erodeSize + 1;
    end
    if erodeSize > 5
        tooManyErosions = true;
        break;
    end
end

seedMap_smoothed = imopen(seedMap,strel('disk',2));
seedMap_smoothed = imclose(seedMap_smoothed,strel('disk',2));

L = bwlabel(seedMap_smoothed);
numChecks = max(L(:));
if numChecks > prod(anticipatedBoardSize)
    % pull out the 20 largest blobs
    check_A = regionprops(L>0,'area');
    A = [check_A.Area];
    [~,idx] = sort(A,'descend');
    seedMap_smoothed = false(size(seedMap));
    for iCheck = 1 : prod(anticipatedBoardSize)
        seedMap_smoothed = seedMap_smoothed | L==idx(iCheck);
    end
end

whiteMask = false(size(testGray));
blackMask = false(size(testGray));
validCheckIntensities = testGray .* double(seedMap_smoothed);
validCheckIntensities = validCheckIntensities(:);
validCheckIntensities = validCheckIntensities(seedMap_smoothed(:));
testThresh = graythresh(validCheckIntensities);
L = bwlabel(seedMap_smoothed);
for iCheck = 1 : max(L(:))
    % count pixels in this check with intensities above and below testThresh
    checkIntensities = testGray .* double(L==iCheck);
    whitePix = checkIntensities > testThresh & L==iCheck;
    blackPix = checkIntensities < testThresh & L==iCheck;
    
    if sum(whitePix(:)) > sum(blackPix(:))   % if more white than black pixels
        whiteMask = whiteMask | L==iCheck;
    else
        blackMask = blackMask | L==iCheck;
    end
end
% whiteMask = imbinarize(testGray .* double(seedMap_smoothed));
% blackMask = imbinarize((1-testGray) .* double(seedMap_smoothed));

% figure(1);imshow(whiteMask)
% figure(2);imshow(blackMask)
% what if we went through too many erosions? One of the checks didn't
% quite meet criteria to stay...
if tooManyErosions
    errorFlag = true;
%     new_q = q .* double(~imdilate(seedMap,strel('disk',4)) & boardMask);
%     newSeed = imbinarize(new_q);
%     newSeed = imclose(newSeed,strel('disk',3));
%     newSeed = imopen(newSeed,strel('disk',3));
%     
%     oldSeepProps = regionprops(seedMap,'solidity','area','centroid');
%     newSeedProps = regionprops(newSeed,'solidity','area','centroid');
    
    
end
% z = bwmorph(seedMap,'shrink',3);
% t = imsegfmm(q_masked,z,0.5);
% figure(1);imshow(z)
% figure(2);imshow(t)
% while (num_white_regions ~= num_antic_regions || num_black_regions ~= num_antic_regions) && numIterations <= maxIterations
%     numIterations = numIterations + 1;
%     
%     white_checks = testGray > curWhiteThresh;
%     black_checks = testGray < curBlackThresh;
%     
%     interChecks = imopen(interChecks,strel('disk',1));
%     interChecks = imclose(interChecks,strel('disk',1));
%     
%     white_checks = white_checks & boardMask;
%     white_checks = white_checks & ~interChecks;
% %     white_checks = imclose(white_checks,strel('disk',2));
% %     white_checks = imopen(white_checks,strel('disk',2));
% %     white_checks = imerode(white_checks,strel('disk',5));
% 
%     
%     black_checks = black_checks & boardMask;
%     black_checks = black_checks & ~interChecks;
% %     black_checks = imclose(black_checks,strel('disk',2));
% %     black_checks = imopen(black_checks,strel('disk',2));
% %     black_checks = imerode(black_checks,strel('disk',5));
%     
%     L_white = bwlabel(white_checks);
%     L_black = bwlabel(black_checks);
%     
%     % store any checks that already meet criteria for later
%     checkProps = regionprops(white_checks,'solidity','area');
%     num_white_regions = length(checkProps);
%     for iWhite = 1 : num_white_regions
%         if checkProps(iWhite).Solidity > minSolidity && ...
%            checkProps(iWhite).Area > minArea
%             whiteMask = whiteMask | L_white == iWhite;
%         end
%     end
%     
%     checkProps = regionprops(black_checks,'solidity','area');
%     num_black_regions = length(checkProps);
%     for iBlack = 1 : num_black_regions
%         if checkProps(iBlack).Solidity > minSolidity && ...
%            checkProps(iBlack).Area > minArea
%             blackMask = blackMask | L_black == iBlack;
%         end
%     end
%     
%     curWhiteMask = whiteMask | white_checks;
%     curBlackMask = blackMask | black_checks;
%     
%     curL_white = bwlabel(curWhiteMask);
%     curL_black = bwlabel(curBlackMask);
%     
%     num_white_regions = max(curL_white(:));
%     num_black_regions = max(curL_black(:));
%         
%     if num_white_regions ~= num_antic_regions
%         curWhiteThresh = curWhiteThresh + threshStep;
%     end
%     
%     if num_black_regions ~= num_antic_regions
%         curBlackThresh = curBlackThresh - threshStep;
%     end
%     
% %     num_regions = min(num_white_regions, num_black_regions);
%     
% %     figure(3);imshow(label2rgb(curL_white));
% %     figure(4);imshow(label2rgb(curL_black));
%     
% end