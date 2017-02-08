function initPawMask = find_initPawMask_greenPaw_relRGB( image_ud, BGimg_ud, sr_ratInfo, session_mp, boxCalibration, boxRegions, greenBGmask, varargin )

h = size(image_ud,1);
w = size(image_ud,2);

drkThresh = 0.05;    % exclude pixels with RGB values all below this value
imFiltWidth = 5;

maxFrontPanelSep = 20;

initPawMask = cell(1,2);

ROIheight = 150;    % in pixels - how high above the shelf to look for the paw
ROI_dist_from_slot = 50;
ROIwidth = 200;

belowShelfDist = 50;
behindPanelDist = 150;
inFrontPanelDist = 200;
directWidth = 250;    % in pixels

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'imfiltwidth'
            imFiltWidth = varargin{iarg + 1};
    end
end

filtBG = imboxfilt(BGimg_ud,imFiltWidth);
relBG = relativeRGB(filtBG);

frontPanelMask = boxRegions.frontPanelMask;
% shelfMask = boxRegions.shelfMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
intMask = boxRegions.intMask;

shelfMask = boxRegions.shelfMask;
% intMask = boxRegions.intMask;
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
cameraParams = boxCalibration.cameraParams;

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
        
        frontPanelEdge = rightFrontEdge;
        fundMat = srCal.F(:,:,2);
%         mirror_mask = rightMirrorGreen;
        
        SE_fromExt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [ones(1,5),zeros(1,5)];
        
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
        
        frontPanelEdge = leftFrontEdge;
        fundMat = srCal.F(:,:,1);
%         mirror_mask = leftMirrorGreen;
        
        SE_fromExt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [zeros(1,5),ones(1,5)];
        
        ROI = [direct_left,direct_top,direct_width,direct_height;...
               mirror_left,mirror_top,mirror_width,mirror_height];
end

% leftMirrorMask = false(h,w);
% shelf_bot = session_mp.leftMirror.left_back_shelf_corner(2)+20;
% shelf_top = shelf_bot - ROIheight;
% shelf_right = session_mp.leftMirror.left_back_shelf_corner(1)+20;
% shelf_left = max(1,shelf_right - ROIwidth);
% leftMirrorMask(shelf_top:shelf_bot,shelf_left:shelf_right) = true;
% 
% rightMirrorMask = false(h,w);
% shelf_bot = session_mp.rightMirror.right_back_shelf_corner(2)+40;
% shelf_top = shelf_bot - ROIheight;
% shelf_left = session_mp.rightMirror.right_back_shelf_corner(1)-40;
% shelf_right = min(w,shelf_left + ROIwidth);
% rightMirrorMask(shelf_top:shelf_bot,shelf_left:shelf_right) = true;
% 
% directMask = false(h,w);
% shelf_left = session_mp.direct.left_back_shelf_corner(1);
% shelf_right = session_mp.direct.right_back_shelf_corner(1);
% shelf_bot = session_mp.direct.left_bottom_shelf_corner(2);
% shelf_top = shelf_bot - 200;
% direct_left = round((shelf_left+shelf_right)/2 - directWidth/2);
% direct_right = direct_left + directWidth;
% directMask(shelf_top:shelf_bot,direct_left:direct_right) = true;



% video.CurrentTime = triggerTime;
% image = readFrame(video);
% if strcmpi(class(image),'uint8')
%     image = double(image) / 255;
% end
% image_ud = undistortImage(image, cameraParams);
filt_im = imboxfilt(image_ud,imFiltWidth);
rel_im = relativeRGB(filt_im);
rel_grdiff = rel_im(:,:,2) - rel_im(:,:,1);
rel_gbdiff = rel_im(:,:,2) - rel_im(:,:,3);

view_rel_grdiff = cell(1,2);
view_rel_gbdiff = cell(1,2);
view_gr_thresh_img = cell(1,2);
view_gb_thresh_img = cell(1,2);
l_gr = zeros(1,2);
l_gb = zeros(1,2);
grMask = cell(1,2);
gbMask = cell(1,2);
view_im = cell(1,2);
drkmsk = cell(1,2);
tempMask = cell(1,2);
newMask = cell(1,2);
relBG_ROI = cell(1,2);
im_relRGB = cell(1,2);
BGmask = cell(1,2);
for iView = 1 : 2
    view_rel_grdiff{iView} = rel_grdiff(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                                        ROI(iView,1):ROI(iView,1)+ROI(iView,3));
    view_rel_gbdiff{iView} = rel_gbdiff(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                                        ROI(iView,1):ROI(iView,1)+ROI(iView,3));
                                    
	view_im{iView} = filt_im(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                             ROI(iView,1):ROI(iView,1)+ROI(iView,3),:);
	drkmsk{iView} = view_im{iView}(:,:,1) < drkThresh & ...
                    view_im{iView}(:,:,2) < drkThresh & ...
                    view_im{iView}(:,:,3) < drkThresh;
                
	im_relRGB{iView} = rel_im(ROI(iView,2):ROI(iView,2)+ROI(iView,4),ROI(iView,1):ROI(iView,1)+ROI(iView,3),:);
                
    relBG_ROI{iView} = relBG(ROI(iView,2):ROI(iView,2)+ROI(iView,4),ROI(iView,1):ROI(iView,1)+ROI(iView,3),:);
	BGdiff = imabsdiff(relBG_ROI{iView},im_relRGB{iView});
    BGdiffmag = sqrt(sum(BGdiff.^2,3));
    BGadjust = imadjust(BGdiffmag);
    BGthresh = graythresh(BGadjust);
    BGmask{iView} = imbinarize(BGadjust,BGthresh);
                                    
	view_gr_thresh_img{iView} = imadjust(view_rel_grdiff{iView});
    view_gb_thresh_img{iView} = imadjust(view_rel_gbdiff{iView});
    
    l_gr(iView) = graythresh(view_gr_thresh_img{iView});
    l_gb(iView) = graythresh(view_gb_thresh_img{iView});
    
    grMask{iView} = view_gr_thresh_img{iView} > l_gr(iView);
    gbMask{iView} = view_gb_thresh_img{iView} > l_gb(iView);
    
    tempMask{iView} = grMask{iView} & gbMask{iView} & ~drkmsk{iView} & BGmask{iView};
    tempMask{iView} = processMask(tempMask{iView},2);
    
    newMask{iView} = false(h,w);
    
    newMask{iView}(ROI(iView,2):ROI(iView,2)+ROI(iView,4),...
                   ROI(iView,1):ROI(iView,1)+ROI(iView,3)) = tempMask{iView};
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
