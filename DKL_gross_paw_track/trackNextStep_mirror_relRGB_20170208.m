function [fullMask] = trackNextStep_mirror_relRGB_20170208( image_ud, fundMat, greenBGmask, prevMask, boxRegions, pawPref,varargin)
% function [fullMask] = trackNextStep_mirror_relRGB_PCA( image_ud, fundMat, greenBGmask, prevMask, boxRegions, pawPref,PCAcoeff,PCAmean,PCAmean_nonPaw,PCAcovar,varargin)
%
% function to segment a video frame of a rat reaching (paw painted with
% green nail polish) into paw and non-paw portions in both the mirror and
% direct views
%
% INPUTS:
%   image_ud - current undistorted video frame
%   fundMat - fundamental matrix that transforms the direct view to the
%       mirror view containing the dorsum of the paw (i.e., left mirror for
%       a right-pawed rat and vice-versa)
%   BGimg_ud - undistorted background image from this video. This is useful if
%       there are any green blobs (e.g., nail polish that rubbed off the
%       paw) on the box, so they can be ignored during paw tracking
%   prevMask - 
%   boxRegions - 
%   pawPref - 

% extract height and width of the video frame
h = size(image_ud,1); w = size(image_ud,2);
% pawThresh = 0.5;
% nonPawThresh = 0.8;
% probDiffThresh = 0.1;
grDistThresh_res = 0.9;
grDistThresh_lib = 0.5;

min_gb_diff = 0.05;
min_gr_diff = 0.1;

% threshPctile_strict = 95;
% threshPctile_lib = 80;
% gbThresh = 40;
% BGdiffPctile = 60;
% grDiffThresh = 0.3;
% gbDiffThresh = 0.2;

imFiltWidth = 5;

% filtBG = imboxfilt(BGimg_ud,imFiltWidth);
maxFrontPanelSep = 30;
maxDistBehindFrontPanel = 15;
maxDistPerFrame = 20;
shelfThick = 50;

% frontPanelMask = imdilate(boxRegions.frontPanelMask,strel('disk',2)); 
frontPanelMask = boxRegions.frontPanelMask;
darkThresh = 0.05;    % pixels darker than this threshold in R, G, AND B should be discarded

intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
belowShelfMask = boxRegions.belowShelfMask;
shelfMask = boxRegions.shelfMask;
floorMask = boxRegions.floorMask;
slotMask = boxRegions.slotMask;

for iarg = 1 : 2 : nargin - 10
    switch lower(varargin{iarg})
        case 'maxdistperframe'
            maxDistPerFrame = varargin{iarg + 1};
    end
end

% check to see if the paw was entirely outside the box, entirely inside the
% box, or partially in both in the last frame
testOut = prevMask{2} & extMask;
if any(testOut(:))
    prev_pawOut = true;
else
    prev_pawOut = false;
end
testIn = prevMask{2} & intMask;
if any(testIn(:))
    prev_pawIn = true;
else
    prev_pawIn = false;
end
testBelow = prevMask{1} & belowShelfMask;
if any(testBelow(:))
    pawBelow = true;
else
    pawBelow = false;
end
testAbove = prevMask{1} & (~belowShelfMask & ~shelfMask);
if any(testAbove(:))
    pawAbove = true;
else
    pawAbove = false;
end

prev_bbox = zeros(2,4);
cur_ROI = cell(1,2);
prev_mask_dilate_ROI = cell(1,2);
im_relRGB = cell(1,2);
drkmsk = cell(1,2);
dilated_bbox = zeros(2,4);
BGmask_ROI = cell(1,2);
% PCA_im = cell(1,2);
for ii = 2 : -1 : 1
    temp = regionprops(bwconvhull(prevMask{ii},'union'),'BoundingBox');
    prev_bbox(ii,:) = round(temp.BoundingBox);
    dilated_bbox(ii,1:2) = [max(prev_bbox(ii,1)-maxDistPerFrame, 1),...
                            max(prev_bbox(ii,2)-maxDistPerFrame, 1)];
    dilated_bbox(ii,3:4) = [min(prev_bbox(ii,3)+(2*maxDistPerFrame),w-dilated_bbox(ii,1)),...
                            min(prev_bbox(ii,4)+(2*maxDistPerFrame),h-dilated_bbox(ii,2))];
                          
    if ii == 2   
        
        SE = [ones(1,maxDistBehindFrontPanel),zeros(1,maxDistBehindFrontPanel)];
        behindPanelMask = imdilate(frontPanelMask,SE) & ~frontPanelMask;
        
        prevMask_dilate = imdilate(prevMask{2},strel('disk',maxDistPerFrame));
        
        frontPanelTest = (prevMask_dilate & frontPanelMask);
        if any(frontPanelTest(:))
            if prev_pawIn == false 
                if strcmpi(pawPref,'left')
                    % extend the bounding box backward by maxFrontPanelSep
                    dilated_bbox(2,1) = max(dilated_bbox(2,1) - maxFrontPanelSep, 1);
                    dilated_bbox(2,3) = min(dilated_bbox(2,3) + maxFrontPanelSep, w-dilated_bbox(2,1));

                    % extend prevMask_dilate back by maxFrontPanelSep
                    SE = [ones(1,maxFrontPanelSep+maxDistPerFrame),zeros(1,maxFrontPanelSep+maxDistPerFrame)];

                    prevMask_dilate = imdilate(prevMask_dilate, SE);
                else
                    % extend the bounding box forward by maxFrontPanelSep
                    dilated_bbox(2,3) = min(dilated_bbox(2,3) + maxFrontPanelSep, w-dilated_bbox(2,1));

                    % extend prevMask_dilate forward by maxFrontPanelSep
                    SE = [zeros(1,maxFrontPanelSep+maxDistPerFrame),ones(1,maxFrontPanelSep+maxDistPerFrame)];

                    prevMask_dilate = imdilate(prevMask_dilate, SE);
                end
            end
            if prev_pawOut == false
                if strcmpi(pawPref,'left')
                    % extend the bounding box forward by maxFrontPanelSep
                    dilated_bbox(2,3) = min(dilated_bbox(2,3) + maxFrontPanelSep, w-dilated_bbox(2,1));

                    % extend prevMask_dilate forward by maxFrontPanelSep
                    SE = [zeros(1,maxFrontPanelSep+maxDistPerFrame),ones(1,maxFrontPanelSep+maxDistPerFrame)];

                    prevMask_dilate = imdilate(prevMask_dilate, SE);
                else
                    % extend the bounding box backward by maxFrontPanelSep
                    dilated_bbox(2,1) = max(dilated_bbox(2,1) - maxFrontPanelSep, 1);
                    dilated_bbox(2,3) = min(dilated_bbox(2,3) + maxFrontPanelSep, w-dilated_bbox(2,1));

                    % extend prevMask_dilate back by maxFrontPanelSep
                    SE = [ones(1,maxFrontPanelSep+maxDistPerFrame),zeros(1,maxFrontPanelSep+maxDistPerFrame)];

                    prevMask_dilate = imdilate(prevMask_dilate, SE);
                end
            end
        end
        behindPanelMask = prevMask_dilate & behindPanelMask;
        behindPanelMask = behindPanelMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    else
        prevMask_dilate = imdilate(prevMask{1},strel('disk',maxDistPerFrame));
        shelfTest = (prevMask_dilate & shelfMask);
        if any(shelfTest(:)) && (pawIn == true)  % check that part of the paw is currently inside the box on the last frame. Note this is set on the first loop iteration.
            if pawAbove == false
                % extend the bounding box up
                dilated_bbox(1,2) = max(dilated_bbox(1,2) - shelfThick, 1);
                dilated_bbox(1,4) = min(dilated_bbox(1,4) + shelfThick, h);
                
                % extend prevMask_dilate up
                SE = [ones(shelfThick,1);zeros(shelfThick,1)];
                prevMask_dilate = imdilate(prevMask_dilate, SE);
            end
            if pawBelow == false
                % extend the bounding box down
                dilated_bbox(1,4) = min(dilated_bbox(1,4) + shelfThick, h);
                
                % extend prevMask_dilate down
                SE = [zeros(shelfThick,1);ones(shelfThick,1)];
                prevMask_dilate = imdilate(prevMask_dilate, SE);
            end
        end
        if pawAbove == true
            % make sure bounding box at least includes the width of the
            % slot
            slotOutline = regionprops(imdilate(slotMask,strel('disk',5)),'boundingbox');
            slot_bbox = round(slotOutline.BoundingBox);
            bbox_right = dilated_bbox(1,1) + dilated_bbox(1,3);
            dilated_bbox(1,1) = min(dilated_bbox(1,1),slot_bbox(1));
            bbox_right = max(bbox_right, slot_bbox(1) + slot_bbox(3));
            dilated_bbox(1,3) = bbox_right - dilated_bbox(1,1);
        end    
             
    end
    

    cur_ROI{ii} = image_ud(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3),:);
    cur_ROI{ii} = imboxfilt(cur_ROI{ii},imFiltWidth);
    prev_mask_dilate_ROI{ii} = prevMask_dilate(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    im_relRGB{ii} = relativeRGB(cur_ROI{ii});
%     BG_ROI{ii} = filtBG(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3),:);
%     relBG_ROI{ii} = relativeRGB(BG_ROI{ii});
    BGmask_ROI{ii} = greenBGmask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    frontPanelMask_ROI = frontPanelMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    
    r = im_relRGB{ii}(:,:,1);
    g = im_relRGB{ii}(:,:,2);
    b = im_relRGB{ii}(:,:,3);
    
    gr_diff = g - r;
    gb_diff = g - b;
    
    grMask = gr_diff > min_gr_diff;
    gbMask = gb_diff > min_gb_diff;
    
    gr_diff(gr_diff < 0) = 0;
    gb_diff(gb_diff < 0) = 0;
    
    grDist = sqrt(gr_diff.^2 + gb_diff.^2);
    grDist_adj = imadjust(grDist);
    
    tempMask_res = grDist_adj > grDistThresh_res;
    tempMask_lib = grDist_adj > grDistThresh_lib;
    tempMask = imreconstruct(tempMask_res,tempMask_lib);
    
    tempMask = tempMask & grMask & gbMask;   % make sure that any large differences between green and red/blue are not driven by just one color channel
    
    drkmsk{ii} = true(size(tempMask));
    for jj = 1 : 3
        drkmsk{ii} = drkmsk{ii} & cur_ROI{ii}(:,:,jj) < darkThresh;
    end
    if ii == 2
        drkmsk{2} = drkmsk{2} & ~behindPanelMask;
    end
    tempMask = tempMask & ~drkmsk{ii};
    tempMask = tempMask & ~BGmask_ROI{ii};
    tempMask = tempMask & prev_mask_dilate_ROI{ii};
    
    tempMask = processMask(tempMask,'sesize',2);
    if ii == 2
        intMask = intMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
        testIn = intMask & tempMask;
        pawIn = false;
        if any(testIn(:))
            pawIn = true;
        end
        tempMask = tempMask & ~frontPanelMask_ROI;
    end
    
    newMask{ii} = false(h,w);
    newMask{ii}(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3)) = tempMask;
    newMask{ii} = newMask{ii} & ~floorMask;
    
end

fullMask = newMask;
% if any(newMask{1}(:)) && any(newMask{2}(:))
%     fullMask = maskProjectionBlobs(newMask,[1,1,w-1,h-1;1,1,w-1,h-1],fundMat,[h,w]);
% end
