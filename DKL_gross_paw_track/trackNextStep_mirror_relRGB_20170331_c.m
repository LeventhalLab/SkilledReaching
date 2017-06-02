function [fullMask] = trackNextStep_mirror_relRGB_20170331_c( image_ud, BGimg_ud, fundMat, greenBGmask, prevMask, boxRegions, pawPref,varargin)
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

grDistThresh_res = [0.7,0.95];
grDistThresh_lib = [0.7,0.6];
belowShelfThresh_res = 0.8;
belowShelfThresh_lib = 0.6;

int_grDistThresh_res = 0.99;
int_grDistThresh_lib = 0.8;

grayRange = [0.08,0.8
             0.03,0.8];    % pixels darker than this threshold in R, G, AND B should be discarded
int_grayRange = [0.05,0.5];
belowShelf_grayRange = [0.08,0.5];

BGdiff_thresh = 0.015;
relBGdiff_thresh = [0.08,0.04];

min_abs_grDiff = [0.02,0.03];
min_abs_gbDiff = [0.02,0.02];
min_int_abs_grDiff = 0.03;
belowShelf_min_abs_grDiff = 0.01;

imDiff = imabsdiff(BGimg_ud,image_ud);
imDiffMask = imDiff(:,:,1) < BGdiff_thresh & ...
             imDiff(:,:,2) < BGdiff_thresh & ...
             imDiff(:,:,3) < BGdiff_thresh;
imDiffMask = ~imDiffMask;

min_gb_diff = [0.05,0.05];
min_gr_diff = [-0.05,0.05];

% min_internal_gr_diff = 0.1;
% min_internal_gb_diff = 0.06;

imFiltWidth = 5;

maxFrontPanelSep = 50;
maxDistBehindFrontPanel = 30;
maxDistPerFrame = 20;
shelfThick = 50;
frontPanelShadowWidth = 10;
% imadjust_dist = 75;               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


frontPanelMask = boxRegions.frontPanelMask;


intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
belowShelfMask = boxRegions.belowShelfMask;
shelfMask = boxRegions.shelfMask;
floorMask = boxRegions.floorMask;
slotMask = boxRegions.slotMask;

for iarg = 1 : 2 : nargin - 7
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
grayMask = cell(1,2);
dilated_bbox = zeros(2,4);
BGmask_ROI = cell(1,2);
BGdiff_mask_ROI = cell(1,2);
BG_relRGBdiff = cell(1,2);
BG_ROI = cell(1,2);
relBG_ROI = cell(1,2);

filt_im = imboxfilt(image_ud,imFiltWidth);
relRGB = relativeRGB(filt_im);
rel_r = relRGB(:,:,1); rel_g = relRGB(:,:,2); rel_b = relRGB(:,:,3);
rel_gr_diff = rel_g - rel_r; rel_gb_diff = rel_g - rel_b;
rel_gr_diff_clipped = rel_gr_diff; rel_gb_diff_clipped = rel_gb_diff;
rel_gr_diff_clipped(rel_gr_diff_clipped < 0) = 0;
rel_gb_diff_clipped(rel_gb_diff_clipped < 0) = 0;
gr_dist = sqrt(rel_gr_diff_clipped .^2 + rel_gb_diff_clipped.^2);
lh_direct = stretchlim(gr_dist,[0.002,0.998]);
lh_mirror = stretchlim(gr_dist,[0.002,0.998]);
gr_dist_adj_direct = imadjust(gr_dist,lh_direct);
gr_dist_adj_mirror = imadjust(gr_dist,lh_mirror);

for ii = 2 : -1 : 1
    temp = regionprops(bwconvhull(prevMask{ii},'union'),'BoundingBox');
    prev_bbox(ii,:) = round(temp.BoundingBox);
    dilated_bbox(ii,1:2) = [max(prev_bbox(ii,1)-maxDistPerFrame, 1),...
                            max(prev_bbox(ii,2)-maxDistPerFrame, 1)];
    dilated_bbox(ii,3:4) = [min(prev_bbox(ii,3)+(2*maxDistPerFrame),w-dilated_bbox(ii,1)),...
                            min(prev_bbox(ii,4)+(2*maxDistPerFrame),h-dilated_bbox(ii,2))];

% 	if ii == 1
%         dilated_bbox(ii,4) = dilated_bbox(ii,4) + 100;
%         dilated_bbox(ii,1) = dilated_bbox(ii,1) - 50;
%         dilated_bbox(ii,3) = dilated_bbox(ii,3) + 50;
%     end
    if ii == 2   
        
        if strcmpi(pawPref,'left')
            SE = [ones(1,maxDistBehindFrontPanel),zeros(1,maxDistBehindFrontPanel)];
        else
            SE = [zeros(1,maxDistBehindFrontPanel),ones(1,maxDistBehindFrontPanel)];
        end
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

                    temp_prevMask_dilate = imdilate(prevMask{2}, SE);
                    prevMask_dilate = prevMask_dilate | temp_prevMask_dilate;
%                     prevMask_dilate = imdilate(prevMask_dilate, SE);
                else
                    % extend the bounding box forward by maxFrontPanelSep
                    dilated_bbox(2,3) = min(dilated_bbox(2,3) + maxFrontPanelSep, w-dilated_bbox(2,1));

                    % extend prevMask_dilate forward by maxFrontPanelSep
                    SE = [zeros(1,maxFrontPanelSep+maxDistPerFrame),ones(1,maxFrontPanelSep+maxDistPerFrame)];

                    temp_prevMask_dilate = imdilate(prevMask{2}, SE);
                    prevMask_dilate = prevMask_dilate | temp_prevMask_dilate;
%                     prevMask_dilate = imdilate(prevMask_dilate, SE);
                end
            end
            if prev_pawOut == false
                if strcmpi(pawPref,'left')
                    % extend the bounding box forward by maxFrontPanelSep
                    dilated_bbox(2,3) = min(dilated_bbox(2,3) + maxFrontPanelSep, w-dilated_bbox(2,1));

                    % extend prevMask_dilate forward by maxFrontPanelSep
                    SE = [zeros(1,maxFrontPanelSep+maxDistPerFrame),ones(1,maxFrontPanelSep+maxDistPerFrame)];

                    temp_prevMask_dilate = imdilate(prevMask{2}, SE);
                    prevMask_dilate = prevMask_dilate | temp_prevMask_dilate;
%                     prevMask_dilate = imdilate(prevMask_dilate, SE);
                else
                    % extend the bounding box backward by maxFrontPanelSep
                    dilated_bbox(2,1) = max(dilated_bbox(2,1) - maxFrontPanelSep, 1);
                    dilated_bbox(2,3) = min(dilated_bbox(2,3) + maxFrontPanelSep, w-dilated_bbox(2,1));

                    % extend prevMask_dilate back by maxFrontPanelSep
                    SE = [ones(1,maxFrontPanelSep+maxDistPerFrame),zeros(1,maxFrontPanelSep+maxDistPerFrame)];

                    temp_prevMask_dilate = imdilate(prevMask{2}, SE);
                    prevMask_dilate = prevMask_dilate | temp_prevMask_dilate;
%                     prevMask_dilate = imdilate(prevMask_dilate, SE);
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
    

%     cur_ROI{ii} = image_ud(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3),:);
%     cur_ROI{ii} = imboxfilt(cur_ROI{ii},imFiltWidth);
    cur_ROI{ii} = filt_im(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3),:);
    BGdiff_mask_ROI{ii} = imDiffMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    prev_mask_dilate_ROI{ii} = prevMask_dilate(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
%     im_relRGB{ii} = relativeRGB(cur_ROI{ii});
    im_relRGB{ii} = relRGB(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3),:);
    BG_ROI{ii} = BGimg_ud(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3),:);
    BG_ROI{ii} = imboxfilt(BG_ROI{ii},imFiltWidth);
    relBG_ROI{ii} = relativeRGB(BG_ROI{ii});
    BGmask_ROI{ii} = greenBGmask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    BG_relRGBdiff{ii} = imabsdiff(im_relRGB{ii},relBG_ROI{ii});
    frontPanelMask_ROI = frontPanelMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
%     shelfMask_ROI = shelfMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    

    rel_r_ROI = im_relRGB{ii}(:,:,1);
    rel_g_ROI = im_relRGB{ii}(:,:,2);
    rel_b_ROI = im_relRGB{ii}(:,:,3);
    
    abs_grdiff = cur_ROI{ii}(:,:,2) - cur_ROI{ii}(:,:,1);
    abs_gbdiff = cur_ROI{ii}(:,:,2) - cur_ROI{ii}(:,:,3);
    
    abs_grdiffMask = abs_grdiff > min_abs_grDiff(ii);
    abs_gbdiffMask = abs_gbdiff > min_abs_gbDiff(ii);
    
    gr_diff_ROI = rel_g_ROI - rel_r_ROI;
    gb_diff_ROI = rel_g_ROI - rel_b_ROI;
    
    grMask = gr_diff_ROI > min_gr_diff(ii);
    gbMask = gb_diff_ROI > min_gb_diff(ii);
    
%     gr_diff_clipped = gr_diff;
%     gb_diff_clipped = gb_diff;
%     gr_diff_clipped(gr_diff < 0) = 0;
%     gb_diff_clipped(gb_diff < 0) = 0;
    
%     grDist_ROI = sqrt(gr_diff_clipped.^2 + gb_diff_clipped.^2);
    grDist_ROI = gr_dist(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    if ii == 1
        grDist_adj_ROI = gr_dist_adj_direct(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    else
        grDist_adj_ROI = gr_dist_adj_mirror(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
    end
    belowShelf_ROI = belowShelfMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));

    gray_img = rgb2gray(cur_ROI{ii});
    
    if ii == 2
        intMask = intMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
        extMask = extMask(dilated_bbox(ii,2):dilated_bbox(ii,2)+dilated_bbox(ii,4),dilated_bbox(ii,1):dilated_bbox(ii,1)+dilated_bbox(ii,3));
        
        int_frontPanel_neighbors = imdilate(frontPanelMask_ROI,strel('disk',frontPanelShadowWidth));
        int_frontPanel_neighbors = int_frontPanel_neighbors & intMask;
        
        if any(intMask(:))% && any(frontPanelMask_ROI(:))
            grayMask_ext = (gray_img > grayRange(ii,1)) & (gray_img < grayRange(ii,2)) & extMask;
            grayMask_int = (gray_img > int_grayRange(1)) & (gray_img < int_grayRange(2)) & intMask;
            grayMask{ii} = grayMask_ext | grayMask_int;
            
            abs_grdiffMask_int = (abs_grdiff > min_int_abs_grDiff) & intMask;
            int_tempMask_res = (grDist_adj_ROI > int_grDistThresh_res) & grMask & gbMask & BGdiff_mask_ROI{ii} & abs_grdiffMask_int & grayMask_int; %int_frontPanel_neighbors;
            int_tempMask_lib = (grDist_adj_ROI > int_grDistThresh_lib) & grMask & gbMask & BGdiff_mask_ROI{ii} & abs_grdiffMask_int & grayMask_int; % & int_frontPanel_neighbors & grayMask_int;
            int_tempMask = imreconstruct(int_tempMask_res, int_tempMask_lib);
        else
            int_tempMask = false(size(intMask));
            grayMask{ii} = (gray_img > grayRange(ii,1)) & (gray_img < grayRange(ii,2));
        end
%         
        prevMask_int = prev_mask_dilate_ROI{ii} & intMask;
%         
%         int_grMask = gr_diff > min_internal_gr_diff;
%         int_gbMask = gb_diff > min_internal_gb_diff;
%         intPawTest = int_grMask & int_gbMask & intMask & ~drkmsk{ii};
%         if any(frontPanelMask_ROI(:)) && any(intPawTest(:))  % the front panel is included in the image, and there are candidate green points inside the box.
%                                                              % Therefore, the paw may be both inside and outside the box.
%             int_grDist = grDist .* double(intMask);
%             int_grDist_adj = imadjust(int_grDist);
%             grDist_adj(intMask) = int_grDist_adj(intMask);
%         end
        belowShelf_tempMask = false(size(grayMask{ii}));
    else
        grayMask{ii} = (gray_img > grayRange(ii,1)) & (gray_img < grayRange(ii,2));
        int_tempMask = false(size(grayMask{ii}));
        if any(belowShelf_ROI(:)) %&& any(shelfMask_ROI(:))
            belowShelfGrayMask = (gray_img > belowShelf_grayRange(1)) & (gray_img < belowShelf_grayRange(2));
            belowShelf_abs_grDiffMask = (abs_grdiff > belowShelf_min_abs_grDiff);
            belowShelf_tempMask_res = belowShelf_ROI & (grDist_adj_ROI > belowShelfThresh_res) & belowShelf_abs_grDiffMask & belowShelfGrayMask;
            belowShelf_tempMask_lib = belowShelf_ROI & (grDist_adj_ROI > belowShelfThresh_lib) & belowShelf_abs_grDiffMask & belowShelfGrayMask;
            belowShelf_tempMask = imreconstruct(belowShelf_tempMask_res,belowShelf_tempMask_lib);
        else
            belowShelf_tempMask = false(size(grayMask{ii}));
        end
    end

    tempMask_res = (grDist_adj_ROI > grDistThresh_res(ii)) & grMask & gbMask & BGdiff_mask_ROI{ii} & abs_grdiffMask;
    tempMask_lib = (grDist_adj_ROI > grDistThresh_lib(ii)) & grMask & gbMask & BGdiff_mask_ROI{ii} & abs_grdiffMask;
    tempMask = imreconstruct(tempMask_res,tempMask_lib);
    if ii == 2
        tempMask_int = tempMask & intMask;
        tempMask_ext = tempMask & extMask;
        extMask_border = bwmorph(tempMask_ext,'remove');
        if any(tempMask_ext(:)) && any(tempMask_int(:))
            [y,~] = find(extMask_border);
            min_y = min(y);
            max_y = max(y);
            extMask_proj = false(size(tempMask_int));
            extMask_proj(min_y:max_y,1:end) = true;
            behindPanelMask = behindPanelMask & extMask_proj;
        end
        current_grayMask = grayMask{2} | behindPanelMask;
    else
        current_grayMask = grayMask{ii};
    end
    % this weird repeat is to make sure the "restrictive" mask does not
    % incude values outside the gray range
    tempMask_res = (grDist_adj_ROI > grDistThresh_res(ii)) & grMask & gbMask & BGdiff_mask_ROI{ii} & abs_grdiffMask & current_grayMask;
    tempMask_lib = (grDist_adj_ROI > grDistThresh_lib(ii)) & grMask & gbMask & BGdiff_mask_ROI{ii} & abs_grdiffMask & current_grayMask;

    tempMask = imreconstruct(tempMask_res,tempMask_lib) | int_tempMask | belowShelf_tempMask;
%     tempMask = tempMask & current_grayMask;
%     if ii == 2
        tempMask = tempMask & ~BGmask_ROI{ii};
%     end
%     tempMask = tempMask & prev_mask_dilate_ROI{ii};
%     
%     tempMask = processMask(tempMask,'sesize',2);
    
%     if ii == 2
%         tempMask_ext = tempMask & extMask;
%         
%         tempMask_ext_dilate = imdilate(tempMask_ext, strel('disk',5));
%         frontPanelTest = tempMask_ext_dilate & frontPanelMask_ROI;
%         if any(tempMask_ext(:)) && ~any(frontPanelTest(:)) && ~any(prevMask_int(:))    % if part of the paw is external to the box AND far enough away from the front panel that there shouldn't be any part on the inside
%             tempMask_int = false(size(tempMask));
%         else
%             tempMask_int = tempMask & intMask;
%         end
%         extMask_border = bwmorph(tempMask_ext,'remove');
%         if any(tempMask_ext(:)) && any(tempMask_int(:))   % make sure internal mask bits aren't wildly misaligned with the paw detected outside the box
%             [y,~] = find(extMask_border);
%             min_y = min(y);
%             max_y = max(y);
%             extMask_proj = false(size(tempMask_int));
%             extMask_proj(min_y:max_y,1:end) = true;
%             behindPanelMask = behindPanelMask & extMask_proj;
%             current_grayMask = grayMask{2} & behindPanelMask;
%             
%             relBGdiffMask = BG_relRGBdiff{ii} > relBGdiff_thresh(ii);
%             relBGdiffMask = relBGdiffMask(:,:,1) | relBGdiffMask(:,:,2) | relBGdiffMask(:,:,3);
%             intMask_overlap = imdilate(extMask_proj,strel('disk',10)) & tempMask_int & current_grayMask & relBGdiffMask;
% %             intMask_overlap = processMask(intMask_overlap,'sesize',1);
%             newMask_int = imreconstruct(intMask_overlap, tempMask_int);
% 
%             tempMask = tempMask_ext | newMask_int;
%         else
%             tempMask = tempMask_ext | tempMask_int;
%         end
%     else
% %         relBGdiffMask = BG_relRGBdiff{ii} > relBGdiff_thresh(ii);
% %         relBGdiffMask = relBGdiffMask(:,:,1) | relBGdiffMask(:,:,2) | relBGdiffMask(:,:,3);
%         
% %         tempMask = tempMask & relBGdiffMask;
%     end
        

    if ii == 2
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