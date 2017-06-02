function greenBGmask = findGreenBG_relRGB(BGimg_ud, boxRegions, pawPref, boxCalibration, varargin)

w = size(BGimg_ud,2);h = size(BGimg_ud,1);

ROIheight = 150;    % in pixels - how high above the shelf to look for the paw
ROI_dist_from_slot = 50;

belowShelfDist = 50;
behindPanelDist = 20;
inFrontPanelDist = 20;

maxFrontPanelSep = 20;

min_gb_diff = 0.05;
min_gr_diff = 0.1;

drkThresh = 0.5;    % exclude pixels with RGB values all below this value
imFiltWidth = 5;
grDistThresh = 0.15;

srCal = boxCalibration.srCal;

if isa(BGimg_ud,'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

frontPanelMask = boxRegions.frontPanelMask;
shelfMask = boxRegions.shelfMask;
slotMask = boxRegions.slotMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
intMask = boxRegions.intMask;

shelfLims = regionprops(shelfMask,'boundingbox');
slotLims = regionprops(slotMask,'boundingbox');

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
        
        frontPanelEdge = leftFrontEdge;
        fundMat = srCal.F(:,:,1);
%         mirror_mask = leftMirrorGreen;
        
%         SE_fromExt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
%         overlapCheck_SE_fromExt = [zeros(1,5),ones(1,5)];
        
        ROI = [direct_left,direct_top,direct_width,direct_height;...
               mirror_left,mirror_top,mirror_width,mirror_height];
end

ROImask = false(h,w);
for ii = 1 : 2
    ROImask(ROI(ii,2):ROI(ii,2)+ROI(ii,4), ...
            ROI(ii,1):ROI(ii,1)+ROI(ii,3)) = true;
end

filt_BG = imboxfilt(BGimg_ud, imFiltWidth);
rel_im = relativeRGB(filt_BG);

drkmsk = filt_BG(:,:,1) < drkThresh & ...
         filt_BG(:,:,2) < drkThresh & ...
         filt_BG(:,:,3) < drkThresh;
    
gr_diff = rel_im(:,:,2) - rel_im(:,:,1);
gb_diff = rel_im(:,:,2) - rel_im(:,:,3);

gr_diff(gr_diff<0) = 0;
gb_diff(gb_diff<0) = 0;

grMask = gr_diff > min_gr_diff;
gbMask = gb_diff > min_gb_diff;
    
grDist = sqrt(gr_diff.^2 + gb_diff.^2);

greenBGmask = (grDist > grDistThresh);
greenBGmask = greenBGmask & grMask & gbMask;
greenBGmask = greenBGmask & ~drkmsk;

greenBGmask = greenBGmask & ROImask;
% 
% if ~isempty(mean_img)
%     % look for green marks that may have been hidden behind the pellet in
%     % the background image
%     direct_str_gray = rgb2gray(direct_str_img);
%     direct_whiteMask = (direct_str_gray > whiteThresh);
%     whiteMask = false(h,w);
%     whiteMask(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3)) = direct_whiteMask;
%     direct_mean_img_ud = mean_img(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:);
%     other_mirror_mean_img_ud = mean_img(ROI(3,2):ROI(3,2)+ROI(3,4),ROI(3,1):ROI(3,1)+ROI(3,3),:);
%     lh_mean  = stretchlim(other_mirror_mean_img_ud,0.05);
%     mean_direct_str_img = imadjust(direct_mean_img_ud,lh_mean,[]);
%     mean_direct_green = decorrstretch(mean_direct_str_img,'tol',0.02);
%     
%     decorr_mean = mean_img;
%     decorr_mean(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:) = mean_direct_green;
%     mean_hsv = rgb2hsv(decorr_mean);
%     meanBGmask = HSVthreshold(mean_hsv, meanHSVrange);
%     meanBGmask = meanBGmask & whiteMask;
% else
%     meanBGmask = false(h,w);
% end
%     
% direct_green = decorrstretch(direct_str_img,'tol',0.02);
% mirror_green = decorrstretch(mirror_str_img,'tol',0.02);
% decorr_BG = BGimg_ud;
% decorr_BG(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:) = mirror_green;
% decorr_BG(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:) = direct_green;
% 
% % slotMask = boxRegions.slotMask;
% % slotMask = imdilate(slotMask,strel('line',6,0)) | imdilate(slotMask,strel('line',6,180));
% % decorr_BG = decorrstretch(BGimg_ud,'targetmean',targetMean,'targetsigma',targetSigma);
% BGhsv = rgb2hsv(decorr_BG);
% 
% greenBGmask = HSVthreshold(BGhsv, pawHSVrange);
% greenBGmask = greenBGmask | meanBGmask;
% % greenBGmask = greenBG & slotMask;
% 
% end