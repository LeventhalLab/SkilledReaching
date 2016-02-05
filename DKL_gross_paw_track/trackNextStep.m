function [fullMask,bbox] = trackNextStep( image_ud, BGimg_ud, prevMasks, boxRegions, fundMat, pawPref, varargin)

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
floorMask = boxRegions.floorMask;

boxFrontThick = 20;

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

for iarg = 1 : 2 : nargin - 6
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
        case 'boxfrontthick',
            boxFrontThick = varargin{iarg + 1};
        case 'maxdistperframe',
            maxDistPerFrame = varargin{iarg + 1};
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
    if strcmpi(pawPref,'right')
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
                                
%         viewMask = viewMask | behindPanelRegion;   % because shadow behind front panel is often dark in background and video images
        behindPanel_hsv = decorr_hsv{iView} .* repmat(double(behindPanelRegion),1,1,3);
        any_greenMask{iView} = HSVthreshold(behindPanel_hsv, pawHSVrange(3,:));   % in shadowed region, take anything that's green
    else
        overlap_mask = (intMask & fullMask{2});
        if any(overlap_mask(:))    % if any of the paw is inside the box, make
                                   % sure to check below the shelf for
                                   % the paw (may be partially obscured
                                   % by the shelf)
            projMask = projMaskFromTangentLines(fullMask{2},fundMat,[1 1 w-1 h-1],[h,w]);
            overlap_mask = (projMask & (belowShelfMask | shelfMask));
            if any(overlap_mask(:))    % part of mirror view projection overlaps the shelf and/or region below the shelf
                                       % this means there is probably
                                       % (certainly?) part of the paw
                                       % obscured by the shelf, and we
                                       % need to see if the paw is
                                       % visible below the shelf 
                tempMask = false(h,w);
                tempMask(bbox(1,2):bbox(1,2)+bbox(1,4),...
                         bbox(1,1):bbox(1,1)+bbox(1,3)) = true;
                extended_bbox = [bbox(1,1),bbox(1,2),bbox(1,3),h-bbox(1,2)];   % extend direct view bounding box to the bottom of the image
                tempMask2 = false(h,w);
                tempMask2(extended_bbox(2):extended_bbox(2)+extended_bbox(4),...
                          extended_bbox(1):extended_bbox(1)+extended_bbox(3)) = true;
                tempMask2 = tempMask2 & projMask;   % projection mask directly below bbox
                tempMask = tempMask | tempMask2;
                s = regionprops(tempMask,'boundingbox');
                bbox(1,:) = round(s.BoundingBox);
                bbox(1,4) = bbox(1,4) + 10;    % cushion in case mirror view was too restrictive
            end
        end
        
        viewMask = im_masked(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                             bbox(iView,1):bbox(iView,1) + bbox(iView,3));
        rgViewMask = rgMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...   % looking for places in raw image where green and red channels are different (not white/black/grey)
                            bbox(iView,1):bbox(iView,1) + bbox(iView,3));

        imView{iView} = image_ud(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                          bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
        decorr_fg{iView} = decorrstretch(imView{iView},'tol',stretchTol);
        decorr_hsv{iView} = rgb2hsv(decorr_fg{iView});

        belowShelfRegion = belowShelfMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                                          bbox(iView,1):bbox(iView,1) + bbox(iView,3));
        floorRegion = floorMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                                bbox(iView,1):bbox(iView,1) + bbox(iView,3));
        viewMask = viewMask & ~floorRegion;    % paw can't be in front of the floor
                                      
        belowShelf_hsv = decorr_hsv{iView} .* repmat(double(belowShelfRegion),1,1,3);
        any_greenMask{iView} = HSVthreshold(belowShelf_hsv, pawHSVrange(3,:));
        
    end
    
    decorr_hsv{iView} = decorr_hsv{iView} .* repmat(double(viewMask),1,1,3);

    greenMask{iView} = HSVthreshold(decorr_hsv{iView}, pawHSVrange(1,:)) | any_greenMask{iView};
%     redMask{iView} = HSVthreshold(decorr_hsv{iView}, pawHSVrange(2,:));

    [~,~,~,greenLabMat] = step(restrictiveBlob,greenMask{iView});
    greenMask{iView} = (greenLabMat > 0);
%     [~,~,~,redLabMat] = step(restrictiveBlob,redMask{iView} );
%     redMask{iView} = (redLabMat > 0);
% 
%     overlap_mask = imdilate(greenMask{iView},strel('square',maxRedGreenDist)) & ...
%                    redMask{iView};
%     redMask{iView} = imreconstruct(overlap_mask, redMask{iView});

%     tempMask = (greenMask{iView} | redMask{iView}) & ~rgViewMask;
%     mask = processMask(tempMask, 2);
    mask = greenMask{iView};
    mask = processMask(mask, 2);
    fullMask{iView} = false(h,w);
    fullMask{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                    bbox(iView,1):bbox(iView,1) + bbox(iView,3)) = mask;

    projMask = false(h,w);
    
    if iView == 2
        labMat = bwlabel(fullMask{iView});
        for ii = 1 : max(labMat(:))
            projMask = projMask | ...
                projMaskFromTangentLines((labMat==ii), fundMat, [1 1 w-1 h-1], [h,w]);
        end
    end
    fullMask{iView} = bwconvhull(fullMask{iView},'union');
end
        
% get rid of any blobs so far out of range that the projections from
% either view don't intersect them. But, include parts of the mask that
% are outside the projection.
mirror_projMask = projMaskFromTangentLines(fullMask{2}, fundMat, [1 1 w-1 h-1], [h,w]);
direct_projMask = projMaskFromTangentLines(fullMask{1}, fundMat, [1 1 w-1 h-1], [h,w]);

mirror_proj_overlap = (fullMask{2} & direct_projMask);
direct_proj_overlap = (fullMask{1} & mirror_projMask);

fullMask{1} = imreconstruct(direct_proj_overlap, fullMask{1});
fullMask{2} = imreconstruct(mirror_proj_overlap, fullMask{2});

fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);

% eliminate the floor
fullMask{1} = fullMask{1} & ~floorMask;
direct_projMask = projMaskFromTangentLines(fullMask{1}, fundMat, [1 1 w-1 h-1], [h,w]);
fullMask{2} = fullMask{2} & direct_projMask;