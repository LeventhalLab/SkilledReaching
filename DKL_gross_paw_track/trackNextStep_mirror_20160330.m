function [fullMask,greenMask] = trackNextStep_mirror_20160330( image_ud, fundMat, prevMask, boxRegions, pawPref, varargin)

% CONSIDER SUBTRACTING EACH IMAGE FROM THE PREVIOUS ONE, USING THAT AS A
% BACKGROUND MASK EXCEPT IN THE IMMEDIATE VICINITY OF THE LAST PAW
% LOCATION?

h = size(image_ud,1); w = size(image_ud,2);
targetMean = [0.5,0.2,0.5
              0.3,0.5,0.5];
    
targetSigma = [0.2,0.2,0.2
               0.2,0.2,0.2];
           
maxFrontPanelSep = 20;
maxDistBehindFrontPanel = 10;
maxDistPerFrame = 20;

stretch_hist_limit = 0.75;
% numStretches = 15;

% stretchTol = [0.0 1.0];
foregroundThresh = 15/255;
whiteThresh_ext = 0.95;
whiteThresh_int = 0.85;

frontPanelMask = boxRegions.frontPanelMask;
shelfMask = boxRegions.shelfMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxDistBehindFrontPanel)) & ~frontPanelMask;
% shelfEdge = imdilate(shelfMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
% slotMask = boxRegions.slotMask;

% [~,x] = find(slotMask);
% centerPoly_x = [min(x),max(x),max(x),min(x),min(x)];
% centerPoly_y = [1,1,h,h,1];
% centerMask = poly2mask(centerPoly_x,centerPoly_y,h,w);
% centerMask = imdilate(centerMask,strel('line',150,0));
% centerShelfMask = centerMask & shelfMask;

% belowShelfMask = boxRegions.belowShelfMask;
% floorMask = boxRegions.floorMask;

boxFrontThick = 20;
% maskDilate = 15;

% full_bbox = [1 1 w-1 h-1];

% blob parameters for tight thresholding
% restrictiveBlob = vision.BlobAnalysis;
% restrictiveBlob.AreaOutputPort = true;
% restrictiveBlob.CentroidOutputPort = true;
% restrictiveBlob.BoundingBoxOutputPort = true;
% restrictiveBlob.LabelMatrixOutputPort = true;
% restrictiveBlob.MinimumBlobArea = 5;
% restrictiveBlob.MaximumBlobArea = 10000;

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
%         case 'foregroundthresh',
%             foregroundThresh = varargin{iarg + 1};
        case 'pawhsvrange',
            pawHSVrange = varargin{iarg + 1};
%         case 'resblob',
%             restrictiveBlob = varargin{iarg + 1};
%         case 'stretchtol',
%             stretchTol = varargin{iarg + 1};
        case 'boxfrontthick',
            boxFrontThick = varargin{iarg + 1};
        case 'maxdistperframe',
            maxDistPerFrame = varargin{iarg + 1};
        case 'whitethresh_ext',
            whiteThresh_ext = varargin{iarg + 1};
        case 'whitethresh_int',
            whiteThresh_int = varargin{iarg + 1};
        case 'targetmean',
            targetMean = varargin{iarg + 1};
        case 'targetsigma',
            targetSigma = varargin{iarg + 1};
    end
end

shelfLims = regionprops(boxRegions.shelfMask,'boundingbox');
switch lower(pawPref),
    case 'right',
        ROI = [1,1,...
            floor(shelfLims.BoundingBox(1)),h-1];
        SE_fromExt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
        SE_fromInt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
        
        overlapCheck_SE_fromExt = [zeros(1,5),ones(1,5)];
        overlapCheck_SE_fromInt = [ones(1,15),zeros(1,15)];
        ext_white_check_SE = [zeros(1,10),ones(1,10)];
    case 'left',
        ROI = [ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,...
               w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),h-1];
        SE_fromExt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
        SE_fromInt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [ones(1,5),zeros(1,5)];
        overlapCheck_SE_fromInt = [zeros(1,15),ones(1,15)];
        ext_white_check_SE = [ones(1,10),zeros(1,10)];
end


mirror_image_ud = image_ud(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);
im_gray = mean(mirror_image_ud,3);
[g_hist,g_bins] = imhist(im_gray);
totCount = sum(g_hist(1:end-1));
cumCount = cumsum(g_hist);
gray_lim_idx = find(cumCount < totCount*stretch_hist_limit,1,'last');
gray_lim = g_bins(gray_lim_idx);
in_adjust = [0,0,0;ones(1,3)*(gray_lim + 0.1)];
out_adjust = [ones(1,3)*(gray_lim - 0.1);1,1,1];

prevMask = prevMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
frontPanelEdge = frontPanelEdge(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
frontPanelMask = frontPanelMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
extMask = extMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
intMask = intMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
% str_img = imadjust(mirror_image_ud,[0.0,0.0,0.0;0.4,0.4,0.4],[0.2,0.2,0.2;1,1,1]);
str_img = imadjust(mirror_image_ud,in_adjust,out_adjust);
whiteMask_ext = str_img(:,:,1) > whiteThresh_ext & ...
                str_img(:,:,2) > whiteThresh_ext & ...
                str_img(:,:,3) > whiteThresh_ext;
whiteMask_ext = whiteMask_ext & extMask;

whiteMask_int = str_img(:,:,1) > whiteThresh_int & ...
                str_img(:,:,2) > whiteThresh_int & ...
                str_img(:,:,3) > whiteThresh_int;
whiteMask_int = whiteMask_int & intMask;

whiteMask = whiteMask_ext | whiteMask_int;

decorr_green = decorrstretch(str_img,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
% decorr_green = decorrstretch(image_ud,...
%                              'targetmean',targetMean(1,:),...
%                              'targetsigma',targetSigma(1,:));
                         
lo_hi = stretchlim(decorr_green);
decorr_green = imadjust(decorr_green,lo_hi,[]);

% mirror_decorr_green = decorr_green(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);
decorr_green_hsv = rgb2hsv(decorr_green);
mirror_decorr_green_hsv = decorr_green_hsv(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);


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

prevMask_dilate = imdilate(prevMask,strel('disk',maxDistPerFrame));

mirror_greenHSVthresh_ext = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(1,:));
mirror_greenHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(3,:));
wm_dilate = imdilate(whiteMask, strel('disk',5));
ext_temp = mirror_greenHSVthresh_ext & ~wm_dilate;
int_temp = mirror_greenHSVthresh_int & ~wm_dilate;
% mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & im_masked;
% mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & im_masked;
mirror_greenHSVthresh_ext = imreconstruct(ext_temp, mirror_greenHSVthresh_ext);
mirror_greenHSVthresh_int = imreconstruct(int_temp, mirror_greenHSVthresh_int);

mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & (prevMask_dilate | prevMask_panel_dilate);
mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & (prevMask_dilate | prevMask_panel_dilate);

mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & extMask;
mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & intMask;

% temp = prevMask_dilate & mirror_greenHSVthresh_int;
mirror_greenHSVthresh_ext = processMask(mirror_greenHSVthresh_ext,'sesize',1);
mirror_greenHSVthresh_int = processMask(mirror_greenHSVthresh_int,'sesize',1);
temp = mirror_greenHSVthresh_int & prevMask;
if any(temp(:))     % only keep points that overlap with the previous mask.
                    % if somehow the paw moved so fast that there is no
                    % overlap, just stick with what was previously found.
    mirror_greenHSVthresh_int = temp;
end
temp = mirror_greenHSVthresh_ext & prevMask;
if any(temp(:))     % only keep points that overlap with the previous mask.
                    % if somehow the paw moved so fast that there is no
                    % overlap, just stick with what was previously found.
    mirror_greenHSVthresh_ext = temp;
end

libHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(4,:));
libHSVthresh_int = libHSVthresh_int & intMask & ~whiteMask;

libHSVthresh_ext = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(2,:));
libHSVthresh_ext = libHSVthresh_ext & extMask & ~whiteMask;% & im_masked;

mirror_greenHSVthresh_ext = imreconstruct(mirror_greenHSVthresh_ext, libHSVthresh_ext);
mirror_greenHSVthresh_int = imreconstruct(mirror_greenHSVthresh_int, libHSVthresh_int);

if any(prevExtMask(:)) && ~any(prevIntMask(:))
    % only accept internal mask if no white parts of the limb adjacent to
    % the box
    overlap_test = imdilate(mirror_greenHSVthresh_ext,ext_white_check_SE) & whiteMask & frontPanelMask;
%     overlap_test = imdilate(overlap_test,strel('disk',1)) & frontPanelMask;
    if any(overlap_test(:))
        % is there any green between the white and the wall?
        overlap_test2 = imdilate(overlap_test,ext_white_check_SE) & mirror_greenHSVthresh_ext;
        if ~any(overlap_test2(:))
            mirror_greenHSVthresh_int = false(size(mirror_greenHSVthresh_int));
        end
    end
end
    
    
mirror_greenHSVthresh = mirror_greenHSVthresh_ext | mirror_greenHSVthresh_int;

% mirror_greenHSVthresh = mirror_greenHSVthresh & ~whiteMask;

behindPanelMask = frontPanelEdge & intMask;
behindOverlap = behindPanelMask & (prevMask_dilate | prevMask_panel_dilate);
if any(behindOverlap(:))

    wm_int = whiteMask & intMask;
    temp = HSVthreshold(mirror_decorr_green_hsv,pawHSVrange(5,:));
    
    behindShelfRegion = projMaskFromTangentLines(shelfMask, fundMat', [1,1,h-1,w-1], [h,w]);
    behindShelfRegion = imfill(behindShelfRegion, [1 1]);
    behindShelfRegion = behindShelfRegion(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
    
    temp = temp & behindOverlap & behindShelfRegion;
    overlap_test = wm_int & imdilate(temp,strel('disk',10));   % make sure the white part of the limb is on this side of the front panel
    if any(overlap_test(:))
        
        if any(prevExtMask(:))   % is there any white between the outside green region and the front panel?
            overlap_test = imdilate(mirror_greenHSVthresh_ext,ext_white_check_SE) & whiteMask & frontPanelMask;
        else
            overlap_test = false;
        end
        overlap_test2 = imdilate(overlap_test,ext_white_check_SE) & mirror_greenHSVthresh_ext;
        if ~any(overlap_test(:)) || any(overlap_test2(:))    % either no white outside front panel, or there is green between the white and the wall
            temp = temp & ~wm_dilate;

            lib_temp = HSVthreshold(mirror_decorr_green_hsv,pawHSVrange(6,:));
            lib_temp = lib_temp & behindOverlap & behindShelfRegion & ~whiteMask;
            behindPanelGreenThresh = imreconstruct(temp,lib_temp);
            mirror_greenHSVthresh = mirror_greenHSVthresh | behindPanelGreenThresh;
        end
    end
    
%     diff_greenHSVthresh = HSVthreshold(decorr_green_BG_hsv, pawHSVrange(1,:));
%     diff_greenHSVthresh = diff_greenHSVthresh & behindOverlap;
% else
%     diff_greenHSVthresh = false(size(prevMask_dilate));
% end
end

% greenThresh = diff_greenHSVthresh | mirror_greenHSVthresh;

% temp = greenThresh & (prevMask_dilate | prevMask_panel_dilate);
% temp = mirror_greenHSVthresh & (prevMask_dilate | prevMask_panel_dilate);

greenMask = processMask(mirror_greenHSVthresh,'sesize',1);

temp = bwconvhull(greenMask,'union');
fullMask = false(h,w);
fullMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3)) = temp;