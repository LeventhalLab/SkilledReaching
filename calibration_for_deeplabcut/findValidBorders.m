function [borderMask,denoisedMask,foundValidBorder] = findValidBorders(img_hsv, HSVlimits, viewMask, varargin)

diffThresh = 0.1;
threshStepSize = 0.01;
maxThresh = 0.2;
maxDistFromMainBlob = 200;

minCheckerboardArea = 5000;
maxCheckerboardArea = 25000;

minSolidity = 0.8;
    
SEsize = 3;

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'diffthresh'
            diffThresh = varargin{iarg + 1};
        case 'threshstepsize'
            threshStepSize = varargin{iarg + 1};
        case 'maxthresh'
            maxThresh = varargin{iarg + 1};
        case 'maxdistfrommainblob'
            maxDistFromMainBlob = varargin{iarg + 1};
        case 'mincheckerboardarea'
            minCheckerboardArea = varargin{iarg + 1};
        case 'maxcheckerboardarea'
            maxCheckerboardArea = varargin{iarg + 1};
        case 'sesize'
            SEsize = varargin{iarg + 1};
        case 'minsolidity'
            minSolidity = varargin{iarg + 1};
    end
end
SE = strel('disk',SEsize);

view_hsv = img_hsv .* repmat(double(viewMask),1,1,3);

initSeedMask = HSVthreshold(view_hsv, HSVlimits) & viewMask;

denoisedMask = imopen(squeeze(initSeedMask), SE);
denoisedMask = imclose(squeeze(denoisedMask), SE);

mainBlob = bwareafilt(denoisedMask,1);
denoisedMask = removeDistantBlobs(mainBlob, denoisedMask, maxDistFromMainBlob);

[meanHSV,~] = calcHSVstats(view_hsv, denoisedMask);

hsvDist = calcHSVdist(view_hsv, meanHSV);

hsvDist_gray = mean(hsvDist(:,:,1:2),3);

currentThresh = diffThresh;
numIterations = 0;
foundValidBorder = false;
while ~foundValidBorder && currentThresh < maxThresh
    if numIterations == 0
        borderMask = denoisedMask;
    else
        borderMask = hsvDist_gray < currentThresh;
    end
    borderMask = bwmorph(borderMask,'clean');
    
    borderPlusHoles = imfill(borderMask,'holes');
    borderHoles = borderPlusHoles & ~borderMask;
    borderMask = imopen(borderPlusHoles, SE) & ~borderHoles;
    borderMask = imclose(borderMask, SE);
    
    borderMask = imreconstruct(denoisedMask, borderMask);
    
    L = bwlabel(borderMask);
    if ~any(L(:))   % if nothing detected
        currentThresh = currentThresh + threshStepSize;
        numIterations = numIterations + 1;
        continue;
        
        % what if we have multiple potential borders and only one of them
        % is the right one?
        for iObj = 1 : max(L(:))
            regionstats = regionprops(L == iObj,'euler');
            if regionstats.EulerNumber == 0   % a candidate border - there is one hole
                mirrorBorder_filled = imfill(L == iObj,'holes');
                testImg = mirrorBorder_filled & ~(L == iObj);   % where the checkerboard should be
                teststats = regionprops(testImg,'area');
                A = teststats.Area;

                if A > minCheckerboardArea && A < maxCheckerboardArea
                    foundValidBorder = true;
                    borderMask = (L == iObj);
                    break;
                end
            end
        end
    end
    
    % what if we have the right border but there are multiple holes in
    % it?
    % dilate the border so that if it's almost closed, it seals up
    dil_borderMask = imdilate(borderMask,SE);
    borderPlusHoles = imfill(dil_borderMask,'holes');
    borderHoles = borderPlusHoles & ~dil_borderMask;
    L = bwlabel(borderHoles);
    for iObj = 1 : max(L(:))
        teststats = regionprops(L == iObj,'area','solidity');
        A = teststats.Area;

        if A > minCheckerboardArea && A < maxCheckerboardArea && ...
                teststats.Solidity > minSolidity
            
            % make sure the entire region (holes and borders) is solid -
            % occasionally two sides bleed together
            testObj = imreconstruct(L == iObj, borderPlusHoles);
            new_ts = regionprops(testObj,'solidity');
            if new_ts.Solidity > minSolidity
                foundValidBorder = true;
                borderMask = testObj & ~(L == iObj);
                break;
            end
        end
    end
    
    currentThresh = currentThresh + threshStepSize;
    numIterations = numIterations + 1;

end