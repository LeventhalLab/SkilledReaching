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

stretchTol = [0.0 1.0];
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
    end
end

decorr_green_prev = decorrstretch(prev_image_ud,...
                             'targetmean',targetMean(1,:),...
                             'targetsigma',targetSigma(1,:));
decorr_green_ad_prev = color_adapthisteq(decorr_green_prev);
decorr_green_hsv_prev = rgb2hsv(decorr_green_ad_prev);

% prevPaw = cell(1,2);
% for iView = 1 : 2
%     temp = prevMasks{iView}(:);
%     prevPawVals{iView} = zeros(sum(temp),3);
%     for iCh = 1 : 3
%         temp_image = squeeze(decorr_green_hsv_prev(:,:,iCh));
%         temp_image = temp_image(:);
%         prevPawVals{iView}(:,iCh) = temp_image(temp);
%     end
% end

bbox = zeros(2,4);
prevMask_dilate = cell(1,2);
for iView = 1 : 2
    prevMask_dilate{iView} = imdilate(prevMasks{iView},strel('disk',maxDistPerFrame));
end
% 
% bbox(:,1) = bbox(:,1) - threshFrameExpansion/2;
% bbox(:,2) = bbox(:,2) - threshFrameExpansion/2;
% bbox(:,3) = bbox(:,3) + threshFrameExpansion;
% bbox(:,4) = bbox(:,4) + threshFrameExpansion;

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

% bbox(bbox<=0) = 1;

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
% end
% hsvView = cell(1,2);
% meanHSVdist = cell(1,2);
% pixDist = cell(1,2);
% greenHSVmask = false(h,w);
% for iView = 1 : 2
%     s = regionprops(prevMask_dilate{iView},'boundingbox');
%     bbox(iView,:) = round(s.BoundingBox);
%     
%     hsvView{iView} = decorr_green_hsv(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                              bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
                         
% 	meanHSVdist{iView} = estimateHSVprob(prevPawVals{iView},hsvView{iView});
%     temp = prevMasks{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                              bbox(iView,1):bbox(iView,1) + bbox(iView,3));
%     pixDist{iView} = bwdist(temp) / maxDistPerFrame;
%     HSVdist = sqrt(sum(meanHSVdist{iView}.^2,3));
%     temp = HSVdist < HSV_distThresh;
%     greenHSVmask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                  bbox(iView,1):bbox(iView,1) + bbox(iView,3)) = temp;
% end

greenHSVmask = HSVthreshold(decorr_green_hsv, pawHSVrange(1,:));
greenHSVmask = greenHSVmask | behindPanel_green | belowShelf_green;
greenHSVmask_pr = processMask(greenHSVmask,2);
greenHSVmask_pr = greenHSVmask_pr & (prevMask_dilate{1} | prevMask_dilate{2});
greenHSVmask_bg = greenHSVmask_pr & im_masked;

% digHSVmask = HSVthreshold(decorr_green_hsv, pawHSVrange(2,:));

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



% 
% fullMask = cell(1,2);
% greenMask = cell(1,2);
% imView = cell(1,2);
% decorr_fg = cell(1,2);
% decorr_hsv = cell(1,2);
% viewMask = cell(1,2);
% lib_greenMask = cell(1,2);
% res_greenMask{iView} = cell(1,2);
% view_BGdiff = cell(1,2);
% HSVdiff = cell(1,2);
% prevMask_plusHidden = cell(1,2);
% 
% projMask = true(h,w);
% projMask_dilate = cell(1,2);
% for iView = 2:-1:1
% 	im_masked = projMask & im_masked;
%     viewMask{iView} = im_masked(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                                 bbox(iView,1):bbox(iView,1) + bbox(iView,3));
% %     view_BGdiff{iView} = BGdiff(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
% %                                 bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
% % 	temp = max(minDiffVal, max(view_BGdiff{iView},[],3));
% % 	summary_BGdiff = ones(size(view_BGdiff{iView},1),size(view_BGdiff{iView},2)) ./ temp;
% %     summary_BGdiff = summary_BGdiff / diffScale;
% %     summary_BGdiff = 1 - exp(-temp * diffScale);
% 
%     if iView == 2
%         temp = prevMask_dilate{2} & frontPanelMask;
%         if any(temp(:))   % make sure to look both in front of and behind the front panel if the previous blob was near it
%             panelMaskEdge = imdilate(frontPanelMask, strel('disk',maxFrontPanelSep));
%             projMask_dilate{iView} = projMaskFromTangentLines(prevMask_dilate{1}, fundMat, [1 1 w-1 h-1], [h,w]);
%             prevMask_plusHidden{2} = panelMaskEdge & projMask_dilate{iView};
% %             intMaskEdge = prevMask_plusHidden{2} & intMask;
%             prevMask_plusHidden{iView} = prevMask_plusHidden{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                                 bbox(iView,1):bbox(iView,1) + bbox(iView,3));
%             viewMask{iView} = viewMask{iView} | prevMask_plusHidden{iView};
% %             intMaskEdge = intMaskEdge(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
% %                                 bbox(iView,1):bbox(iView,1) + bbox(iView,3));
% %             behindPanelPts = find(intMaskEdge(:));
% %             summary_BGdiff(behindPanelPts) = summary_BGdiff(behindPanelPts) * 1.5;
% %             summary_BGdiff(summary_BGdiff>1) = 1;
%         else
%             prevMask_plusHidden{iView} = false(bbox(iView,4)+1,bbox(iView,3)+1);
%         end
%     end
%     if iView == 1
%         temp = prevMask_dilate{1} & shelfMask;
%         temp2 = intMask & fullMask{2};
%         if any(temp(:)) && any(temp2(:))  % make sure to look both above and below the shelf if the previous blob was near it
%             shelfEdge = imdilate(shelfMask, strel('disk',maxFrontPanelSep));
%             projMask_dilate{iView} = projMaskFromTangentLines(prevMask_dilate{2}, fundMat', [1 1 w-1 h-1], [h,w]);
%             prevMask_plusHidden{1} = shelfEdge & projMask_dilate{iView};
%             prevMask_plusHidden{iView} = prevMask_plusHidden{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                                 bbox(iView,1):bbox(iView,1) + bbox(iView,3));
%             viewMask{iView} = viewMask{iView} | prevMask_plusHidden{iView};
%         else
%             prevMask_plusHidden{iView} = false(bbox(iView,4)+1,bbox(iView,3)+1);
%         end
%     end
%     
% %     im_masked = im_masked & (prevMask_dilate{1} | prevMask_dilate{2});
% %     temp = im_masked & projMask;
% %     viewMask{iView} = temp(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
% %                                 bbox(iView,1):bbox(iView,1) + bbox(iView,3));
%     imView{iView} = image_ud(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                              bbox(iView,1):bbox(iView,1) + bbox(iView,3),:);
%     decorr_fg{iView} = decorrstretch(imView{iView},'tol',stretchTol);
%     decorr_hsv{iView} = rgb2hsv(decorr_fg{iView});
%     
%     HSVdiff{iView} = calcHSVdist(decorr_hsv{iView}, [1/3, 0.85, 0.85]);
%     
% %     s = regionprops(prevMasks{iView},'centroid');
% %     prev_centroid = s.Centroid - bbox(iView,1:2);
% %     dist_from_prev_centroid = zeros(bbox(iView,4)+1,bbox(iView,3)+1);
% %     dist_from_prev_mask = zeros(bbox(iView,4)+1,bbox(iView,3)+1);
%     curMask = prevMasks{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                              bbox(iView,1):bbox(iView,1) + bbox(iView,3)) | prevMask_plusHidden{iView};
% % 	tic
% %     for i_x = 1 : size(dist_from_prev_centroid,2)
% %         for i_y = 1 : size(dist_from_prev_centroid,1)
% % %             dist_from_prev_centroid(i_y,i_x) = sqrt((i_y - prev_centroid(2))^2 + (i_x - prev_centroid(1))^2);
% %             
% %             if curMask(i_y,i_x)
% %                 dist_from_prev_mask(i_y,i_x) = 0;
% %             else
% %                 dist_from_prev_mask(i_y,i_x) = distFromBlob(curMask,[i_x,i_y]);
% %             end
% %             
% %         end
% %     end
% %     toc
% 
%     dist_from_prev_mask = bwdist(curMask);
%     
% %     dist_from_prev_centroid = dist_from_prev_centroid / maskRadius;
% %     temp = exp(-dist_from_prev_centroid / maskRadius);
%     scaled_dist_from_mask = exp(-dist_from_prev_mask / maskRadius);
%     
%     HSVprob = (HSVdiff{iView}(:,:,1)*HSVweights(1) + ...
%                HSVdiff{iView}(:,:,2)*HSVweights(2) + ...
%                HSVdiff{iView}(:,:,1)*HSVweights(3)) / sum(HSVweights);
% 
%     HSVmask = HSVthreshold(decorr_hsv{iView},pawHSVrange(3,:));
%     HSVprob(~HSVmask) = 1;
% 	HSVprob = 1 - HSVprob;
% 	summary_prob = ((HSVprob * summaryWeights(1) + ...
%                      scaled_dist_from_mask * summaryWeights(2))/sum(summaryWeights));% .* summary_BGdiff;
% 	summary_prob = summary_prob .* double(viewMask{iView});
%     
% %     lib_greenMask{iView} = HSVthreshold(decorr_hsv{iView}, pawHSVrange(3,:));
% %     res_greenMask{iView} = HSVthreshold(decorr_hsv{iView}, pawHSVrange(1,:));
% %     
% %     if iView == 2
% %         % look just behind the front panel for green pixels
% %         temp = imdilate(frontPanelMask,strel('disk',maxFrontPanelSep));
% %         temp = temp & intMask;
% %         res_behindPanelMask = HSVthreshold(decorr_hsv{iView}, pawHSVrange(2,:));
% %         if isempty(projMask_dilate{iView})
% %             projMask_dilate{iView} = true(size(temp));
% %         end
% %         behindPanelMask = temp & projMask_dilate{iView};igure;
% %         behindPanelMask = behindPanelMask(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
% %                                           bbox(iView,1):bbox(iView,1) + bbox(iView,3));
% %         res_behindPanelMask = res_behindPanelMask & behindPanelMask;
% %         viewMask{iView} = viewMask{iView} | behindPanelMask;
% %         res_greenMask{iView} = res_greenMask{iView} | res_behindPanelMask;
% %         res_greenMask{iView} = res_greenMask{iView} | (lib_greenMask{iView} & behindPanelMask);
% %     end
%         
% %     temp = processMask(lib_greenMask{iView},2);
% %     res_greenMask{iView} = imerode(res_greenMask{iView},strel('disk',1));
% %     greenMask{iView} = imreconstruct(res_greenMask{iView}, temp);
% % 
% %     mask = greenMask{iView} & viewMask{iView};    % allow green area to extend outside background diff mask, but only if they overlap
% %     mask = imreconstruct(mask,greenMask{iView});
% 
%     mask = (summary_prob > summary_thresh);
% 
%     mask = processMask(mask, 2);
%     fullMask{iView} = false(h,w);
%     fullMask{iView}(bbox(iView,2):bbox(iView,2) + bbox(iView,4),...
%                     bbox(iView,1):bbox(iView,1) + bbox(iView,3)) = mask;
%    
%     if iView == 2 && any(fullMask{2}(:))
%         projMask = projMaskFromTangentLines(fullMask{2}, fundMat, [1 1 w-1 h-1], [h,w]);
%     end
%     fullMask{iView} = bwconvhull(fullMask{iView},'union');
% end
%         
% get rid of any blobs so far out of range that the projections from
% either view don't intersect them. But, include parts of the mask that
% are outside the projection.

% proj_overlap = cell(1,2);
% for iView = 1 : 2
%     if any(fullMask{iView})
%         projMask = projMaskFromTangentLines(fullMask{iView}, fundMat, [1 1 w-1 h-1], [h,w]);
%         proj_overlap{iView} = (fullMask{3-iView} & projMask);
%     else
%         proj_overlap{iView} = fullMask{3-iView};
%     end
% end
% 
% for iView = 1 : 2
%     fullMask{iView} = imreconstruct(proj_overlap{3-iView},fullMask{iView});
% end
% 
% fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);
% 
% % eliminate the floor
% if any(fullMask{1}(:))
%     fullMask{1} = fullMask{1} & ~floorMask;
%     if any(fullMask{1}(:))
%         direct_projMask = projMaskFromTangentLines(fullMask{1}, fundMat, [1 1 w-1 h-1], [h,w]);
%         fullMask{2} = fullMask{2} & direct_projMask;
%     end
% end