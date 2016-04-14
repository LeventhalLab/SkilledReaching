function [fullMask,greenMask,bbox] = trackNextStep_20160303( image_ud, prev_image_ud, BGimg_ud, prevMasks,prev_greenMask, boxRegions, fundMat, pawPref, varargin)

h = size(image_ud,1); w = size(image_ud,2);
targetMean = [0.5,0.2,0.5
              0.3,0.5,0.5];
    
targetSigma = [0.2,0.2,0.2
               0.2,0.2,0.2];
           
HSV_distThresh = 0.2;

maxFrontPanelSep = 20;
maxDistPerFrame = 20;
threshFrameExpansion = 30;

foregroundThresh = 45/255;

frontPanelMask = boxRegions.frontPanelMask;
shelfMask = boxRegions.shelfMask;
frontPanelEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
shelfEdge = imdilate(shelfMask, strel('disk',maxFrontPanelSep)) & ~frontPanelMask;
intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
[~,x] = find(shelfMask);
centerPoly_x = [min(x),max(x),max(x),min(x),min(x)];
centerPoly_y = [1,1,h,h,1];
centerMask = poly2mask(centerPoly_x,centerPoly_y,h,w);

belowShelfMask = boxRegions.belowShelfMask;
floorMask = boxRegions.floorMask;
maskRadius = 50;
HSVweights = [1,1,1];
summaryWeights = [3,1];
minDiffVal = 0.001;
diffScale = 10;
summary_thresh = 0.9;

boxFrontThick = 20;
maskDilate = 15;

full_bbox = [1 1 w-1 h-1];
full_bbox(2,:) = full_bbox;

% blob parameters for tight thresholding
restrictiveBlob = vision.BlobAnalysis;
restrictiveBlob.AreaOutputPort = true;
restrictiveBlob.CentroidOutputPort = true;
restrictiveBlob.BoundingBoxOutputPort = true;
restrictiveBlob.LabelMatrixOutputPort = true;
restrictiveBlob.MinimumBlobArea = 5;
restrictiveBlob.MaximumBlobArea = 10000;

for iarg = 1 : 2 : nargin - 8
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
        case 'targetmean',
            targetMean = varargin{iarg + 1};
        case 'targetsigma',
            targetSigma = varargin{iarg + 1};
    end
end

decorr_green_prev = decorrstretch(prev_image_ud,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
decorr_green_ad_prev = color_adapthisteq(decorr_green_prev);
decorr_green_hsv_prev = rgb2hsv(decorr_green_ad_prev);

bbox = zeros(2,4);
prevMask_dilate = cell(1,2);
for iView = 1 : 2
    prevMask_dilate{iView} = imdilate(prevMasks{iView},strel('disk',maxDistPerFrame));
end

% if any of the previous mask is on the interior side of the front
% panel, don't add the width of the front panel to the search window
side_overlap_mask = prevMask_dilate{2} & frontPanelMask;
if any(side_overlap_mask(:))
    projMask = projMaskFromTangentLines(prevMask_dilate{1}, fundMat, [1 1 w-1 h-1], [h,w]);
    prevMask_dilate{2} = prevMask_dilate{2} | (projMask & frontPanelEdge);
    prevMask_dilate{2} = imreconstruct(side_overlap_mask,prevMask_dilate{2});
end

shelf_overlap_mask = prevMask_dilate{1} & shelfMask;
if any(shelf_overlap_mask(:)) && any(side_overlap_mask(:))
    projMask = projMaskFromTangentLines(prevMask_dilate{2}, fundMat', [1 1 w-1 h-1], [h,w]);
    temp = bwmorph(prevMask_dilate{1},'remove');
    [~,x] = find(temp);
    slotRegionPoly_x = [min(x),max(x),max(x),min(x),min(x)]; 
    slotRegionPoly_y = [1,1,h,h,min(x)];
    slotRegionMask = poly2mask(slotRegionPoly_x,slotRegionPoly_y,h,w);
    slotRegionMask = imdilate(slotRegionMask,strel('disk',maxFrontPanelSep));
    prevMask_dilate{1} = prevMask_dilate{1} | (projMask & shelfEdge & slotRegionMask);
    prevMask_dilate{1} = imreconstruct(shelf_overlap_mask,prevMask_dilate{1});
end

BGdiff = imabsdiff(image_ud, BGimg_ud);

im_masked = false(h,w);
for iChannel = 1 : 3
    im_masked = im_masked | (BGdiff(:,:,iChannel) > foregroundThresh);
end
orig_im_mask = im_masked;
im_masked = processMask(orig_im_mask, 2);
im_masked = im_masked | (~extMask & ~centerMask);    % exclude regions in side views behind front panel from background subtraction

decorr_green = decorrstretch(image_ud,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
decorr_green_ad = color_adapthisteq(decorr_green);
decorr_green_hsv = rgb2hsv(decorr_green_ad);

% if iView == 2
    behindPanelMask = frontPanelEdge & intMask;%prevMask_dilate{2} & ~extMask;
    behindPanel_hsv = decorr_green_hsv .* double(repmat(behindPanelMask,1,1,3));
    
    behindPanel_green = HSVthreshold(behindPanel_hsv, pawHSVrange(2,:));
    behindPanel_green = behindPanel_green & prevMask_dilate{2};
    
    belowShelfMask = prevMask_dilate{1} & belowShelfMask;
    belowShelf_hsv = decorr_green_hsv .* double(repmat(belowShelfMask,1,1,3));
    
    belowShelf_green = HSVthreshold(belowShelf_hsv, pawHSVrange(2,:));

greenHSVmask = HSVthreshold(decorr_green_hsv, pawHSVrange(1,:));
greenHSVmask = greenHSVmask | behindPanel_green | belowShelf_green;
greenHSVmask_pr = processMask(greenHSVmask,2);
greenHSVmask_pr = greenHSVmask_pr & (prevMask_dilate{1} | prevMask_dilate{2});
greenHSVmask_bg = greenHSVmask_pr & im_masked;

greenMask{1} = greenHSVmask_bg & centerMask;
greenMask{2} = greenHSVmask_bg & ~centerMask;

proj_overlap = cell(1,2);
for iView = 1 : 2
    if any(greenMask{iView})
        projMask = projMaskFromTangentLines(greenMask{iView}, fundMat, [1 1 w-1 h-1], [h,w]);
        proj_overlap{iView} = (greenMask{3-iView} & projMask);
    else
        proj_overlap{iView} = greenMask{3-iView};
    end
end

for iView = 1 : 2
    greenMask{iView} = imreconstruct(proj_overlap{3-iView},greenMask{iView});
end

fullMask{1} = bwconvhull(greenMask{1},'union');
fullMask{2} = bwconvhull(greenMask{2},'union');

fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);

% eliminate the floor
if any(fullMask{1}(:))
    fullMask{1} = fullMask{1} & ~floorMask;
    if any(fullMask{1}(:))
        direct_projMask = projMaskFromTangentLines(fullMask{1}, fundMat, [1 1 w-1 h-1], [h,w]);
        fullMask{2} = fullMask{2} & direct_projMask;
    end
end


bbox = zeros(2,4);
for iView = 1 : 2
    s = regionprops(fullMask{iView},'boundingbox');
    if isempty(s)
        s = regionprops(prevMask_dilate{iView},'boundingbox');
    end
    bbox(iView,:) = s.BoundingBox;
end