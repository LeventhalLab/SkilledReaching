function [fullMask] = trackNextStep_mirror_relRGB_PCA( image_ud, fundMat, greenBGmask, prevMask, boxRegions, pawPref,PCAcoeff,PCA_paw_hist,PCA_nonpaw_hist,PCAbinEdges,varargin)
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
pawThresh = 0.5;
nonPawThresh = 0.8;

threshPctile_strict = 95;
threshPctile_lib = 80;
gbThresh = 40;
% BGdiffPctile = 60;
grDiffThresh = 0.3;
gbDiffThresh = 0.2;

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
    
    colorArray = [r(:),g(:),b(:)];
    
    transformed_rgb = colorArray * PCAcoeff(:,:,ii);
%     transformed_rgb_meanSubt = transformed_rgb - repmat(PCAmean(ii,:),size(transformed_rgb,1),1);
    % see how far each PCA axis is from the mean established for the
    % initial mask
%     PCAmask = true(size(BGmask_ROI{ii}));
%     pcaDist = zeros(size(cur_ROI{ii}));
    % use the first two principal components for image segmentation
    pawHist = squeeze(PCA_paw_hist(:,:,ii));
    nonPawHist = squeeze(PCA_nonpaw_hist(:,:,ii));
    binEdges = squeeze(PCAbinEdges(:,:,ii));
    I = zeros(size(cur_ROI{ii}));
    for jj = 1 : 3
        normalized_pca = (transformed_rgb(:,jj) - min(transformed_rgb(:,jj))) / range(transformed_rgb(:,jj));
        I(:,:,jj) = reshape(normalized_pca,size(BGmask_ROI{ii}));
%         I(:,:,jj) = reshape(transformed_rgb(:,jj),size(BGmask_ROI{ii}));
    end
    [paw_p,nonpaw_p]=pawPixelProb(I,pawHist,nonPawHist,binEdges);
    paw_p(paw_p<0) = 0;
    nonpaw_p(nonpaw_p<0) = 0;
    
    % use only the first two principal components
    p = paw_p(:,:,1:2) - nonpaw_p(:,:,1:2);
    pmax = max(p,[],3);    % find max paw probability across the first 2 principal components
%     PCAmask = pmax > pThresh;
    nonPawMask = nonpaw_p(:,:,2) > nonPawThresh;
    pawMask = paw_p(:,:,1) > pawThresh;
    PCAmask = pawMask & ~nonPawMask;
    
%     for jj = 1 : 2
%         pca_vals = transformed_rgb(:,jj);
%         pca_vals = (pca_vals-min(pca_vals))/range(pca_vals);
%         pca_im = reshape(pca_vals, size(BGmask_ROI{ii}));
%         pcaThresh = graythresh(pca_im);
%         
%         pawMask = ~imbinarize(pca_im,pcaThresh);   % first pc should be small to identify the paw
% 
%         PCAmask = PCAmask & pawMask;
%     end
%     for jj = 1 : 3
%         test_vals = reshape(transformed_rgb(:,jj),size(BGmask_ROI{ii}));
%         if PCAmean(ii,jj) < PCAmean_nonPaw(ii,jj)
%              % look for values greater than the mean minus one standard
%              % deviation
%             pcaDist(:,:,jj) = test_vals - PCAmean(ii,jj);
% %             PCAmask = PCAmask & (test_vals > (PCAmean(ii,jj) - PCAcovar(ii,jj)));
%         else
%             % look for values less than the mean plus one standard
%             % deviation
%             pcaDist(:,:,jj) = PCAmean(ii,jj) - test_vals;
% %             PCAmask = PCAmask & (test_vals < (PCAmean(ii,jj) + PCAcovar(ii,jj)));
%         end
%         PCAmask = PCAmask & (pcaDist(:,:,jj) < sqrt(PCAcovar(ii,jj)));
%     end
           
            
%     pcaDeviation = zeros(size(transformed_rgb));
%     pdev = zeros(size(cur_ROI{ii}));
%     for jj = 1 : 3
%         pcaDeviation(:,jj) = (transformed_rgb(:,jj) - PCAmean(ii,jj));
%         pdev(:,:,jj) = reshape(pcaDeviation(:,jj),size(BGmask_ROI{ii}));
%     end
%     
%     pcaDist = sqrt(sum(pcaDeviation.^2,2));
%     pcaDist = reshape(pcaDist,size(BGmask_ROI{ii}));
    
%     BGdiff = imabsdiff(relBG_ROI{ii},im_relRGB{ii});
%     BGdiffmag = sqrt(sum(BGdiff.^2,3));
%     BGadjust = imadjust(BGdiffmag);
%     BGthresh = graythresh(BGadjust);
%     BGvals = BGadjust(:);
%     BGthresh = prctile(BGvals(BGvals>0),BGdiffPctile);
%     BGthresh = 0.25;
%     BGmask = imbinarize(BGadjust,BGthresh);

    
    
%     rel_grdiff = im_relRGB{ii}(:,:,2) - im_relRGB{ii}(:,:,1);
%     rel_gbdiff = im_relRGB{ii}(:,:,2) - im_relRGB{ii}(:,:,3);
%     rel_gr_img = imadjust(rel_grdiff);
%     rel_gb_img = imadjust(rel_gbdiff);
%     rel_gr_values = rel_gr_img(:);
%     rel_gb_values = rel_gb_img(:);
%     l_gr = prctile(rel_gr_values(rel_gr_values>0), threshPctile_strict);
%     l_gb = prctile(rel_gb_values(rel_gb_values>0), gbThresh);
%     l_gb = prctile(rel_gb_img(:), threshPctile_strict);
    
%     l_gr2 = prctile(rel_gr_values(rel_gr_values>0), threshPctile_lib);
%     l_gb2 = prctile(rel_gb_img(:), threshPctile_lib);
    
%     l_gr = graythresh(rel_gr_img);
%     grMask = rel_gr_img > (l_gr + 0.05);
%     grMask_strict = rel_gr_img > l_gr;
%     grMask = imbinarize(rel_grdiff, grDiffThresh);%rel_gr_img > l_gr2;
%     gbMask = imbinarize(rel_gbdiff, gbDiffThresh);
%     if ii == 2
%         grMask_lib = grMask_lib & ~frontPanelMask_ROI;
%         grMask_strict = grMask_strict & ~frontPanelMask_ROI;
%         grMask = grMask & ~frontPanelMask_ROI;
%     end
        
%     grMask = imreconstruct(grMask_strict,grMask_lib);
    
%     l_gb = graythresh(rel_gb_img);
%     gbMask = rel_gb_img > (l_gb + 0.05);
%     gbMask_strict = rel_gb_img > l_gb;
%     gbMask_lib = rel_gb_img > l_gb2;
%     gbMask = imreconstruct(gbMask_strict,gbMask_lib);
%     gbMask = imbinarize(rel_gb_img,l_gb);

    tempMask = PCAmask;%grMask & gbMask;
    
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
