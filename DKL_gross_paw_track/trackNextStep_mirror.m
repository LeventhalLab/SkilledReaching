function [fullMask,greenMask] = trackNextStep_mirror( image_ud, fundMat, BGimg_ud, prevMask, boxRegions, pawPref, varargin)

h = size(image_ud,1); w = size(image_ud,2);
targetMean = [0.5,0.2,0.5
              0.3,0.5,0.5];
    
targetSigma = [0.2,0.2,0.2
               0.2,0.2,0.2];
           
maxFrontPanelSep = 20;
maxDistPerFrame = 20;

numStretches = 15;

% stretchTol = [0.0 1.0];
% foregroundThresh = 45/255;
whiteThresh = 0.85;

frontPanelMask = boxRegions.frontPanelMask;
shelfMask = boxRegions.shelfMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
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

for iarg = 1 : 2 : nargin - 6
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
        case 'whitethresh',
            whiteThresh = varargin{iarg + 1};
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
    case 'left',
        ROI = [ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,...
               w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),h-1];
        SE_fromExt = [ones(1,maxFrontPanelSep+25),zeros(1,maxFrontPanelSep+25)];
        SE_fromInt = [zeros(1,maxFrontPanelSep+25),ones(1,maxFrontPanelSep+25)];
        overlapCheck_SE_fromExt = [ones(1,5),zeros(1,5)];
        overlapCheck_SE_fromInt = [zeros(1,15),ones(1,15)];
end

mirror_image_ud = image_ud(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);
% prev_mirror_image_ud = prev_image_ud(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);
prevMask = prevMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
frontPanelEdge = frontPanelEdge(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
extMask = extMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));

frontPanelMask = frontPanelMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
% centerMask = centerMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));
intMask = intMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));


str_img = image_ud;
for ii = 1 : numStretches
    str_img = color_adapthisteq(str_img);
end
whiteMask = rgb2gray(str_img) > whiteThresh;
whiteMask = whiteMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3));

<<<<<<< HEAD
% decorr_green = decorrstretch(str_img,...
%                              'targetmean',targetMean(1,:),...
%                              'targetsigma',targetSigma(1,:));
decorr_green = decorrstretch(image_ud,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
lo_hi = stretchlim(decorr_green);
decorr_green = imadjust(decorr_green,lo_hi,[]);

=======
decorr_green = decorrstretch(str_img,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
>>>>>>> origin/master
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

mirror_greenHSVthresh_ext = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(6,:));
<<<<<<< HEAD
mirror_greenHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(6,:));
=======
mirror_greenHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(2,:));
>>>>>>> origin/master

mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & (prevMask_dilate | prevMask_panel_dilate);
mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & (prevMask_dilate | prevMask_panel_dilate);

mirror_greenHSVthresh_ext = mirror_greenHSVthresh_ext & extMask;
mirror_greenHSVthresh_int = mirror_greenHSVthresh_int & intMask;

% temp = prevMask_dilate & mirror_greenHSVthresh_int;
<<<<<<< HEAD
mirror_greenHSVthresh_ext = processMask(mirror_greenHSVthresh_ext,'sesize',1);
mirror_greenHSVthresh_int = processMask(mirror_greenHSVthresh_int,'sesize',1);

libHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(7,:));
libHSVthresh_int = libHSVthresh_int & intMask& ~whiteMask;
=======
% mirror_greenHSVthresh_ext = processMask(mirror_greenHSVthresh_ext,'sesize',2);
% mirror_greenHSVthresh_int = processMask(temp,'sesize',2);

libHSVthresh_int = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(5,:));
libHSVthresh_int = libHSVthresh_int & intMask;
>>>>>>> origin/master

libHSVthresh_ext = HSVthreshold(mirror_decorr_green_hsv, pawHSVrange(7,:));
libHSVthresh_ext = libHSVthresh_ext & extMask & ~whiteMask;

mirror_greenHSVthresh_ext = imreconstruct(mirror_greenHSVthresh_ext, libHSVthresh_ext);
mirror_greenHSVthresh_int = imreconstruct(mirror_greenHSVthresh_int, libHSVthresh_int);

mirror_greenHSVthresh = mirror_greenHSVthresh_ext | mirror_greenHSVthresh_int;

mirror_greenHSVthresh = mirror_greenHSVthresh & ~whiteMask;

behindPanelMask = frontPanelEdge & intMask;
behindOverlap = behindPanelMask & (prevMask_dilate | prevMask_panel_dilate);
if any(behindOverlap(:))
    
    BGimg_ud = BGimg_ud(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3),:);
    
    abs_BGdiff = imabsdiff(mirror_image_ud, BGimg_ud);
    BGdiff_stretch = color_adapthisteq(abs_BGdiff);
    decorr_green_BG = decorrstretch(BGdiff_stretch,...
                                 'targetmean',targetMean(1,:),...
                                 'targetsigma',targetSigma(1,:));
    
    decorr_green_BG_hsv = rgb2hsv(decorr_green_BG);
    temp = HSVthreshold(decorr_green_BG_hsv,pawHSVrange(2,:));
    behindShelfRegion = projMaskFromTangentLines(shelfMask, fundMat', [1,1,h-1,w-1], size(BGimg_ud));
    behindShelfRegion = imfill(behindShelfRegion, [1 1]);
    
    temp = temp & behindPanelMask & behindShelfRegion;
    mirror_greenHSVthresh = mirror_greenHSVthresh | temp;
    
%     diff_greenHSVthresh = HSVthreshold(decorr_green_BG_hsv, pawHSVrange(1,:));
%     diff_greenHSVthresh = diff_greenHSVthresh & behindOverlap;
% else
%     diff_greenHSVthresh = false(size(prevMask_dilate));
% end
end

% greenThresh = diff_greenHSVthresh | mirror_greenHSVthresh;

% temp = greenThresh & (prevMask_dilate | prevMask_panel_dilate);
temp = mirror_greenHSVthresh & (prevMask_dilate | prevMask_panel_dilate);

greenMask = processMask(temp,'sesize',1);

temp = bwconvhull(greenMask,'union');
fullMask = false(h,w);
fullMask(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3)) = temp;