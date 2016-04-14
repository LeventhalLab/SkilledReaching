function [fullMask,bbox] = trackNextStep( image_ud, BGimg_ud, prevMasks, boxRegions, fundMat, pawPref, varargin)

h = size(image_ud,1); w = size(image_ud,2);

maxFrontPanelSep = 20;
maxDistPerFrame = 20;
threshFrameExpansion = 30;

stretchTol = [0.0 1.0];
foregroundThresh = 45/255;

frontPanelMask = boxRegions.frontPanelMask;
intMask = boxRegions.intMask;
% extMask = boxRegions.extMask;
shelfMask = boxRegions.shelfMask;
belowShelfMask = boxRegions.belowShelfMask;
floorMask = boxRegions.floorMask;

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

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
%         case 'pawgraylevels',
%             pawGrayLevels = varargin{iarg + 1};
%         case 'pixelcountthreshold',
%             pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'pawhsvrange',
            pawHSVrange = varargin{iarg + 1};
%         case 'maxredgreendist',
%             maxRedGreenDist = varargin{iarg + 1};
%         case 'minrgdiff',
%             minRGDiff = varargin{iarg + 1};
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
prevMask_dilate = cell(1,2);
for iView = 1 : 2
    prevMask_dilate{iView} = imdilate(prevMasks{iView},strel('disk',maxDistPerFrame));
    s = regionprops(prevMask_dilate{iView},'boundingbox');
    bbox(iView,:) = round(s.BoundingBox);
end

bbox(:,1) = bbox(:,1) - threshFrameExpansion/2;
bbox(:,2) = bbox(:,2) - threshFrameExpansion/2;
bbox(:,3) = bbox(:,3) + threshFrameExpansion;
bbox(:,4) = bbox(:,4) + threshFrameExpansion;

% if any of the previous mask is on the interior side of the front
% panel, don't add the width of the front panel to the search window
overlap_mask = prevMask_dilate{2} & frontPanelMask;
if any(overlap_mask(:))
    if strcmpi(pawPref,'right')
        bbox(2,3) = bbox(2,3) + boxFrontThick;
    else
        bbox(2,1) = bbox(2,1) + boxFrontThick;
        bbox(2,3) = bbox(2,3) - boxFrontThick;
    end
%     prevMask_dilate{2} = prevMask_dilate{2} | frontPanelMask;
end
bbox(bbox<=0) = 1;

BGdiff = imabsdiff(image_ud, BGimg_ud);
% orig_image_ud = image_ud;
image_ud = color_adapthisteq(image_ud);
% full_decorr = decorrstretch(image_ud,'tol',stretchTol);
% full_hsv = rgb2hsv(full_decorr);

im_masked = false(h,w);
for iChannel = 1 : 3
    im_masked = im_masked | (BGdiff(:,:,iChannel) > foregroundThresh);
end
orig_im_mask = im_masked;
im_masked = processMask(orig_im_mask, 2);
im_masked = imdilate(im_masked,strel('disk',maskDilate));

% rgDiffMap = abs(image_ud(:,:,2) - image_ud(:,:,1));
% rgMask = rgDiffMap < minRGDiff;

fullMask = cell(1,2);
% redMask = cell(1,2);
greenMask = cell(1,2);
any_greenMask = cell(1,2);
imView = cell(1,2);
decorr_fg = cell(1,2);
decorr_hsv = cell(1,2);
% full_hsv_cropped = cell(1,2);
% meanHSV = cell(1,2);
viewMask = cell(1,2);
% prevMask_crop = cell(1,2);

projMask = true(h,w);
for iView = 2:-1:1
	im_masked = projMask & im_masked;
    im_masked = im_masked & (prevMask_dilate{1} | prevMask_dilate{2});
%     prevMask_crop{iView} = prevMask_dilate{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                              bbox(iView,1):bbox(iView,1) + bbox(iView,3));
    
    if iView == 2
        viewMask{iView} = im_masked(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                             bbox(iView,1):bbox(iView,1) + bbox(iView,3));
%         rgViewMask = rgMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                             bbox(iView,1):bbox(iView,1) + bbox(iView,3));
        imView{iView} = image_ud(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                                 bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
        decorr_fg{iView} = decorrstretch(imView{iView},'tol',stretchTol);
        decorr_hsv{iView} = rgb2hsv(decorr_fg{iView});
%         full_hsv_cropped{iView} = full_hsv(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                                            bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
%         meanHSV{iView} = zeros(size(full_hsv_cropped{iView}));
%         meanHSV{iView}(:,:,2:3) = (decorr_hsv{iView}(:,:,2:3) + full_hsv_cropped{iView}(:,:,2:3)) / 2;
%         temp = zeros(size(viewMask{iView},1),size(viewMask{iView},2),2);
%         temp(:,:,1) = decorr_hsv{iView}(:,:,1);
%         temp(:,:,2) = full_hsv_cropped{iView}(:,:,1);
%         meanHSV{iView}(:,:,1) = circMean(temp,0,1,3);    % circular average for hue values
                                   
%         behindPanelRegion = intMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                                     bbox(iView,1):bbox(iView,1) + bbox(iView,3));
        temp = imdilate(frontPanelMask,strel('disk',maxFrontPanelSep));
        temp = temp & intMask;
        behindPanelRegion = temp(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                                    bbox(iView,1):bbox(iView,1) + bbox(iView,3));
                                
%         viewMask{iView} = viewMask{iView} | behindPanelRegion;   % because shadow behind front panel is often dark in background and video images
%         behindPanelRegion = behindPanelRegion & viewMask{iView};
        behindPanel_hsv = decorr_hsv{iView} .* repmat(double(behindPanelRegion),1,1,3);
%         behindPanel_hsv = meanHSV{iView} .* repmat(double(behindPanelRegion),1,1,3);
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
                tempMask = bwconvhull(tempMask,'union');
                s = regionprops(tempMask,'boundingbox');
                bbox(1,:) = round(s.BoundingBox);
                bbox(1,4) = min(bbox(1,4) + 10,h-bbox(1,2));    % cushion in case mirror view was too restrictive
            end
        end
        
        bbox(bbox<=0) = 1;
        viewMask{iView} = im_masked(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                             bbox(iView,1):bbox(iView,1) + bbox(iView,3));
%         rgViewMask = rgMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...   % looking for places in raw image where green and red channels are different (not white/black/grey)
%                             bbox(iView,1):bbox(iView,1) + bbox(iView,3));

        imView{iView} = image_ud(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                          bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
        decorr_fg{iView} = decorrstretch(imView{iView},'tol',stretchTol);
        decorr_hsv{iView} = rgb2hsv(decorr_fg{iView});
        
%         full_hsv_cropped{iView} = full_hsv(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                                            bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
%         meanHSV{iView} = zeros(size(full_hsv_cropped{iView}));
%         meanHSV{iView}(:,:,2:3) = (decorr_hsv{iView}(:,:,2:3) + full_hsv_cropped{iView}(:,:,2:3)) / 2;
%         temp = zeros(size(viewMask{iView},1),size(viewMask{iView},2),2);
%         temp(:,:,1) = decorr_hsv{iView}(:,:,1);
%         temp(:,:,2) = full_hsv_cropped{iView}(:,:,1);
%         meanHSV{iView}(:,:,1) = circMean(temp,0,1,3);    % circular average for hue values

        belowShelfRegion = belowShelfMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                                          bbox(iView,1):bbox(iView,1) + bbox(iView,3));
        floorRegion = floorMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                                bbox(iView,1):bbox(iView,1) + bbox(iView,3));
%         viewMask{iView} = viewMask{iView} & ~floorRegion;    % paw can't be in front of the floor
               
        belowShelfRegion = belowShelfRegion & viewMask{iView};
        belowShelf_hsv = decorr_hsv{iView} .* repmat(double(belowShelfRegion),1,1,3);
%         belowShelf_hsv = meanHSV{iView} .* repmat(double(belowShelfRegion),1,1,3);
        any_greenMask{iView} = HSVthreshold(belowShelf_hsv, pawHSVrange(3,:));
        
    end
    
%     decorr_hsv{iView} = decorr_hsv{iView} .* repmat(double(viewMask{iView}),1,1,3);
%     meanHSV{iView} = meanHSV{iView} .* repmat(double(viewMask{iView}),1,1,3);

%     greenMask{iView} = HSVthreshold(meanHSV{iView}, pawHSVrange(1,:)) | any_greenMask{iView};
    greenMask{iView} = HSVthreshold(decorr_hsv{iView}, pawHSVrange(1,:));% | any_greenMask{iView};
%     redMask{iView} = HSVthreshold(decorr_hsv{iView}, pawHSVrange(2,:));

%     [~,~,~,greenLabMat] = step(restrictiveBlob,greenMask{iView});
%     greenMask{iView} = (greenLabMat > 0);
%     [~,~,~,redLabMat] = step(restrictiveBlob,redMask{iView} );
%     redMask{iView} = (redLabMat > 0);
% 
%     overlap_mask = imdilate(greenMask{iView},strel('square',maxRedGreenDist)) & ...
%                    redMask{iView};
%     redMask{iView} = imreconstruct(overlap_mask, redMask{iView});

%     tempMask = (greenMask{iView} | redMask{iView}) & ~rgViewMask;
%     mask = processMask(tempMask, 2);
    mask = greenMask{iView} & viewMask{iView};
    mask = imreconstruct(mask,greenMask{iView});
    mask = mask | any_greenMask{iView};
    mask = processMask(mask, 2);
    fullMask{iView} = false(h,w);
    fullMask{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
                    bbox(iView,1):bbox(iView,1) + bbox(iView,3)) = mask;
   
    if iView == 2 && any(fullMask{2}(:))
        projMask = projMaskFromTangentLines(fullMask{2}, fundMat, [1 1 w-1 h-1], [h,w]);
%         labMat = bwlabel(fullMask{iView});
%         for ii = 1 : max(labMat(:))
%             projMask = projMask | ...
%                 projMaskFromTangentLines((labMat==ii), fundMat, [1 1 w-1 h-1], [h,w]);
%         end
    end
    fullMask{iView} = bwconvhull(fullMask{iView},'union');
end
        
% get rid of any blobs so far out of range that the projections from
% either view don't intersect them. But, include parts of the mask that
% are outside the projection.
proj_overlap = cell(1,2);
for iView = 1 : 2
    if any(fullMask{iView})
        projMask = projMaskFromTangentLines(fullMask{iView}, fundMat, [1 1 w-1 h-1], [h,w]);
        proj_overlap{iView} = (fullMask{3-iView} & projMask);
    else
        proj_overlap{iView} = fullMask{3-iView};
    end
end

for iView = 1 : 2
    fullMask{iView} = imreconstruct(proj_overlap{3-iView},fullMask{iView});
end

fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);

% eliminate the floor
fullMask{1} = fullMask{1} & ~floorMask;
direct_projMask = projMaskFromTangentLines(fullMask{1}, fundMat, [1 1 w-1 h-1], [h,w]);
fullMask{2} = fullMask{2} & direct_projMask;