function [ imgMask, denoisedMasks ] = findDirectBorders( img, HSVlimits, ROIs, varargin )
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

minCheckerboardArea = 5000;
maxCheckerboardArea = 25000;
    
maxDistFromMainBlob = 200;    
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

    img_hsv = rgb2hsv(img_stretch);

    directMask = false(h,w);
    directMask(ROIs(1,2):ROIs(1,2)+ROIs(1,4)-1, ROIs(1,1):ROIs(1,1)+ROIs(1,3)-1) = true;
%     directView_hsv = img_hsv .* repmat(double(directMask),1,1,3);

    % mirrorMasks = false(h,w,3);
    % mirrorView_hsv = zeros(h,w,3,3);
    % for iView = 1 : numMirrors
    %     mirrorMasks(ROIs(iView+1,2):ROIs(iView+1,2)+ROIs(iView+1,4)-1, ROIs(iView+1,1):ROIs(iView+1,1)+ROIs(iView+1,3)-1,iView) = true;
    %     mirrorView_hsv(:,:,:,iView) = img_hsv .* repmat(double(squeeze(mirrorMasks(:,:,iView))),1,1,3);
    %     mirrorMasks(:,:,iView) = directMask | squeeze(mirrorMasks(:,:,iView));
    % end

    % find seed regions

%     meanHSV = zeros(numColors,2,3);    % 3 colors by 2 regions by 3 values
%     stdHSV = zeros(numColors,2,3);

    imgMask{iImg} = false(h,w,numColors);
    foundValidBorder = false(1,numColors);
    for iColor = 1 : numColors
        
        [directBorder,denoisedMask,indValidBorder] = findValidBorders(img_hsv, HSVlimits(iColor,:), directMask, ...
            'diffthresh', diffThresh, 'threshstepsize', threshStepSize, 'maxthresh', maxThresh, ...
            'maxdistfrommainblob', maxDistFromMainBlob, 'mincheckerboardarea', minCheckerboardArea, ...
            'maxcheckerboardarea', maxCheckerboardArea, 'sesize', SEsize, 'minsolidity', minSolidity);
        denoisedMasks(:,:,iColor,iImg) = denoisedMask;
        foundValidBorder(iColor) = indValidBorder;
%         initSeedMasks(:,:,iColor,iImg) = HSVthreshold(img_hsv, HSVlimits(iColor,:)) & directMask;
% 
%         % clean up the noise
%         denoisedMasks(:,:,iColor,iImg) = imopen(squeeze(initSeedMasks(:,:,iColor,iImg)), SE);
%         denoisedMasks(:,:,iColor,iImg) = imclose(squeeze(denoisedMasks(:,:,iColor,iImg)), SE);
%         
%         % get rid of little "satellite blobs" too far from the main blob
%         mainBlob = bwareafilt(denoisedMasks(:,:,iColor,iImg),1);
%         denoisedMasks(:,:,iColor,iImg) = removeDistantBlobs(mainBlob, denoisedMasks(:,:,iColor,iImg), maxDistFromMainBlob);        
%         % find stats for colors inside the mask region
%     %     mirrorBorderMask = squeeze(denoisedMasks(:,:,iColor)) & squeeze(mirrorMasks(:,:,iColor));
%         directBorderMask = squeeze(denoisedMasks(:,:,iColor,iImg));
%         [meanHSV(iColor,1,:),stdHSV(iColor,1,:)] = calcHSVstats(img_hsv, directBorderMask);
%     %     [meanHSV(iColor,2,:),stdHSV(iColor,2,:)] = calcHSVstats(img_hsv, mirrorBorderMask);
% 
%         % in each view, calculate distance in hsv space to the mean values in
%         % the borders
%         directView_hsvDist = calcHSVdist(directView_hsv, squeeze(meanHSV(iColor,1,:)));
%     %     mirrorView_hsvDist = calcHSVdist(squeeze(mirrorView_hsv(:,:,:,iColor)), squeeze(meanHSV(iColor,2,:)));
% 
%         directViewGray = mean(directView_hsvDist(:,:,1:2),3);
%     %     mirrorViewGray = mean(mirrorView_hsvDist(:,:,1:2),3);
%     %     figure(iColor+4)
%     %     directThresh = directView_hsvDist(:,:,1) < diffThresh;
%     %     mirrorThresh = mirrorView_hsvDist(:,:,1) < diffThresh;
% 
%         % iterate until we find a border region with a single hole 
%         currentThresh = diffThresh;
%         while ~foundValidBorder(iColor) && currentThresh < maxThresh
%             directBorder = directViewGray < currentThresh;
%             directBorder = bwmorph(directBorder,'clean');
%             % make sure we don't over-erode a thin edge
%             borderPlusHoles = imfill(directBorder,'holes');
%             borderHoles = borderPlusHoles & ~directBorder;
%             directBorder = imopen(borderPlusHoles, SE) & ~borderHoles;
%             directBorder = imclose(directBorder, SE);
% 
%             % only include regions that touch the initial seed region
%             directBorder = imreconstruct(denoisedMasks(:,:,iColor,iImg), directBorder);
%             L = bwlabel(directBorder);
%             if ~any(L(:))   % if nothing detected
%                 currentThresh = currentThresh + threshStepSize;
%                 continue;
%             end
% 
%             for iObj = 1 : max(L(:))
%                 regionstats = regionprops(L == iObj,'euler');
%                 if regionstats.EulerNumber == 0   % a candidate border - there is one hole
%                     directBorder_filled = imfill(directBorder,'holes');
%                     testImg = directBorder_filled & ~directBorder;   % where the checkerboard should be
%                     teststats = regionprops(testImg,'area');
%                     A = teststats.Area;
% 
%                     if A > minCheckerboardArea && A < maxCheckerboardArea
%                         foundValidBorder(iColor) = true;
%                         directBorder = (L == iObj);
%                         break;
%                     end
%                 end
%             end
%             currentThresh = currentThresh + threshStepSize;
% 
%         end
        % smooth it
    %     imgMask(:,:,iColor) = imopen(directBorder,strel('disk',3));
    %     imgMask(:,:,iColor) = imclose(imgMask(:,:,iColor),strel('disk',3));
        if foundValidBorder(iColor)
            imgMask{iImg}(:,:,iColor) = directBorder;
        end

    end
    
    % if no valid borders found for one or more of the colors, look again
    % close to the other borders that were found
    if any(foundValidBorder) && ~all(foundValidBorder)
        % create a mask of the other border(s) that are valid
        otherBorderMask = false(h,w);
        for ii = 1 : numColors
            otherBorderMask = otherBorderMask | imgMask{iImg}(:,:,ii);
        end
        if ~foundValidBorder(1)
            % extend ROI up at from other borders if the
            % top (red) checkerboard wasn't found
            extendMaskUp = 150;
        else
            extendMaskUp = 0;
        end
        if foundValidBorder(1) && ~(foundValidBorder(2) || foundValidBorder(3))
            extendMaskDown = 250;
        else
            extendMaskDown = 0;
        end
        if foundValidBorder(2) && ~foundValidBorder(3)
            extendMaskRight = 250;
            extendMaskLeft = 0;
        end
        if ~foundValidBorder(2) && foundValidBorder(3)
            extendMaskLeft = 250;
            extendMaskRight = 0;
        end
        if ~foundValidBorder(2) && ~foundValidBorder(3)
            extendMaskLeft = 50;
            extendMaskRight = 50;
        end
        if foundValidBorder(2) && foundValidBorder(3)
            extendMaskLeft = 0;
            extendMaskRight = 0;
        end
        s = regionprops(bwconvhull(otherBorderMask,'union'),'boundingbox');
        bBox = round(s.BoundingBox);
        bBox(1) = bBox(1) - extendMaskLeft;
        bBox(2) = bBox(2) - extendMaskUp;
        bBox(3) = bBox(3) + extendMaskLeft + extendMaskRight;
        bBox(4) = bBox(4) + extendMaskUp + extendMaskDown;
        
        cropped_img = img{iImg}(bBox(2):bBox(2) + bBox(4),...
                                bBox(1):bBox(1) + bBox(3),:);
                            
        otherBorderMask_filled = imfill(otherBorderMask,'holes');
        otherBorderMask_cropped = otherBorderMask_filled(bBox(2):bBox(2) + bBox(4),...
                                bBox(1):bBox(1) + bBox(3));
        cropped_overlay = imoverlay(cropped_img,otherBorderMask_cropped,'k');
        cropped_stretch = decorrstretch(cropped_overlay);
        cropped_hsv = rgb2hsv(cropped_stretch);
        
        for iColor = 1 : numColors
            if ~foundValidBorder(iColor)
                testMask = true(bBox(4)+1,bBox(3)+1);
                testMask = testMask & ~otherBorderMask_cropped;
                [directBorder,denoisedMask,indValidBorder] = findValidBorders(cropped_hsv, HSVlimits(iColor,:), testMask, ...
                    'diffthresh', diffThresh, 'threshstepsize', threshStepSize, 'maxthresh', maxThresh, ...
                    'maxdistfrommainblob', maxDistFromMainBlob, 'mincheckerboardarea', minCheckerboardArea, ...
                    'maxcheckerboardarea', maxCheckerboardArea, 'sesize', SEsize, 'minsolidity', minSolidity);
                foundValidBorder(iColor) = indValidBorder;
                fullBorder = false(h,w);
                fullBorder(bBox(2):bBox(2) + bBox(4),bBox(1):bBox(1) + bBox(3)) = ...
                    denoisedMask;
                denoisedMasks(:,:,iColor,iImg) = fullBorder;
                if foundValidBorder(iColor)
                    fullBorder = false(h,w);
                    fullBorder(bBox(2):bBox(2) + bBox(4),bBox(1):bBox(1) + bBox(3)) = ...
                    directBorder;
                    imgMask{iImg}(:,:,iColor) = fullBorder;
                end
            end
        end
    end

end

end


