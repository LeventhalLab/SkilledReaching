function [greenMask,redMask] = findGreen_and_red_paw_regions_behindShelf(img, pawMask, boxCalibration, pawPref, boxRegions)
projection_dilate_factor = 10;
mask_dilate_factor = 30;

F = boxCalibration.srCal.F;

h = size(pawMask{1},1); w = size(pawMask{1},2);

% view 1 is the direct view
% view 2 is the view with the dorsum of the paw
% view 3 is the view with the palmar aspect of the paw

switch pawPref
    case 'right'
        dorsum_F = squeeze(F(:,:,1));   % F that relates direct view to mirror view of dorsum of paw
        palmar_F = squeeze(F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
    case 'left'
        dorsum_F = squeeze(F(:,:,2));   % F that relates direct view to mirror view of dorsum of paw
        palmar_F = squeeze(F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
end
projMask = cell(1,2);
for iView = 1 : 2
    projMask{iView} = projMaskFromTangentLines(pawMask{iView}, dorsum_F, [1,1,w-1,h-1], [h,w]);
end

fullProjMask = projMask{1} | projMask{2};

redMask = cell(1,3);greenMask = cell(1,3);
img_region = cell(1,2);

region_scaled = cell(1,2);
region_rdiff = cell(1,2);
region_gdiff = cell(1,2);
region_rdiff_scaled = cell(1,2);
region_gdiff_scaled = cell(1,2);
searchRegion = zeros(2,4);
searchRegionMask = cell(1,2);

for iView = 1 : 2
    testRegion = fullProjMask & pawMask{iView};
    s = regionprops(testRegion,'boundingbox');
    bbox_left = round(s.BoundingBox(1)) - projection_dilate_factor;
    bbox_right = round(s.BoundingBox(1)) + round(s.BoundingBox(3)) + projection_dilate_factor;
    
    tempMask = false(h,w);
    tempMask(1:h,bbox_left:bbox_right) = true;
    
    searchRegionMask{iView} = imdilate((tempMask & fullProjMask),strel('disk',projection_dilate_factor));
    s = regionprops(searchRegionMask{iView},'boundingbox');
%     s = regionprops(searchRegionMask,'boundingbox');
    
    searchRegion(iView,:) = round([s.BoundingBox(1), s.BoundingBox(2),...
                          s.BoundingBox(1)+s.BoundingBox(3),s.BoundingBox(2)+s.BoundingBox(4)]);
	img_region{iView} = img(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3),:);
                      
end
full_img_scaled = imadjust(img,stretchlim(img_region{1}),[]);
full_img_decorr = decorrstretch(full_img_scaled);
full_img_hsv = rgb2hsv(full_img_decorr);
rdiff = full_img_scaled(:,:,1) - mean(full_img_scaled(:,:,2:3),3);
gdiff = full_img_scaled(:,:,2) - mean(full_img_scaled(:,:,[1,3]),3);
regionProbs = zeros(size(img));
tempRedMask = cell(1,2);
tempGreenMask = cell(1,2);

for iView = 1 : 2
    tempRedMask{iView} = false(h,w);
    tempGreenMask{iView} = false(h,w);
    
    region_scaled{iView} = full_img_scaled(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3),:);
    region_rdiff{iView} = region_scaled{iView}(:,:,1) - mean(region_scaled{iView}(:,:,2:3),3);
    region_gdiff{iView} = region_scaled{iView}(:,:,2) - mean(region_scaled{iView}(:,:,[1,3]),3);
    regionMask{iView} = searchRegionMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3));
    
    max_rdiff = max(region_rdiff{iView}(:));
    max_gdiff = max(region_gdiff{iView}(:));
    region_rdiff_scaled{iView} = imadjust(region_rdiff{iView},[0,max_rdiff],[]);
    region_gdiff_scaled{iView} = imadjust(region_gdiff{iView},[0,max_gdiff],[]);
%     region_gray{iView} = rgb2gray(region_scaled{iView});
    
    green_seed{iView} = regionMask{iView} & (region_gdiff_scaled{iView} > 0.4);
    red_seed{iView} = regionMask{iView} & (region_rdiff_scaled{iView} > 0.4);
    
    other_seed{iView} = imerode((regionMask{iView} & (region_rdiff{iView}) < 0 & (region_gdiff{iView} < 0.00)),strel('disk',2));
    
    final_green_seed{iView} = green_seed{iView} & ~red_seed{iView} & ~other_seed{iView};
    final_red_seed{iView} = red_seed{iView} & ~green_seed{iView} & ~other_seed{iView};
    final_other_seed{iView} = other_seed{iView} & ~green_seed{iView} & ~red_seed{iView};
    [L,P] = imseggeodesic(region_scaled{iView},final_green_seed{iView},final_red_seed{iView},final_other_seed{iView},'adaptivechannelweighting',true);
    
    % CAN USE THE P ARRAY TO NOT TAKE POINT WITH LOWER P-VALUES IF THEY
    % OVERLAP WITH THE SHELF IN THE DIRECT OR MIRROR VIEWS
    
    regionProbs(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3),:) = P;
    
    tempGreenMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3)) = (L==1);
    tempRedMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3)) = (L==2);
    
    processed_greenMask{iView} = processMask(tempGreenMask{iView},'sesize',2);
    processed_redMask{iView} = processMask(tempRedMask{iView},'sesize',2);
    
    tempFullMask{iView} = processed_greenMask{iView} | processed_redMask{iView} | pawMask{iView};
    
end
% have we now filled in the direct and mirror views so that the tangent
% lines for the original mirror and direct blobs intersect the new mirror/direct blobs?

viewMatchFlags = false(2,2);
upper_testPt = false(h,w);upper_testPt(1,1) = true;
lower_testPt = false(h,w);lower_testPt(h,w) = true;
new_red_mask = false(h,w);
new_green_mask = false(h,w);
for iView = 1 : 2
    otherView = 3 - iView;
    
    upperTestMask = imreconstruct(upper_testPt,~projMask{otherView});
    lowerTestMask = imreconstruct(lower_testPt,~projMask{otherView});
    
    upperTest = upperTestMask & tempFullMask{iView};
    lowerTest = lowerTestMask & tempFullMask{iView};
    
    if any(upperTest(:))
        viewMatchFlags(iView,1) = true;
    end
    if any(lowerTest(:))
        viewMatchFlags(iView,2) = true;
    end
    
    if ~viewMatchFlags(iView,1)
        % find point(s) along the tangent line from the other view that
        % should be included in the current mask
        upperEdge = bwmorph(upperTestMask,'remove') & searchRegionMask{iView};
        Pvals = repmat(double(upperEdge),[1,1,3]) .* regionProbs;
        new_red_mask = new_red_mask | Pvals(:,:,1) > 0.5;
        new_green_mask = new_green_mask | Pvals(:,:,2) > 0.5;
        
        if ~any(new_red_mask(:)) && ~any(new_green_mask(:))
            % just find the points along the tangent line closest to the blob and add them in
            [y,x] = find(upperEdge);
            [min_d_green,ptIdx_green] = findPointsClosestToBlob([x,y],processed_greenMask{iView});
            [min_d_red,ptIdx_red] = findPointsClosestToBlob([x,y],processed_redMask{iView});
            if min_d_green < min_d_red
                processed_greenMask{iView}([y(ptIdx_green),x(ptIdx_green)]) = true;
            else
                processed_redMask{iView}([y(ptIdx_red),x(ptIdx_red)]) = true;
            end
        end
            
    end
    
    if ~viewMatchFlags(iView,2)
        % find point(s) along the tangent line from the other view that
        % should be included in the current mask
        lowerEdge = bwmorph(lowerTestMask,'remove') & searchRegionMask{iView};
        Pvals = repmat(double(lowerEdge),[1,1,3]) .* regionProbs;
        new_red_mask = new_red_mask | Pvals(:,:,1) > 0.5;
        new_green_mask = new_green_mask | Pvals(:,:,2) > 0.5;
        
        if ~any(new_red_mask(:)) && ~any(new_green_mask(:))
            % just find the points along the tangent line closest to the blob and add them in
            [y,x] = find(lowerEdge);
            [min_d_green,ptIdx_green] = findPointsClosestToBlob([x,y],processed_greenMask{iView});
            [min_d_red,ptIdx_red] = findPointsClosestToBlob([x,y],processed_redMask{iView});
            if min_d_green < min_d_red
                processed_greenMask{iView}([y(ptIdx_green),x(ptIdx_green)]) = true;
            else
                processed_redMask{iView}([y(ptIdx_red),x(ptIdx_red)]) = true;
            end
        end
    end
    
    tempFullMask{iView} = processed_greenMask{iView} | processed_redMask{iView};
        
end    % for iView...

% now cut off anything that's outside the projection of the new masks
newProjMask = cell(1,2);
for iView = 1 : 2
    otherView = 3 - iView;
    newProjMask{otherView} = projMaskFromTangentLines(tempFullMask{otherView}, dorsum_F, [1,1,h-1,w-1],[h,w]);
    greenMask{iView} = processed_greenMask{iView} & newProjMask{otherView};
    redMask{iView} = processed_redMask{iView} & newProjMask{otherView};
end


end    % function
% 
% 
