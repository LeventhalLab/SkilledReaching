function [ imgMask, denoisedMasks ] = findDirectBorders( img, HSVlimits, ROIs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% INPUTS

% OUTPUTS
%   imgMask - mask images - h x w x 3 stored in the following order:
%       1 - direct view red
%       2 - direct view green
%       3 - direct view blue

threshStepSize = 0.01;
diffThresh = 0.1;
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
    
SEsize = 3;
SE = strel('disk',SEsize);

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

    minCheckerboardArea = 5000;
    maxCheckerboardArea = 20000;

    img_hsv = rgb2hsv(img_stretch);

    directMask = false(h,w);
    directMask(ROIs(1,2):ROIs(1,2)+ROIs(1,4)-1, ROIs(1,1):ROIs(1,1)+ROIs(1,3)-1) = true;
    directView_hsv = img_hsv .* repmat(double(directMask),1,1,3);

    % mirrorMasks = false(h,w,3);
    % mirrorView_hsv = zeros(h,w,3,3);
    % for iView = 1 : numMirrors
    %     mirrorMasks(ROIs(iView+1,2):ROIs(iView+1,2)+ROIs(iView+1,4)-1, ROIs(iView+1,1):ROIs(iView+1,1)+ROIs(iView+1,3)-1,iView) = true;
    %     mirrorView_hsv(:,:,:,iView) = img_hsv .* repmat(double(squeeze(mirrorMasks(:,:,iView))),1,1,3);
    %     mirrorMasks(:,:,iView) = directMask | squeeze(mirrorMasks(:,:,iView));
    % end

    % find seed regions

    meanHSV = zeros(numColors,2,3);    % 3 colors by 2 regions by 3 values
    stdHSV = zeros(numColors,2,3);

    imgMask{iImg} = false(h,w,numColors);
    for iColor = 1 : numColors
        initSeedMasks(:,:,iColor,iImg) = HSVthreshold(img_hsv, HSVlimits(iColor,:)) & directMask;
    %     initSeedMasks(:,:,iColor) = squeeze(initSeedMasks(:,:,iColor)) & squeeze(mirrorMasks(:,:,iColor));

    %     figure(iColor+1)
    %     imshow(squeeze(initSeedMasks(:,:,iColor)));

        % clean up the noise
        denoisedMasks(:,:,iColor,iImg) = imopen(squeeze(initSeedMasks(:,:,iColor,iImg)), SE);
        denoisedMasks(:,:,iColor,iImg) = imclose(squeeze(denoisedMasks(:,:,iColor,iImg)), SE);
        
        % get rid of little "satellite blobs" too far from the main blob
        mainBlob = bwareafilt(denoisedMasks(:,:,iColor,iImg),1);
        denoisedMasks(:,:,iColor,iImg) = removeDistantBlobs(mainBlob, denoisedMasks(:,:,iColor,iImg), maxDistFromMainBlob);        
        % find stats for colors inside the mask region
    %     mirrorBorderMask = squeeze(denoisedMasks(:,:,iColor)) & squeeze(mirrorMasks(:,:,iColor));
        directBorderMask = squeeze(denoisedMasks(:,:,iColor,iImg));
        [meanHSV(iColor,1,:),stdHSV(iColor,1,:)] = calcHSVstats(img_hsv, directBorderMask);
    %     [meanHSV(iColor,2,:),stdHSV(iColor,2,:)] = calcHSVstats(img_hsv, mirrorBorderMask);

        % in each view, calculate distance in hsv space to the mean values in
        % the borders
        directView_hsvDist = calcHSVdist(directView_hsv, squeeze(meanHSV(iColor,1,:)));
    %     mirrorView_hsvDist = calcHSVdist(squeeze(mirrorView_hsv(:,:,:,iColor)), squeeze(meanHSV(iColor,2,:)));

        directViewGray = mean(directView_hsvDist(:,:,1:2),3);
    %     mirrorViewGray = mean(mirrorView_hsvDist(:,:,1:2),3);
    %     figure(iColor+4)
    %     directThresh = directView_hsvDist(:,:,1) < diffThresh;
    %     mirrorThresh = mirrorView_hsvDist(:,:,1) < diffThresh;

        % iterate until we find a border region with a single hole 
        currentThresh = diffThresh;
        foundValidBorder = false;
        while ~foundValidBorder && currentThresh < maxThresh
            directBorder = directViewGray < currentThresh;
            directBorder = bwmorph(directBorder,'clean');
            % make sure we don't over-erode a thin edge
            borderPlusHoles = imfill(directBorder,'holes');
            borderHoles = borderPlusHoles & ~directBorder;
            directBorder = imopen(borderPlusHoles, SE) & ~borderHoles;
            directBorder = imclose(directBorder, SE);

            % only include regions that touch the initial seed region
            directBorder = imreconstruct(denoisedMasks(:,:,iColor,iImg), directBorder);
            L = bwlabel(directBorder);
            if ~any(L(:))   % if nothing detected
                currentThresh = currentThresh + threshStepSize;
                continue;
            end

            for iObj = 1 : max(L(:))
                regionstats = regionprops(L == iObj,'euler');
                if regionstats.EulerNumber == 0   % a candidate border - there is one hole
                    directBorder_filled = imfill(directBorder,'holes');
                    testImg = directBorder_filled & ~directBorder;   % where the checkerboard should be
                    teststats = regionprops(testImg,'area');
                    A = teststats.Area;

                    if A > minCheckerboardArea && A < maxCheckerboardArea
                        foundValidBorder = true;
                        directBorder = (L == iObj);
                        break;
                    end
                end
            end
            currentThresh = currentThresh + threshStepSize;

        end
        % smooth it
    %     imgMask(:,:,iColor) = imopen(directBorder,strel('disk',3));
    %     imgMask(:,:,iColor) = imclose(imgMask(:,:,iColor),strel('disk',3));
        if foundValidBorder
            imgMask{iImg}(:,:,iColor) = directBorder;
        end

    end


end

end

