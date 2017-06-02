function initPawMask = find_initPawMask_greenPaw_relRGB_20170208( image_ud, BGimg_ud, sr_ratInfo, session_mp, boxCalibration, boxRegions, greenBGmask, varargin )

h = size(image_ud,1);
w = size(image_ud,2);

drkThresh = [0.05,0.05];    % exclude pixels with RGB values all below this value
imFiltWidth = 5;

maxFrontPanelSep = 20;
max_img_bgDiff = 0.01;

if isa(BGimg_ud,'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end
if isa(image_ud,'uint8')
    image_ud = double(image_ud) / 255;
end

imDiff = imabsdiff(image_ud,BGimg_ud);
imDiffMask = imDiff(:,:,1) < max_img_bgDiff & ...
             imDiff(:,:,2) < max_img_bgDiff & ...
             imDiff(:,:,3) < max_img_bgDiff;
imDiffMask = ~imDiffMask;

relBGthresh = [0.05,0.05];

grDistThresh_res = [0.8,0.7];
grDistThresh_lib = [0.5,0.5];

min_internal_gr_diff = 0.15;
min_internal_gb_diff = 0.06;

min_gb_diff = 0.05;
min_gr_diff = 0.05;

min_abs_gb_diff = 0.0;
min_abs_gr_diff = 0.0;

ROIheight = 150;    % in pixels - how high above the shelf to look for the paw
ROI_dist_from_slot = 50;

belowShelfDist = 50;
behindPanelDist = 150;
inFrontPanelDist = 200;
maxDistBehindFrontPanel = 15;

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'imfiltwidth'
            imFiltWidth = varargin{iarg + 1};
    end
end

% filtBG = imboxfilt(BGimg_ud,imFiltWidth);
% relBG = relativeRGB(filtBG);

frontPanelMask = boxRegions.frontPanelMask;
% shelfMask = boxRegions.shelfMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
intMask = boxRegions.intMask;
extMask = boxRegions.extMask;

shelfMask = boxRegions.shelfMask;
% extMask = boxRegions.extMask;
slotMask = boxRegions.slotMask;
floorMask = boxRegions.floorMask;
[y,~] = find(floorMask);
ROI_bot = min(y);

[~,x] = find(shelfMask);
centerPoly_x = [min(x),max(x),max(x),min(x),min(x)];
centerPoly_y = [1,1,h,h,1];
centerMask = poly2mask(centerPoly_x,centerPoly_y,h,w);
centerMask = imdilate(centerMask,strel('line',100,0));
belowShelfMask = boxRegions.belowShelfMask;

shelfLims = regionprops(shelfMask,'boundingbox');
slotLims = regionprops(slotMask,'boundingbox');

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

srCal = boxCalibration.srCal;
% cameraParams = boxCalibration.cameraParams;

leftFrontPanelMask = false(h,w);
rightFrontPanelMask = false(h,w);
leftFrontEdge = false(h,w);
rightFrontEdge = false(h,w);

leftFrontPanelMask(1:h,1:round(w/2)) = frontPanelMask(1:h,1:round(w/2));
rightFrontPanelMask(1:h,round(w/2):end) = frontPanelMask(1:h,round(w/2):end);
leftFrontEdge(1:h,1:round(w/2)) = frontPanelEdge(1:h,1:round(w/2));
rightFrontEdge(1:h,round(w/2):end) = frontPanelEdge(1:h,round(w/2):end);

direct_top = round(shelfLims.BoundingBox(2) - ROIheight);
direct_height = round(ROIheight+shelfLims.BoundingBox(4) + belowShelfDist);
direct_left = round(slotLims.BoundingBox(1) - ROI_dist_from_slot);
direct_width = round(slotLims.BoundingBox(3) + 2*ROI_dist_from_slot);
directMask = false(h,w);
directMask(direct_top:direct_top+direct_height,direct_left:direct_left+direct_width) = true;
mirrorMask = false(h,w);
switch pawPref
    case 'left'
        fundMat = srCal.F(:,:,2);
        
        projMask = calcProjMask(directMask, fundMat, [1,1,w-1,h-1],[h,w]);
        
        frontPanelMask = rightFrontPanelMask;    % right mirror
        frontPanelLims = regionprops(frontPanelMask,'boundingbox');
        
        mirror_left = round(frontPanelLims.BoundingBox(1) - behindPanelDist);
        mirror_right = round(frontPanelLims.BoundingBox(1) + frontPanelLims.BoundingBox(3) + inFrontPanelDist);
        mirror_right = min(mirror_right, w);
        mirror_width = mirror_right - mirror_left;
        
        mirrorMask(1:h,mirror_left:mirror_left+mirror_width) = true;
        mirrorMask = mirrorMask & projMask;
        mirrorLims = regionprops(mirrorMask,'boundingbox');
        mirror_top = round(mirrorLims.BoundingBox(2));
        mirror_height = round(mirrorLims.BoundingBox(4));
        
        SE = [ones(1,maxDistBehindFrontPanel),zeros(1,maxDistBehindFrontPanel)];
%         mirror_mask = rightMirrorGreen;
        
%         SE_fromExt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
%         overlapCheck_SE_fromExt = [ones(1,5),zeros(1,5)];
        
        ROI = [direct_left,direct_top,direct_width,direct_height;...
               mirror_left,mirror_top,mirror_width,mirror_height];
           
    case 'right'
        fundMat = srCal.F(:,:,1);
        
        projMask = calcProjMask(directMask, fundMat, [1,1,w-1,h-1],[h,w]);
        
        frontPanelMask = leftFrontPanelMask;    % left mirror
        frontPanelLims = regionprops(frontPanelMask,'boundingbox');
        
        mirror_right = round(frontPanelLims.BoundingBox(1)+frontPanelLims.BoundingBox(3)+behindPanelDist);
        mirror_left = round(frontPanelLims.BoundingBox(1) - inFrontPanelDist);
        mirror_left = max(mirror_left,1);
        mirror_width = mirror_right - mirror_left;
        
        mirrorMask(1:h,mirror_left:mirror_left+mirror_width) = true;
        mirrorMask = mirrorMask & projMask;
        mirrorLims = regionprops(mirrorMask,'boundingbox');
        mirror_top = round(mirrorLims.BoundingBox(2));
        mirror_height = round(mirrorLims.BoundingBox(4));
        
        SE = [zeros(1,maxDistBehindFrontPanel),ones(1,maxDistBehindFrontPanel)];
%         mirror_mask = leftMirrorGreen;
        
%         SE_fromExt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
%         overlapCheck_SE_fromExt = [zeros(1,5),ones(1,5)];
        
        ROI = [direct_left,direct_top,direct_width,direct_height;...
               mirror_left,mirror_top,mirror_width,mirror_height];
end
behindPanelMask = imdilate(frontPanelMask,SE) & ~frontPanelMask;
behindPanelMask = behindPanelMask(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3));

filt_im = imboxfilt(image_ud,imFiltWidth);
rel_im = relativeRGB(filt_im);
% rel_grdiff = rel_im(:,:,2) - rel_im(:,:,1);
% rel_gbdiff = rel_im(:,:,2) - rel_im(:,:,3);

view_rel_grdiff = cell(1,2);
view_rel_gbdiff = cell(1,2);
% view_gr_thresh_img = cell(1,2);
% view_gb_thresh_img = cell(1,2);
% l_gr = zeros(1,2);
% l_gb = zeros(1,2);
grMask = cell(1,2);
gbMask = cell(1,2);
% view_im = cell(1,2);
drkmsk = cell(1,2);
tempMask = cell(1,2);
newMask = cell(1,2);
% relBG_ROI = cell(1,2);
% im_relRGB = cell(1,2);
% BGmask = cell(1,2);
for iView = 1 : 2
    filt_im_ROI = filt_im(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                          ROI(iView,1):ROI(iView,1)+ROI(iView,3),:);
                      
	abs_gr_diff = filt_im_ROI(:,:,2) - filt_im_ROI(:,:,1);
    abs_gb_diff = filt_im_ROI(:,:,2) - filt_im_ROI(:,:,3);
    
    abs_grMask = abs_gr_diff > min_abs_gr_diff;
    abs_gbMask = abs_gb_diff > min_abs_gb_diff;
    
	rel_im_ROI = relativeRGB(filt_im_ROI);
    
    BG_ROI = BGimg_ud(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                          ROI(iView,1):ROI(iView,1)+ROI(iView,3),:);
	filt_BG_ROI = imboxfilt(BG_ROI,imFiltWidth);
    rel_filt_BG_ROI = relativeRGB(filt_BG_ROI);
    relBGdiff = imabsdiff(rel_filt_BG_ROI,rel_im_ROI);
    
    relBGMask = relBGdiff(:,:,1) < relBGthresh(iView) & ...
                relBGdiff(:,:,2) < relBGthresh(iView) & ...
                relBGdiff(:,:,3) < relBGthresh(iView);
	relBGMask = ~relBGMask;
    
    view_rel_grdiff{iView} = rel_im_ROI(:,:,2) - rel_im_ROI(:,:,1);
    view_rel_gbdiff{iView} = rel_im_ROI(:,:,2) - rel_im_ROI(:,:,3);
    greenBGmask_ROI = greenBGmask(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                                  ROI(iView,1):ROI(iView,1)+ROI(iView,3));

                                    
    view_rel_grdiff{iView}(view_rel_grdiff{iView} < 0) = 0;
    view_rel_gbdiff{iView}(view_rel_grdiff{iView} < 0) = 0;
                                    
    grDist = sqrt(view_rel_grdiff{iView}.^2 + view_rel_gbdiff{iView}.^2);
    grDist_adj = imadjust(grDist);
    
% 	view_im{iView} = filt_im(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
%                              ROI(iView,1):ROI(iView,1)+ROI(iView,3),:);
	drkmsk{iView} = filt_im_ROI(:,:,1) < drkThresh(iView) & ...
                    filt_im_ROI(:,:,2) < drkThresh(iView) & ...
                    filt_im_ROI(:,:,3) < drkThresh(iView);
                
% 	im_relRGB{iView} = rel_im(ROI(iView,2):ROI(iView,2)+ROI(iView,4),ROI(iView,1):ROI(iView,1)+ROI(iView,3),:);
                
    if iView == 2
        frontPanelMask_ROI = frontPanelMask(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                                            ROI(iView,1):ROI(iView,1)+ROI(iView,3));
        intMask = intMask(ROI(iView,2):ROI(iView,2)+ROI(iView,4),ROI(iView,1):ROI(iView,1)+ROI(iView,3));
        int_grMask = view_rel_grdiff{iView} > min_internal_gr_diff;
        int_gbMask = view_rel_gbdiff{iView} > min_internal_gb_diff;
        intPawTest = int_grMask & int_gbMask & intMask & ~drkmsk{iView};
        if any(frontPanelMask_ROI(:)) && any(intPawTest(:))   % the front panel is included in the image, and the paw may be both inside and outside the box
            int_grDist = grDist .* double(intMask);
            int_grDist_adj = imadjust(int_grDist);
            grDist_adj(intMask) = int_grDist_adj(intMask);
        end
    end
    
    grMask{iView} = view_rel_grdiff{iView} > min_gr_diff;
    gbMask{iView} = view_rel_gbdiff{iView} > min_gb_diff;
    
    tempMask_res = (grDist_adj > grDistThresh_res(iView)) & grMask{iView} & gbMask{iView} & ~drkmsk{iView} & abs_grMask & abs_gbMask;
%     tempMask_res = processMask(tempMask_res,'sesize',2);
    tempMask_lib = (grDist_adj > grDistThresh_lib(iView)) & grMask{iView} & gbMask{iView} & ~drkmsk{iView} & abs_grMask & abs_gbMask;
    tempMask{iView} = imreconstruct(tempMask_res,tempMask_lib) & ~greenBGmask_ROI;
    
%     tempMask{iView} = grMask{iView} & gbMask{iView} & ~drkmsk{iView} & ~greenBGmask_ROI;
    tempMask{iView} = tempMask{iView} & relBGMask;
    tempMask{iView} = processMask(tempMask{iView},2);
    
    if iView == 2
        extMask = extMask(ROI(iView,2):ROI(iView,2)+ROI(iView,4),ROI(iView,1):ROI(iView,1)+ROI(iView,3));
        tempMask_ext = tempMask{iView} & extMask;
        
%         behindPanelMask = imdilate(frontPanelMask,SE) & ~frontPanelMask;
        
        tempMask_ext_dilate = imdilate(tempMask_ext, strel('disk',5));
        frontPanelTest = tempMask_ext_dilate & frontPanelMask_ROI;
        
        if any(tempMask_ext(:)) && ~any(frontPanelTest(:))   % if part of the paw is external to the box AND far enough away from the front panel that there shouldn't be any part on the inside
            tempMask_int = false(size(tempMask{iView}));
        else
            tempMask_int = tempMask{iView} & intMask;
        end
        extMask_border = bwmorph(tempMask_ext,'remove');
        
        if any(tempMask_ext(:)) && any(tempMask_int(:))   % make sure internal mask bits aren't wildly misaligned with the paw detected outside the box
            [y,~] = find(extMask_border);
            min_y = min(y);
            max_y = max(y);
            extMask_proj = false(size(tempMask_int));
            extMask_proj(min_y:max_y,1:end) = true;
            behindPanelMask = behindPanelMask & extMask_proj;
            current_drkmsk = drkmsk{2} & ~behindPanelMask;
            
            intMask_overlap = extMask_proj & tempMask_int & ~current_drkmsk;
            intMask_overlap = processMask(intMask_overlap,'sesize',2);
            newMask_int = imreconstruct(intMask_overlap, tempMask_int);

            tempMask{iView} = tempMask_ext | newMask_int;
        else
            tempMask{iView} = tempMask_ext | tempMask_int;
        end
    end
    
    newMask{iView} = false(h,w);
    
    newMask{iView}(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                   ROI(iView,1):ROI(iView,1)+ROI(iView,3)) = tempMask{iView};
	newMask{iView} = newMask{iView} & imDiffMask;
end
newMask{2} = newMask{2} & ~frontPanelMask;

initPawMask = newMask;
if any(newMask{1}(:)) && any(newMask{2}(:))
    initPawMask = maskProjectionBlobs(newMask,[1,1,w-1,h-1;1,1,w-1,h-1],fundMat,[h,w]);
end

% rel_im_dstr = decorrstretch(rel_im,'tol',0.01);
% rel_im_hsv = rgb2hsv(rel_im_dstr);
% drk_mask = true(h,w);
% for ii = 1  : 3
%     drk_mask = drk_mask & (image_ud(:,:,ii) < drkThresh);
% end
% 
% grn_mask = HSVthreshold(rel_im_hsv,[1/3,0.03,0.9,1.0,0.9,1.0]);
% 
% grn_mask = grn_mask & ~drk_mask;
% grn_mask = processMask(grn_mask,'sesize',2);
% 
% leftMirrorGreen = leftMirrorMask & grn_mask;
% rightMirrorGreen = rightMirrorMask & grn_mask;
% directGreen = directMask & grn_mask;
% 
% 
% 
% 
%       
% mirror_projMask = projMaskFromTangentLines(mirror_mask, fundMat, [1,1,h-1,w-1], [h,w]);
% 
% direct_proj_overlap = (directGreen & mirror_projMask);
% direct_proj_overlap = imreconstruct(direct_proj_overlap, directGreen);
% 
% initPawMask{1} = direct_proj_overlap;%bwconvhull(direct_proj_overlap,'union');
% initPawMask{2} = mirror_mask;
% 
% bbox = [1,1,w-1,h-1];
% bbox(2,:) = bbox;
% 
% 
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
