function fullMasks = trackNextStep( image_ud, BGimg_ud, prevMasks, boxRegions, fundMat, varargin)

h = size(image_ud,1); w = size(image_ud,2);

maxFrontPanelSep = 20;
maxDistPerFrame = 30;

stretchTol = [0.0 1.0];
foregroundThresh = 45/255;

frontPanelMask = boxRegions.frontPanelMask;
intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
shelfMask = boxRegions.shelfMask;
belowShelfMask = boxRegions.belowShelfMask;

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

for iarg = 1 : 2 : nargin - 9
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'pawhsvrange',
            pawHSVrange = varargin{iarg + 1};
        case 'maxredgreendist',
            maxRedGreenDist = varargin{iarg + 1};
        case 'minrgdiff',
            minRGDiff = varargin{iarg + 1};
        case 'resblob',
            restrictiveBlob = varargin{iarg + 1};
        case 'stretchtol',
            stretchTol = varargin{iarg + 1};
    end
end

bbox = zeros(2,4);
for iView = 1 : 2
    s = regionprops(prevMasks{iView},'boundingbox');
    bbox(iView,:) = round(s.BoundingBox);
end

bbox(:,1) = bbox(:,1) - maxDistPerFrame/2;
bbox(:,2) = bbox(:,2) - maxDistPerFrame/2;
bbox(:,3) = bbox(:,3) + maxDistPerFrame;
bbox(:,4) = bbox(:,4) + maxDistPerFrame;

% if any of the previous mask is on the interior side of the front
% panel, don't add the width of the front panel to the search window
overlap_mask = prevMasks{2} & intMask;
if ~any(overlap_mask(:))
    if boxFrontThick > 0
        bbox(2,3) = bbox(2,3) + boxFrontThick;
    else
        bbox(2,1) = bbox(2,1) + boxFrontThick;
        bbox(2,3) = bbox(2,3) - boxFrontThick;
    end
end

BGdiff = imabsdiff(image_ud, BGimg_ud);
orig_image_ud = image_ud;
image_ud = color_adapthisteq(orig_image_ud);

im_masked = false(h,w);
for iChannel = 1 : 3
    im_masked = im_masked | (BGdiff(:,:,iChannel) > foregroundThresh);
end

rgDiffMap = abs(image_ud(:,:,2) - image_ud(:,:,1));
rgMask = rgDiffMap < minRGDiff;

fullMask = cell(1,2);
redMask = cell(1,2);
greenMask = cell(1,2);
any_greenMask = cell(1,2);
imView = cell(1,2);
decorr_fg = cell(1,2);
decorr_hsv = cell(1,2);

projMask = true(h,w);
for iView = 2:-1:1
	im_masked = projMask & im_masked;
    viewMask = im_masked(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                         bbox(iView,1):bbox(iView,1) + bbox(iView,3));
    rgViewMask = rgMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                        bbox(iView,1):bbox(iView,1) + bbox(iView,3));
	imView{iView} = image_ud(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                             bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
    decorr_fg{iView} = decorrstretch(imView{iView},'tol',stretchTol);
    decorr_hsv{iView} = rgb2hsv(decorr_fg{iView});
    
    if iView == 2
        behindPanelRegion = intMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                                    bbox(iView,1):bbox(iView,1) + bbox(iView,3));
        
    
    