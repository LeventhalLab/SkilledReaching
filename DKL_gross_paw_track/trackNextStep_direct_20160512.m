function [fullMask] = trackNextStep_direct_20160512( image_ud, prevMask, cur_mir_points2d, boxRegions, pawPref, boxCalibration, greenBGmask, varargin)

% MAY HAVE TO UPDATE HOW GREENBGMASK IS CALCULATED IN THE CALLING FUNCTION

h = size(image_ud,1); w = size(image_ud,2);
           
maxFrontPanelSep = 20;
maxDistPerFrame = 20;

numStretches = 7;

foregroundThresh = 45/255;
whiteThresh = 0.8;

shelfThick = 50;

frontPanelMask = boxRegions.frontPanelMask;
shelfMask = boxRegions.shelfMask;
% frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
% shelfEdge = imdilate(shelfMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
slotMask = boxRegions.slotMask;
floorMask = boxRegions.floorMask;
[y,~] = find(floorMask);
ROI_bot = min(y);

[~,x] = find(shelfMask);
centerPoly_x = [min(x),max(x),max(x),min(x),min(x)];
centerPoly_y = [1,1,h,h,1];
centerMask = poly2mask(centerPoly_x,centerPoly_y,h,w);
centerMask = imdilate(centerMask,strel('line',100,0));
distFromSlot = 150;
% ROI = [centerPoly_x(1)-distFromSlot, 1, range(x)+2*distFromSlot, h-1];
centerShelfMask = centerMask & shelfMask;
belowShelfMask = boxRegions.belowShelfMask;


boxFrontThick = 20;
maskDilate = 15;

full_bbox = [1 1 w-1 h-1];

% blob parameters for tight thresholding
restrictiveBlob = vision.BlobAnalysis;
restrictiveBlob.AreaOutputPort = true;
restrictiveBlob.CentroidOutputPort = true;
restrictiveBlob.BoundingBoxOutputPort = true;
restrictiveBlob.LabelMatrixOutputPort = true;
restrictiveBlob.MinimumBlobArea = 5;
restrictiveBlob.MaximumBlobArea = 10000;

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'pawhsvrange',
            pawHSVrange = varargin{iarg + 1};
        case 'resblob',
            restrictiveBlob = varargin{iarg + 1};
        case 'stretchtol',
            stretchTol = varargin{iarg + 1};
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
        fundMat = boxCalibration.srCal.F(:,:,1);
%         ROI = [1,1,floor(shelfLims.BoundingBox(1) + shelfLims.BoundingBox(3)),ROI_bot;...
%             ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot];
        ROI = [1,1,floor(shelfLims.BoundingBox(1)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)),1,ceil(shelfLims.BoundingBox(3)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot];
    case 'left',
        fundMat = boxCalibration.srCal.F(:,:,2);
%         ROI = [ceil(shelfLims.BoundingBox(1)),1,w-ceil(shelfLims.BoundingBox(1)),ROI_bot;...
%                1,1,floor(shelfLims.BoundingBox(1)),ROI_bot];
        ROI = [ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)),1,ceil(shelfLims.BoundingBox(3)),ROI_bot;...
               1,1,floor(shelfLims.BoundingBox(1)),ROI_bot];
end

% lh  = stretchlim(image_ud(1:ROI_bot,:));
% str_img = imadjust(image_ud,lh,[]);

mirror_image_ud = image_ud(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:);
direct_image_ud = image_ud(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:);
other_mirror_image_ud = image_ud(ROI(3,2):ROI(3,2)+ROI(3,4),ROI(3,1):ROI(3,1)+ROI(3,3),:);
lh  = stretchlim(other_mirror_image_ud,0.05);
direct_str_img = imadjust(direct_image_ud,lh,[]);
mirror_str_img = imadjust(mirror_image_ud,lh,[]);
% str_img = image_ud;
% str_img(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:) = mirror_str_img;
% str_img(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:) = direct_str_img;

direct_green = decorrstretch(direct_str_img,'tol',0.02);
mirror_green = decorrstretch(mirror_str_img,'tol',0.02);
decorr_green = image_ud;
decorr_green(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:) = mirror_green;
decorr_green(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:) = direct_green;

mirror_mask = false(h,w);
if ~isempty(cur_mir_points2d)
    for ii = 1 : size(cur_mir_points2d,1)
        mirror_mask(cur_mir_points2d(ii,2),cur_mir_points2d(ii,1)) = true;
    end
    mirror_mask = imfill(mirror_mask,'holes');
    mirror_mask_dil = imdilate(mirror_mask, strel('disk',10));
    projMask = projMaskFromTangentLines(mirror_mask_dil, fundMat, [1 1 w-1 h-1], [h,w]);
    centerProjMask = projMask & centerMask;
else
    centerProjMask = imdilate(centerMask,strel('disk',150));    % expand center region because this is probably the rat walking up to the slot
end

decorr_green_hsv = rgb2hsv(decorr_green);

prevMask_dilate = imdilate(prevMask,strel('disk',maxDistPerFrame));
dil_mask = imdilate(prevMask,strel('line',10,90)) | imdilate(prevMask,strel('line',10,270));
shelf_overlap_mask = dil_mask & shelfMask;

behindPanelMask = mirror_mask & intMask;

if any(shelf_overlap_mask(:)) && any(behindPanelMask(:))   % previous paw mask is very close to the shelf
                                % AND the paw is behind the front panel
                                % therefore, check the other side of the
                                % shelf to see if the paw shows
                                % up there
    SE = strel('rectangle',[shelfThick + 50, 10]);
    prevMask_panel_dilate = imdilate(prevMask, SE);
else
    prevMask_panel_dilate = false(size(prevMask));
end

greenHSVthresh = HSVthreshold(decorr_green_hsv,pawHSVrange(1,:));
greenHSVthresh = greenHSVthresh & ~imdilate(greenBGmask,strel('disk',2));

projGreenThresh = greenHSVthresh & (centerProjMask & (prevMask_dilate | prevMask_panel_dilate));
% projGreenThresh = projGreenThresh & ~whiteMask;

lib_HSVthresh = HSVthreshold(decorr_green_hsv,pawHSVrange(2,:));
lib_HSVthresh = lib_HSVthresh & ~greenBGmask;

fullThresh = imreconstruct(projGreenThresh, lib_HSVthresh);

extCheck = mirror_mask & extMask;
if ~any(extCheck(:))  % paw mask is entirely inside the box - do we have to eliminate reflections in the floor?
    % new strategy is to check for points that would be below the floor
    
    if any(fullThresh(:)) && any(mirror_mask(:))
        [validDirectMask, validMirrorMask] = findValidDirectPts( boxRegions.floorCoords, fullThresh, mirror_mask, boxCalibration, pawPref);
        mirror_mask = validMirrorMask;
        fullThresh = validDirectMask;
    end
else
    % part of the paw is outside the box, so the paw must be pretty close
    % to the slot. Get rid of any points too far from the slot
    switch lower(pawPref),
        case 'left',
            extended_SE = [ones(1,100),zeros(1,100)];
        case 'right',
            extended_SE = [zeros(1,100),ones(1,100)];
    end
    extSlotMask = imdilate(slotMask,strel('disk',50));
    extSlotMask = imdilate(extSlotMask,extended_SE);
    extSlotMask = imdilate(extSlotMask,[zeros(50,1);ones(50,1)]);
    
    fullThresh = fullThresh & extSlotMask;
end



fullThresh = bwconvhull(fullThresh,'union');

bbox = [1,1,w-1,h-1];
bbox(2,:) = bbox;
if ~isempty(cur_mir_points2d) && any(fullThresh(:))
    masks{1} = fullThresh;
    masks{2} = mirror_mask;
    fullMask = estimateHiddenSilhouette(masks, bbox,fundMat,[h,w]);
elseif ~isempty(cur_mir_points2d) && ~any(fullThresh(:))
    fullMask{1} = false(h,w);
    fullMask{2} = mirror_mask;
elseif isempty(cur_mir_points2d) && any(fullThresh(:))
    fullMask{1} = fullThresh;
    fullMask{2} = false(h,w);
else
    fullMask{1} = false(h,w);
    fullMask{2} = false(h,w);
end
