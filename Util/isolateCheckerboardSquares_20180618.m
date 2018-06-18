function [whiteMask, blackMask] = isolateCheckerboardSquares_20180618(testGray, boardMask, anticipatedBoardSize, varargin)
threshStep = 0.02;
curWhiteThresh = 0.5;
curBlackThresh = 0.5;
maxIterations = 20;

minSolidity = 0.85;
minArea = 100;
maxArea = 1000;
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

% testGray = img_sharp .* double(cvHull);
% testGray_inv = (1 - img_sharp) .* double(cvHull);
% 
% figure(1);
% imshow(testGray)
% 
% figure(2);
% imshow(testGray_inv)

whiteMask = false(size(testGray,1),size(testGray,2));
blackMask = false(size(testGray,1),size(testGray,2));
num_white_regions = 0;
num_black_regions = 0;

numIterations = 0;
q = gradientweight(testGray);
interChecks = q < 0.1 & boardMask;
q_adj = imadjust(q);
q_masked = q_adj .* double(boardMask);
r = q_masked > 0.1;

erodeSize = 0;
seedMap = false(size(r));
numValidRegions = 0;
tooManyErosions = false;
while numValidRegions ~= prod(anticipatedBoardSize)
    s=imerode(r,strel('disk',erodeSize));
    s = s & ~interChecks;
    checkProps = regionprops(s,'solidity','area');
    numRegions = length(checkProps);
    
    L = bwlabel(s);
    for iRegion = 1 : numRegions
        if checkProps(iRegion).Area > minArea && ...
                checkProps(iRegion).Area < maxArea && ...
                checkProps(iRegion).Solidity > minSolidity
            seedMap = seedMap | L == iRegion;
        end
    end
    
    seed_L = bwlabel(seedMap);
    numValidRegions = max(seed_L(:));
    erodeSize = erodeSize + 1;
    if erodeSize > 5
        tooManyErosions = true;
        break;
    end
end

% what if we went through too many erosions? One of the checks didn't
% quite meet criteria to stay...
if tooManyErosions
    % WORKING HERE TOMORROW
    
end
z = bwmorph(seedMap,'shrink',3);
t = imsegfmm(q_masked,z,0.5);
figure(1);imshow(z)
figure(2);imshow(t)
while (num_white_regions ~= num_antic_regions || num_black_regions ~= num_antic_regions) && numIterations <= maxIterations
    numIterations = numIterations + 1;
    
    white_checks = testGray > curWhiteThresh;
    black_checks = testGray < curBlackThresh;
    
    interChecks = imopen(interChecks,strel('disk',1));
    interChecks = imclose(interChecks,strel('disk',1));
    
    white_checks = white_checks & boardMask;
    white_checks = white_checks & ~interChecks;
%     white_checks = imclose(white_checks,strel('disk',2));
%     white_checks = imopen(white_checks,strel('disk',2));
%     white_checks = imerode(white_checks,strel('disk',5));

    
    black_checks = black_checks & boardMask;
    black_checks = black_checks & ~interChecks;
%     black_checks = imclose(black_checks,strel('disk',2));
%     black_checks = imopen(black_checks,strel('disk',2));
%     black_checks = imerode(black_checks,strel('disk',5));
    
    L_white = bwlabel(white_checks);
    L_black = bwlabel(black_checks);
    
    % store any checks that already meet criteria for later
    checkProps = regionprops(white_checks,'solidity','area');
    num_white_regions = length(checkProps);
    for iWhite = 1 : num_white_regions
        if checkProps(iWhite).Solidity > minSolidity && ...
           checkProps(iWhite).Area > minArea
            whiteMask = whiteMask | L_white == iWhite;
        end
    end
    
    checkProps = regionprops(black_checks,'solidity','area');
    num_black_regions = length(checkProps);
    for iBlack = 1 : num_black_regions
        if checkProps(iBlack).Solidity > minSolidity && ...
           checkProps(iBlack).Area > minArea
            blackMask = blackMask | L_black == iBlack;
        end
    end
    
    curWhiteMask = whiteMask | white_checks;
    curBlackMask = blackMask | black_checks;
    
    curL_white = bwlabel(curWhiteMask);
    curL_black = bwlabel(curBlackMask);
    
    num_white_regions = max(curL_white(:));
    num_black_regions = max(curL_black(:));
        
    if num_white_regions ~= num_antic_regions
        curWhiteThresh = curWhiteThresh + threshStep;
    end
    
    if num_black_regions ~= num_antic_regions
        curBlackThresh = curBlackThresh - threshStep;
    end
    
%     num_regions = min(num_white_regions, num_black_regions);
    
%     figure(3);imshow(label2rgb(curL_white));
%     figure(4);imshow(label2rgb(curL_black));
    
end