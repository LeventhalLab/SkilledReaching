function [fullMask,greenMask] = trackNextStep_mirror_20160503_b( image_ud, BGimg_ud_str, fundMat, prevMask, boxRegions, pawPref, greenBGmask,varargin)

% CONSIDER SUBTRACTING EACH IMAGE FROM THE PREVIOUS ONE, USING THAT AS A
% BACKGROUND MASK EXCEPT IN THE IMMEDIATE VICINITY OF THE LAST PAW
% LOCATION?

h = size(image_ud,1); w = size(image_ud,2);

% targetMean = [0.5,0.3,0.5];
% targetSigma = [0.1,0.1,0.1];

maxFrontPanelSep = 20;
maxDistBehindFrontPanel = 20;
maxDistPerFrame = 20;

frontPanelMask = imdilate(boxRegions.frontPanelMask,strel('disk',2));
shelfMask = boxRegions.shelfMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxDistBehindFrontPanel)) & ~frontPanelMask;

whiteThresh = 0.7;
int_whiteThresh = 0.3;
libHSVthresh_ext_maxBW = 0.3;
blackThresh = 0.04;
diff_thresh = [0.2,0.2,0.2];

intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
floorMask = boxRegions.floorMask;
[y,~] = find(floorMask);
ROI_bot = min(y);

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'pawhsvrange',
            pawHSVrange = varargin{iarg + 1};
        case 'maxdistperframe',
            maxDistPerFrame = varargin{iarg + 1};
    end
end

shelfLims = regionprops(boxRegions.shelfMask,'boundingbox');
switch lower(pawPref),
    case 'right',
        ROI = [1,1,floor(shelfLims.BoundingBox(1)),ROI_bot;...
            ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot];
        SE_fromExt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+35)];
        SE_fromInt = [ones(1,maxFrontPanelSep+35),zeros(1,maxFrontPanelSep+25)];
        
        overlapCheck_SE_fromExt = [zeros(1,5),ones(1,5)];
        overlapCheck_SE_fromInt = [ones(1,15),zeros(1,15)];
%         ext_white_check_SE = [zeros(1,10),ones(1,10)];
    case 'left',
        ROI = [ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot;...
            1,1,floor(shelfLims.BoundingBox(1)),ROI_bot];
        SE_fromExt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
        SE_fromInt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [ones(1,5),zeros(1,5)];
        overlapCheck_SE_fromInt = [zeros(1,15),ones(1,15)];
%         ext_white_check_SE = [ones(1,10),zeros(1,10)];
end

vertSTREL = strel('line',15,90);
% lh  = stretchlim(image_ud(1:ROI_bot,:));
% str_img = imadjust(image_ud,lh,[]);

mirror_image_ud = image_ud(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:);
other_mirror_image_ud = image_ud(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:);
lh  = stretchlim(other_mirror_image_ud,0.05);
mirror_str_img = imadjust(mirror_image_ud,lh,[]);
% mirror_str_img = str_img(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);

% prev_mirror_image_ud = prev_image_ud(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);

prevMask = prevMask(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3));
frontPanelEdge = frontPanelEdge(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3));
frontPanelMask = frontPanelMask(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3));
extMask = extMask(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3));
intMask = intMask(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3));

prevMask_panel_dilate = prevMask;

dil_mask = imdilate(prevMask,overlapCheck_SE_fromExt) & ~prevMask;    % look to see if the paw is at the outside edge of the front panel
side_overlap_mask = dil_mask & frontPanelMask;
prevExtMask = prevMask & extMask;
prevIntMask = prevMask & intMask;
if any(side_overlap_mask(:)) && any(prevExtMask(:)) && ~any(prevIntMask(:))   % only extend the masked region behind the front panel if the paw
                                                                              % was entirely in the exterior region on the previous frame (there
                                                                              % will already be part of the mask on the inside if part of the 
                                                                              % previous paw detection was inside the box)
%     SE = strel('line',boxFrontThick+70,frontPanelFromExt_angle);
    prevMask_panel_dilate = imdilate(prevMask_panel_dilate, SE_fromExt);
    SE = strel('line',10,90);
    prevMask_panel_dilate = imdilate(prevMask_panel_dilate, SE);
%     SE = strel('line',10,270);
%     prevMask_panel_dilate = imdilate(prevMask_panel_dilate, SE);
end

dil_mask = imdilate(prevMask,overlapCheck_SE_fromInt) & ~prevMask;    % look to see if the paw is at the outside edge of the front panel
side_overlap_mask = dil_mask & frontPanelMask;
if any(side_overlap_mask(:)) && any(prevIntMask(:)) && ~any(prevExtMask(:))
%     SE = strel('line',boxFrontThick+70,frontPanelFromInt_angle);
    prevMask_panel_dilate = imdilate(prevMask_panel_dilate, SE_fromInt);
    SE = strel('line',10,90);
    prevMask_panel_dilate = imdilate(prevMask_panel_dilate, SE);
%     SE = strel('line',10,270);
%     prevMask_panel_dilate = imdilate(prevMask_panel_dilate, SE);
end

% [ye,xe] = find(extMask);
% [yi,xi] = find(intMask);
% decorr_green_ext = decorrstretch(mirror_image_ud,'tol',0.02,'samplesubs',{ye,xe});
% decorr_green_int = decorrstretch(mirror_image_ud,'tol',0.02,'samplesubs',{yi,xi});

% decorr_green_ext = decorrstretch(mirror_str_img,'tol',0.02,'samplesubs',{ye,xe});
% decorr_green_int = decorrstretch(mirror_str_img,'tol',0.02,'samplesubs',{yi,xi});
decorr_green = decorrstretch(mirror_str_img,'tol',0.02);%'targetsigma',targetSigma,'targetmean',targetMean);
BG_decorr_green = decorrstretch(BGimg_ud_str,'tol',0.02);%'targetsigma',targetSigma,'targetmean',targetMean);
decorr_diff = imabsdiff(BG_decorr_green, decorr_green);
mirror_greenBGmask = greenBGmask(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3));

% keep only the green bits in the external part or near the front panel in
% the mirror view
temp_greenBGmask = mirror_greenBGmask & imdilate(frontPanelMask, strel('disk',maxDistBehindFrontPanel));
mirror_greenBGmask = temp_greenBGmask | (mirror_greenBGmask & extMask);


BG_mask = ~(decorr_diff(:,:,1) < diff_thresh(1) & ...
            decorr_diff(:,:,2) < diff_thresh(2) & ...
            decorr_diff(:,:,3) < diff_thresh(3));
% lh = stretchlim(decorr_green);
% decorr_green = imadjust(decorr_green,lh,[]);

% mirror_decorr_green_hsv_ext = rgb2hsv(decorr_green_ext);
% mirror_decorr_green_hsv_int = rgb2hsv(decorr_green_int);
mirror_decorr_green_hsv = rgb2hsv(decorr_green);
mirror_decorr_green_hsv_ext = mirror_decorr_green_hsv;
mirror_decorr_green_hsv_int = mirror_decorr_green_hsv;

prevMask_dilate = imdilate(prevMask,strel('disk',maxDistPerFrame));
bright_im = imadjust(rgb2gray(mirror_str_img),[0.05,0.9]);
whiteMask = bright_im > whiteThresh;
blackMask = bright_im < blackThresh;

mirror_greenHSVthresh_ext = HSVthreshold(mirror_decorr_green_hsv_ext, pawHSVrange(1,:));
mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & ~whiteMask & ~blackMask;
mirror_greenHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv_int, pawHSVrange(3,:));
mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & ~whiteMask;
mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext;% & ~mirror_greenBGmask;
% mirror_greenHSVthresh_int = mirror_greenHSVthresh_int;% & ~mirror_greenBGmask;

mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & extMask & BG_mask;
mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & intMask & BG_mask;

mirror_greenHSVthresh_ext = processMask(mirror_greenHSVthresh_ext,'sesize',1);   % **** SESIZE USED TO BE 1, CHANGED IT TO 2 TO AVOID DETECTING GREEN TINGE ON THE PELLET 20180804
mirror_greenHSVthresh_int = processMask(mirror_greenHSVthresh_int,'sesize',1);

mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & (prevMask_dilate | prevMask_panel_dilate);
% mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & (prevMask_dilate | prevMask_panel_dilate);

% temp = mirror_greenHSVthresh_int & prevMask;
% 
% % CONSIDER WHETHER TO REMOVE THIS REQUIREMENT...MAYBE ONLY KEEP IT FOR THE
% % INSIDE?
% if any(temp(:))     % only keep points that overlap with the previous mask.
%                     % if somehow the paw moved so fast that there is no
%                     % overlap, just stick with what was previously found.
%     mirror_greenHSVthresh_int = temp;
% end
% temp = mirror_greenHSVthresh_ext & prevMask;
% if any(temp(:))     % only keep points that overlap with the previous mask.
%                     % if somehow the paw moved so fast that there is no
%                     % overlap, just stick with what was previously found.
%     mirror_greenHSVthresh_ext = temp;
% end

libHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv_int, pawHSVrange(4,:));
int_whiteMask = bright_im > int_whiteThresh;
libHSVthresh_int = libHSVthresh_int & intMask & ~int_whiteMask;% & BG_mask;% & ~whiteMask;
libHSVthresh_int = processMask(libHSVthresh_int,'sesize',2);
temp = libHSVthresh_int & (prevMask_dilate | prevMask_panel_dilate);
libHSVthresh_int = imreconstruct(temp, libHSVthresh_int);

libHSVthresh_ext = HSVthreshold(mirror_decorr_green_hsv_ext, pawHSVrange(2,:));
temp = libHSVthresh_ext & ~(bright_im > libHSVthresh_ext_maxBW);
libHSVthresh_ext = mirror_greenHSVthresh_ext | temp;

libHSVthresh_ext = libHSVthresh_ext & extMask & ~whiteMask & ~blackMask;% & BG_mask;% & ~whiteMask;% & im_masked;
% libHSVthresh_ext = processMask(libHSVthresh_ext,'sesize',2);

% libHSVthresh_ext = libHSVthresh_ext;% & ~mirror_greenBGmask;
libHSVthresh_int = libHSVthresh_int & ~mirror_greenBGmask;

% if any(prevExtMask(:)) && ~any(prevIntMask(:))
%     % only accept internal mask if no white parts of the limb adjacent to
%     % the box
%     overlap_test = imdilate(mirror_greenHSVthresh_ext,ext_white_check_SE) & frontPanelMask;% & whiteMask;
% %     overlap_test = imdilate(overlap_test,strel('disk',1)) & frontPanelMask;
%     if any(overlap_test(:))
%         % is there any green between the white and the wall?
%         overlap_test2 = imdilate(overlap_test,ext_white_check_SE) & mirror_greenHSVthresh_ext;
%         if ~any(overlap_test2(:))
%             mirror_greenHSVthresh_int = false(size(mirror_greenHSVthresh_int));
%         end
%     end
% end
    
% mirror_greenHSVthresh = mirror_greenHSVthresh_ext | mirror_greenHSVthresh_int & ~frontPanelMask;
libHSVthresh_ext = imreconstruct(mirror_greenHSVthresh_ext, libHSVthresh_ext);
libHSVthresh_int = imreconstruct(mirror_greenHSVthresh_int, libHSVthresh_int);
% b = bwconvhull(mirror_greenHSVthresh_ext);
s = regionprops(bwconvhull(libHSVthresh_ext,'union'),'boundingbox');
% if ~isempty(s)
%     bbox = round(s.BoundingBox);
% 
%     if prod(bbox(3:4)) > 900 % at least 30x30
%         q = mirror_str_img(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
% 
%         lh = stretchlim(q,0.05);
%         q2 = imadjust(q,lh,[]);
%         im_str = zeros(size(mirror_image_ud));
%         im_str(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:) = q2;
%         % find the darkest 1/2 of pixels in this region
%     %     im_gray = zeros(size(mirror_greenHSVthresh_ext));
%     %     im_gray(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)) = mean(q2,3);
%     %     im_gray_vec = im_gray(:);
%     %     idx = find(mirror_greenHSVthresh_ext);
% 
%     %     b = im_gray(mirror_greenHSVthresh_ext | mirror_greenHSVthresh_int);
%     %     b = double(repmat(mirror_greenHSVthresh_ext,1,1,3)) .* im_str;
% 
%         clims = zeros(2,3);
%         newMask = true(size(mirror_greenHSVthresh_ext));
%         brightMask = true(size(mirror_greenHSVthresh_ext));
%         for iCh = 1 : 3
%             temp = q2(:,:,iCh);
%             chVals = temp(:);
%             validVals = chVals(chVals > 0.1);
%     %         chVals = temp(temp > 0);
%             clims(1,iCh) = prctile(validVals,10);
%             clims(2,iCh) = prctile(validVals,50);
% 
%             newMask = newMask & ((im_str(:,:,iCh) >= clims(1,iCh)) & (im_str(:,:,iCh) <= clims(2,iCh)));
%             brightMask = brightMask & (im_str(:,:,iCh) >= prctile(validVals,90));
%         end
% 
%         mirror_greenHSVthresh_ext = imreconstruct(newMask,mirror_greenHSVthresh_ext & ~imdilate(brightMask,strel('disk',4)));
%         mirror_greenHSVthresh_ext = imreconstruct(mirror_greenHSVthresh_ext, libHSVthresh_ext & ~imdilate(brightMask,strel('disk',4)));
%     end
% end

% s = regionprops(bwconvhull(libHSVthresh_int,'union'),'boundingbox');
% if ~isempty(s)
%     
%     bbox = round(s.BoundingBox);
%     
%     if prod(bbox(3:4)) > 900 % at least 30x30
%         q = mirror_str_img(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
% 
%         lh = stretchlim(q,0.05);
%         q2 = imadjust(q,lh,[]);
%         im_str = zeros(size(mirror_image_ud));
%         im_str(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:) = q2;
% 
%     %     b = double(repmat(mirror_greenHSVthresh_int,1,1,3)) .* im_str;
% 
%         clims = zeros(2,3);
%         newMask = true(size(mirror_greenHSVthresh_int));
%         brightMask = true(size(mirror_greenHSVthresh_int));
%         for iCh = 1 : 3
%             temp = q2(:,:,iCh);
%             chVals = temp(:);
%             validVals = chVals(chVals > 0.1);
%     %         chVals = temp(temp > 0);
%             clims(1,iCh) = prctile(validVals,5);
%             clims(2,iCh) = prctile(validVals,50);
% 
%             newMask = newMask & ((im_str(:,:,iCh) > clims(1,iCh)) & (im_str(:,:,iCh) < clims(2,iCh)));
%             brightMask = brightMask & (im_str(:,:,iCh) > prctile(validVals,85));
%         end
% 
%         mirror_greenHSVthresh_int = imreconstruct(newMask,mirror_greenHSVthresh_int & ~imdilate(brightMask,strel('disk',4)));
%         mirror_greenHSVthresh_int = imreconstruct(mirror_greenHSVthresh_int, libHSVthresh_int & ~imdilate(brightMask,strel('disk',4)));
%     end
% 
% end

% mirror_greenHSVthresh_ext = processMask(mirror_greenHSVthresh_ext,'sesize',1);
% mirror_greenHSVthresh_int = processMask(mirror_greenHSVthresh_int,'sesize',1);

mirror_greenHSVthresh_int = imreconstruct(mirror_greenHSVthresh_int, libHSVthresh_int);
if ~any(mirror_greenHSVthresh_ext(:)) && any(mirror_greenHSVthresh_int(:))  % paw is entirely on the inside, eliminate reflection
    s = regionprops(bwconvhull(libHSVthresh_int),'boundingbox');
    bbox = round(s.BoundingBox);
    paw_zoom = mirror_str_img(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
    
    orig_hsv = rgb2hsv(mirror_image_ud);
    str_hsv = rgb2hsv(mirror_str_img);
    masked_ch = zeros(sum(mirror_greenHSVthresh_int(:)),3);
    masked_str_ch = zeros(sum(mirror_greenHSVthresh_int(:)),3);
    for iCh = 1 : 3
        temp_ch = orig_hsv(:,:,iCh);
        temp_ch = temp_ch(:);
        masked_ch(:,iCh) = temp_ch(mirror_greenHSVthresh_int(:));
        
        temp_ch = str_hsv(:,:,iCh);
        temp_ch = temp_ch(:);
        masked_str_ch(:,iCh) = temp_ch(mirror_greenHSVthresh_int(:));
    end
end

% check to see if there are green spots identified away from the front
% panel, while the paw is behind the front panel
if any(mirror_greenHSVthresh_ext(:)) && any(mirror_greenHSVthresh_int(:))
    ext_dilate = imdilate(mirror_greenHSVthresh_ext,strel('disk',25));
    ext_overlap = ext_dilate & frontPanelMask;
    if ~any(ext_overlap(:))
        mirror_greenHSVthresh_ext = false(size(mirror_greenHSVthresh_ext));
    end
end

% mirror_greenHSVthresh = mirror_greenHSVthresh_ext | mirror_greenHSVthresh_int & ~frontPanelMask;
mirror_greenHSVthresh = libHSVthresh_ext | mirror_greenHSVthresh_int & ~frontPanelMask;

behindPanelMask = frontPanelEdge & intMask;
behindOverlap = behindPanelMask & (prevMask_dilate | prevMask_panel_dilate);

if any(behindOverlap(:))

%     wm_int = whiteMask & intMask;
    temp = HSVthreshold(mirror_decorr_green_hsv_int,pawHSVrange(5,:));
    
    behindShelfRegion = projMaskFromTangentLines(shelfMask, fundMat', [1,1,h-1,w-1], [h,w]);
    behindShelfRegion = imfill(behindShelfRegion, [1 1]);
    behindShelfRegion = behindShelfRegion(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3));
    
    temp = temp & behindOverlap & behindShelfRegion & ~mirror_greenBGmask;
    temp = processMask(temp,'sesize',1);

    lib_temp = HSVthreshold(mirror_decorr_green_hsv_int,pawHSVrange(6,:));
    lib_temp = lib_temp & behindShelfRegion & ~mirror_greenBGmask & ~int_whiteMask & ~blackMask; %behindOverlap & ;% & ~whiteMask;
    behindPanelGreenThresh = imreconstruct(temp,lib_temp);
%     behindPanelGreenThresh = processMask(behindPanelGreenThresh, 1);
    if any(mirror_greenHSVthresh_int(:))    % if paw is already detected on interior of box, only accept the mask near the front panel if it overlaps with the internal part already found
        behindPanel_int_overlap_check = mirror_greenHSVthresh_int & lib_temp;
        if ~any(behindPanel_int_overlap_check(:))
            behindPanelGreenThresh = false(size(lib_temp));
        else
            behindPanelGreenThresh = imreconstruct(behindPanel_int_overlap_check, behindPanelGreenThresh);
        end
    end
    mirror_greenHSVthresh = mirror_greenHSVthresh | behindPanelGreenThresh;

end
% greenMask = processMask(mirror_greenHSVthresh,'sesize',1);
greenMask = mirror_greenHSVthresh;

temp = bwconvhull(greenMask,'union');
fullMask = false(h,w);
fullMask(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3)) = temp;