function [ imgMask, denoisedMasks ] = findMirrorBorders(img, HSVlimits, ROIs)


diffThresh = 0.1;
threshStepSize = 0.01;
maxThresh = 0.2;
maxDistFromMainBlob = 200;

if iscell(img)
    num_img = length(img);
else
    num_img = 1;
    img = {img};
end

imgMask = cell(1, num_img);
numColors = size(ROIs,1) - 1;

h = size(img{1},1);
w = size(img{1},2);
    
initSeedMasks = false(h,w,numColors,num_img);
denoisedMasks = false(h,w,numColors,num_img);
    
for iImg = 1 : num_img
    
    if isa(img{iImg},'uint8')
        img{iImg} = double(img{iImg}) / 255;
    end
    im_eq = adapthisteq(rgb2gray(img{iImg}));
    im_hsv = rgb2hsv(img{iImg});
    hsv_eq = im_hsv;
    hsv_eq(:,:,3) = im_eq;
    rgb_eq = hsv2rgb(hsv_eq);

    img_stretch = decorrstretch(rgb_eq);

    SEsize = 3;
    SE = strel('disk',SEsize);
    minCheckerboardArea = 5000;
    maxCheckerboardArea = 20000;
    minSolidity = 0.8;

    img_hsv = rgb2hsv(img_stretch);
    imgMask{iImg} = false(h,w,3);
    for iMirror = 1 : numColors
        mirrorMask = false(h,w);
        mirrorMask(ROIs(iMirror+1,2):ROIs(iMirror+1,2)+ROIs(iMirror+1,4)-1, ROIs(iMirror+1,1):ROIs(iMirror+1,1)+ROIs(iMirror+1,3)-1) = true;
        mirrorView_hsv = img_hsv .* repmat(double(mirrorMask),1,1,3);

        initSeedMasks(:,:,iMirror,iImg) = HSVthreshold(mirrorView_hsv, HSVlimits(iMirror,:)) & mirrorMask;

        denoisedMasks(:,:,iMirror,iImg) = imopen(squeeze(initSeedMasks(:,:,iMirror,iImg)), SE);
        denoisedMasks(:,:,iMirror,iImg) = imclose(squeeze(denoisedMasks(:,:,iMirror,iImg)), SE);

        % get rid of little "satellite blobs" too far from the main blob
        mainBlob = bwareafilt(denoisedMasks(:,:,iMirror,iImg),1);
        denoisedMasks(:,:,iColor,iImg) = removeDistantBlobs(mainBlob, denoisedMasks(:,:,iMirror,iImg), maxDistFromMainBlob);        
        
        mirrorBorderMask = squeeze(denoisedMasks(:,:,iMirror,iImg));
        [meanHSV(iMirror,1,:),stdHSV(iMirror,1,:)] = calcHSVstats(img_hsv, mirrorBorderMask);

        mirrorView_hsvDist = calcHSVdist(mirrorView_hsv, squeeze(meanHSV(iMirror,1,:)));

        mirrorViewGray = mean(mirrorView_hsvDist(:,:,1:2),3);
    %     mirrorViewGray = mirrorView_hsvDist(:,:,1);

        % iterate until we find a border region with a single hole 
        currentThresh = diffThresh;
        foundValidBorder = false;
        numIterations = 0;
        while ~foundValidBorder && currentThresh < maxThresh
            if numIterations == 0
                mirrorBorder = mirrorBorderMask;
            else
                mirrorBorder = mirrorViewGray < currentThresh;
            end
            mirrorBorder = bwmorph(mirrorBorder,'clean');
            % saturation and intensity have to be high to accept pixels
    %         mirrorBorder = mirrorBorder & (mirrorView_hsv(:,:,2) > HSVlimits(iMirror,3)) & ...
    %             (mirrorView_hsv(:,:,3) > HSVlimits(iMirror,5));
            borderPlusHoles = imfill(mirrorBorder,'holes');
            borderHoles = borderPlusHoles & ~mirrorBorder;
            mirrorBorder = imopen(borderPlusHoles, SE) & ~borderHoles;
            mirrorBorder = imclose(mirrorBorder, SE);

            L = bwlabel(mirrorBorder);
            if ~any(L(:))   % if nothing detected
                currentThresh = currentThresh + threshStepSize;
                continue;
            end

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
                        mirrorBorder = (L == iObj);
                        break;
                    end
                end
            end

            % what if we have the right border but there are multiple holes in
            % it?
            mirrorBorder_filled = imfill(mirrorBorder,'holes');
            testHoles = mirrorBorder_filled & ~mirrorBorder;
            L = bwlabel(testHoles);
            for iObj = 1 : max(L(:))
                teststats = regionprops(L == iObj,'area','solidity');
                A = teststats.Area;

                if A > minCheckerboardArea && A < maxCheckerboardArea && ...
                        teststats.Solidity > minSolidity
                    foundValidBorder = true;
                    mirrorBorder = mirrorBorder_filled & ~(L == iObj);
                    break;
                end
            end
            currentThresh = currentThresh + threshStepSize;
            numIterations = numIterations + 1;

        end

        % smooth it
    %     imgMask{iImg}(:,:,iMirror) = imopen(mirrorBorder,strel('disk',3));
    %     imgMask{iImg}(:,:,iMirror) = imclose(imgMask{iImg}(:,:,iMirror),strel('disk',3));
    
        % get rid of anything on the interior that is not saturated or
        % bright enough
%         filledRegion = imfill(mirrorBorder,'holes') & ~mirrorBorder;
        
        % go through points in filled region and figure out if those points
        % are more likely to be part of a checkerboard or part of the border
%         lowSatVal = img_hsv(:,:,2) < HSVlimits(iMirror,3) | img_hsv(:,:,3) < HSVlimits(iMirror,5);
        if foundValidBorder
            imgMask{iImg}(:,:,iMirror) = mirrorBorder;
        end

    end

end

end