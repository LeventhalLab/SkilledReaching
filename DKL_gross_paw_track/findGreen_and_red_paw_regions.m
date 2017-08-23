function [greenMask,redMask] = findGreen_and_red_paw_regions(img, pawMask, prev_pawMask, boxCalibration, pawPref, boxRegions)
projection_dilate_factor = 20;
mask_dilate_factor = 30;

F = boxCalibration.srCal.F;
valid_red_lims_boxExt = [0.35,1;
                0.35,1];    % min and max values of grayscale image that can be accepted in direct (first row) or indirect (second row) views
valid_red_lims_boxInt = [0.1,1;
                0.1,1];    % min and max values of grayscale image that can be accepted in direct (first row) or indirect (second row) views
valid_green_lims_boxExt = [0.35,1;
                           0.1,1];    % min and max values of grayscale image that can be accepted in direct (first row) or indirect (second row) views
valid_green_lims_boxInt = [0.1,1;
                           0.1,1];
            
intMask = boxRegions.intMask;

whiteThresh = [0.9,0.7];
Pthresh = 0.95;
h = size(pawMask{1},1); w = size(pawMask{1},2);

% view 1 is the direct view
% view 2 is the view with the dorsum of the paw
% view 3 is the view with the palmar aspect of the paw

switch pawPref
    case 'right'
        dorsum_F = squeeze(F(:,:,1));   % F that relates direct view to mirror view of dorsum of paw
%         palmar_F = squeeze(F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
    case 'left'
        dorsum_F = squeeze(F(:,:,2));   % F that relates direct view to mirror view of dorsum of paw
%         palmar_F = squeeze(F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
end
projMask = cell(1,2);
prev_projMask = cell(1,2);
for iView = 1 : 2
    projMask{iView} = projMaskFromTangentLines(pawMask{iView}, dorsum_F, [1,1,w-1,h-1], [h,w]);
    prev_projMask{iView} = projMaskFromTangentLines(prev_pawMask{iView}, dorsum_F, [1,1,w-1,h-1], [h,w]);
end

fullProjMask = projMask{1} | projMask{2} | prev_projMask{1} | prev_projMask{2};

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
    testRegion = fullProjMask & (pawMask{iView} | prev_pawMask{iView});
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

maxGreenMask = (full_img_scaled(:,:,2) > full_img_scaled(:,:,1)) & (full_img_scaled(:,:,2) > full_img_scaled(:,:,3));
maxRedMask = (full_img_scaled(:,:,1) > full_img_scaled(:,:,2)) & (full_img_scaled(:,:,1) > full_img_scaled(:,:,3));



testMask_int = pawMask{2} & boxRegions.intMask;
testMask_ext = pawMask{2} & boxRegions.extMask;

if any(testMask_int(:))
    intMaskProj = projMaskFromTangentLines(testMask_int, dorsum_F, [1,1,h-1,w-1],[h,w]);
    shelfOverlap = intMaskProj & imdilate(pawMask{1},strel('disk',40)) & boxRegions.shelfMask;
else
    shelfOverlap = false;
end

regionMask = cell(1,2);
for iView = 1 : 2
    tempRedMask{iView} = false(h,w);
    tempGreenMask{iView} = false(h,w);
    
    region_scaled{iView} = full_img_scaled(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3),:);
    region_rdiff{iView} = region_scaled{iView}(:,:,1) - mean(region_scaled{iView}(:,:,2:3),3);
    region_gdiff{iView} = region_scaled{iView}(:,:,2) - mean(region_scaled{iView}(:,:,[1,3]),3);
    regionMask{iView} = searchRegionMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3));
    region_intMask = boxRegions.intMask(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3));
    region_extMask = boxRegions.extMask(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3));
    
    max_rdiff = max(region_rdiff{iView}(:));
    max_gdiff = max(region_gdiff{iView}(:));
    region_rdiff_scaled{iView} = imadjust(region_rdiff{iView},[0,max_rdiff],[]);
    region_gdiff_scaled{iView} = imadjust(region_gdiff{iView},[0,max_gdiff],[]);
%     region_gray{iView} = rgb2gray(region_scaled{iView});
    
    if iView == 2
        
        validGreenRegion_ext = (squeeze(region_scaled{iView}(:,:,2)) > valid_green_lims_boxExt(iView,1)) & (squeeze(region_scaled{iView}(:,:,2)) < valid_green_lims_boxExt(iView,2));
        validGreenRegion_int = (squeeze(region_scaled{iView}(:,:,2)) > valid_green_lims_boxInt(iView,1)) & (squeeze(region_scaled{iView}(:,:,2)) < valid_green_lims_boxInt(iView,2));
        
        validGreenRegion = validGreenRegion_ext & region_extMask;
        validGreenRegion = validGreenRegion | (validGreenRegion_int & region_intMask);
        
        validRedRegion_ext = (squeeze(region_scaled{iView}(:,:,1)) > valid_red_lims_boxExt(iView,1)) & (squeeze(region_scaled{iView}(:,:,1)) < valid_red_lims_boxExt(iView,2));
        validRedRegion_int = (squeeze(region_scaled{iView}(:,:,1)) > valid_red_lims_boxInt(iView,1)) & (squeeze(region_scaled{iView}(:,:,1)) < valid_red_lims_boxInt(iView,2));
        
        validRedRegion = validRedRegion_ext & region_extMask;
        validRedRegion = validRedRegion | (validRedRegion_int & region_intMask);
    
    else
        if any(testMask_int(:))    % at least part of the paw is inside the box
            validGreenRegion = (squeeze(region_scaled{iView}(:,:,2)) > valid_green_lims_boxInt(iView,1)) & (squeeze(region_scaled{iView}(:,:,2)) < valid_green_lims_boxInt(iView,2));
            validRedRegion = (squeeze(region_scaled{iView}(:,:,1)) > valid_red_lims_boxInt(iView,1)) & (squeeze(region_scaled{iView}(:,:,1)) < valid_red_lims_boxInt(iView,2));
        else   % the paw is entirely outside the box
            validGreenRegion = (squeeze(region_scaled{iView}(:,:,2)) > valid_green_lims_boxExt(iView,1)) & (squeeze(region_scaled{iView}(:,:,2)) < valid_green_lims_boxExt(iView,2));
            validRedRegion = (squeeze(region_scaled{iView}(:,:,1)) > valid_red_lims_boxExt(iView,1)) & (squeeze(region_scaled{iView}(:,:,1)) < valid_red_lims_boxExt(iView,2));
        end
    end
    green_seed{iView} = regionMask{iView} & (region_gdiff_scaled{iView} > 0.5) & validGreenRegion;
    red_seed{iView} = regionMask{iView} & (region_rdiff_scaled{iView} > 0.5) & validRedRegion;
    
    other_seed{iView} = imerode((regionMask{iView} & (region_rdiff{iView}) < 0 & (region_gdiff{iView} < 0.00)),strel('disk',2));
    temp_other = false(size(other_seed{iView}));
    region_edge_width = round(projection_dilate_factor/2); 
    region_width = size(other_seed{iView},2); 
    region_height = size(other_seed{iView},1); 
    temp_other(:,1:region_edge_width) = true;
    temp_other(1:region_edge_width,:) = true;
    temp_other(region_height-region_edge_width : end,:) = true;
    temp_other(:,region_width - region_edge_width : end) = true;
    whiteMask = mean(region_scaled{iView},3) > whiteThresh(iView);
    other_seed{iView} = other_seed{iView} | whiteMask;
    
    final_other_seed{iView} = (other_seed{iView} & ~green_seed{iView} & ~red_seed{iView} ) | temp_other;
    final_green_seed{iView} = green_seed{iView} & ~red_seed{iView} & ~final_other_seed{iView};
    final_red_seed{iView} = red_seed{iView} & ~green_seed{iView} & ~final_other_seed{iView};
    
    if (any(shelfOverlap(:)) || any(testMask_ext(:))) && iView == 1   % if the paw is entirely inside the box, or is partially behind the shelf, don't include the shelf in the scribbles
        region_shelfMask = boxRegions.shelfMask(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3));
        final_red_seed{1} = final_red_seed{1} & ~region_shelfMask;
        final_green_seed{1} = final_green_seed{1} & ~region_shelfMask;
    end
    if (any(shelfOverlap(:))) && iView == 1    % the paw is partially behind the shelf, don't let there be red scribble lateral to green scribble
        excludeRedMask = false(size(final_red_seed{1}));
        [~,x] = find(final_green_seed{1});
        switch pawPref
            case 'left'
                max_green_x = max(x);
                excludeRedMask(:,max_green_x:end) = true;
            case 'right'
                min_green_x = min(x);
                excludeRedMask(:,1:min_green_x) = true;
        end
        final_red_seed{1} = final_red_seed{1} & ~excludeRedMask;
    end
    
    if iView == 2
        % don't accept "red" spots towards the interior of the box from the
        % original paw mask
        [~,x] = find(final_green_seed{2});
        excludeRedMask = false(size(final_red_seed{2}));
        switch pawPref
            case 'left'
%                 interiorGreenPt = find(x==max(x));
                excludeRedMask(:,1:max(x)) = true;
            case 'right'
%                 interiorGreenPt = find(x==min(x));
                excludeRedMask(:,min(x):end) = true;
        end
        final_red_seed{2} = final_red_seed{2} & ~excludeRedMask;
    end
        
    if any(final_green_seed{iView}(:)) && any(final_red_seed{iView}(:))    % red and green blobs both visible in this view
        [~,P] = imseggeodesic(region_scaled{iView},final_green_seed{iView},final_red_seed{iView},final_other_seed{iView},'adaptivechannelweighting',true);
        tempGreenMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3)) = (P(:,:,1) > Pthresh);
        tempRedMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3)) = (P(:,:,2) > Pthresh);
    elseif any(final_green_seed{iView}(:)) && all(~final_red_seed{iView}(:))    % green but not red blobs visible in this view
        [~,P] = imseggeodesic(region_scaled{iView},final_green_seed{iView},final_other_seed{iView},'adaptivechannelweighting',true);
        tempGreenMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3)) = (P(:,:,1) > Pthresh);
        tempRedMask{iView}(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3)) = false;
        P(:,:,3) = P(:,:,2);
        P(:,:,2) = false(size(P,1),size(P,2));
    elseif all(~final_green_seed{iView}(:)) && any(final_red_seed{iView}(:))     % red but not green blobs visible in this view
        
    elseif all(~final_green_seed{iView}(:)) && all(~final_red_seed{iView}(:))       % neither green nor red blobs visible in this view
        
    end
    
    % CAN USE THE P ARRAY TO NOT TAKE POINT WITH LOWER P-VALUES IF THEY
    % OVERLAP WITH THE SHELF IN THE DIRECT OR MIRROR VIEWS
    
    regionProbs(searchRegion(iView,2):searchRegion(iView,4),searchRegion(iView,1):searchRegion(iView,3),:) = P;
        
    tempGreenMask{iView} = tempGreenMask{iView} & maxGreenMask;
    tempRedMask{iView} = tempRedMask{iView} & maxRedMask;
    
    processed_greenMask{iView} = processMask(tempGreenMask{iView},'sesize',1);
    processed_redMask{iView} = processMask(tempRedMask{iView},'sesize',1);
    
    %only accept blobs reasonably close to the original paw mask
    pawTest = imdilate(pawMask{iView},strel('disk',15));
    greenOverlap = processed_greenMask{iView} & pawTest;
    redOverlap = processed_redMask{iView} & pawTest;
    
    processed_greenMask{iView} = imreconstruct(greenOverlap, processed_greenMask{iView});
    processed_redMask{iView} = imreconstruct(redOverlap, processed_redMask{iView});
    
    tempFullMask{iView} = processed_greenMask{iView} | processed_redMask{iView} | pawMask{iView};
    
end
% have we now filled in the direct and mirror views so that the tangent
% lines for the original mirror and direct blobs intersect the new mirror/direct blobs?

viewMatchFlags = false(2,2);
upper_testPt = false(h,w);upper_testPt(1,1) = true;
lower_testPt = false(h,w);lower_testPt(h,w) = true;
new_red_mask = cell(1,2);
new_green_mask = cell(1,2);

% eliminate anything that's too dark
full_scaled_gray = rgb2gray(full_img_scaled);
darkMask = (full_scaled_gray < 0.2);

for iView = 1 : 2
    new_red_mask{iView} = false(h,w);
    new_green_mask{iView} = false(h,w);
    
    processed_greenMask{iView} = processed_greenMask{iView} & ~darkMask;
    processed_redMask{iView} = processed_redMask{iView} & ~darkMask;
    tempFullMask{iView} = processed_greenMask{iView} | processed_redMask{iView} | pawMask{iView};
end

added_pts = false(h,w);
for iView = 1 : 2
    otherView = 3 - iView;
    
    upperTestMask = imreconstruct(upper_testPt,~projMask{otherView});
    lowerTestMask = imreconstruct(lower_testPt,~projMask{otherView});
    
    upperTest = upperTestMask & tempFullMask{iView};
    lowerTest = lowerTestMask & tempFullMask{iView};
    
    viewMatchFlags(iView,1) = any(upperTest(:));
    viewMatchFlags(iView,2) = any(lowerTest(:));
    
end

for iView = 1 : 2
    otherView = 3 - iView;
    upperTestMask = imreconstruct(upper_testPt,~projMask{otherView});
    lowerTestMask = imreconstruct(lower_testPt,~projMask{otherView});
    % NEED TO WORK ON THE CONTINGENCY THAT THE PAW IS
    % PARTIALLY BEHIND THE SHELF. REDO THE CALCULATION USING THE NEW MASKS
    if iView == 1   % could the paw in the direct view be hiding behind the shelf?
        testMask_int = tempFullMask{2} & boxRegions.intMask;

        if any(testMask_int(:))
            intMaskProj = projMaskFromTangentLines(testMask_int, dorsum_F, [1,1,h-1,w-1],[h,w]);
            shelfOverlap = intMaskProj & imdilate(tempFullMask{1},strel('disk',40)) & boxRegions.shelfMask;
        else
            shelfOverlap = false;
        end
    end
    
    [~,x] = find(tempFullMask{iView});
    validEdgeMask = false(h,w);
    validEdgeMask(:,min(x):max(x)) = true;
    validEdgeMask = imdilate(validEdgeMask,strel('disk',10));
    if ~viewMatchFlags(iView,1) || viewMatchFlags(otherView,1)
        % find point(s) along the tangent line from the other view that
        % should be included in the current mask
        upperEdge = bwmorph(upperTestMask,'remove') & validEdgeMask;
%         upperEdge = bwmorph(upperTestMask,'remove') & searchRegionMask{iView};
        Pvals = repmat(double(upperEdge),[1,1,3]) .* regionProbs;
        new_red_mask{iView} = new_red_mask{iView} | Pvals(:,:,2) > 0.5;
        new_green_mask{iView} = new_green_mask{iView} | Pvals(:,:,1) > 0.5;
        
        if any(shelfOverlap(:))
            new_mask_shelf_overlap = (new_green_mask{iView} | new_red_mask{iView}) & boxRegions.shelfMask;
        else
            new_mask_shelf_overlap = false;
        end
                
        
        if (~any(new_red_mask{iView}(:)) && ~any(new_green_mask{iView}(:))) || any(new_mask_shelf_overlap(:))  % there aren't any reasonably green and/or red points along the tangent line from the other view - find the closest point OR look at the previous frame?
            
            % just find the points along the tangent line closest to the blob and add them in
            [y,x] = find(upperEdge);
            if any(processed_greenMask{iView}(:))
                [min_d_green,ptIdx_green] = findPointsClosestToBlob([x,y],processed_greenMask{iView});
            else
                min_d_green = 1000;
            end
            if any(processed_redMask{iView}(:))
                [min_d_red,ptIdx_red] = findPointsClosestToBlob([x,y],processed_redMask{iView});
            else
                min_d_red = 1000;
            end
            if any(pawMask{iView}(:))
                [min_d_paw,ptIdx_paw] = findPointsClosestToBlob([x,y],pawMask{iView});
            else
                min_d_paw = 1000;
            end
            
            min_d = [min_d_green,min_d_red,min_d_paw];
            
            switch min(min_d)
                case min_d_green
                    processed_greenMask{iView}(y(ptIdx_green),x(ptIdx_green)) = true;
                    added_pts(y(ptIdx_green),x(ptIdx_green)) = true;
                case min_d_red
                    processed_redMask{iView}(y(ptIdx_red),x(ptIdx_red)) = true;
                    added_pts(y(ptIdx_red),x(ptIdx_red)) = true;
                case min_d_paw
                    pawMask{iView}(y(ptIdx_paw),x(ptIdx_paw)) = true;
                    added_pts(y(ptIdx_paw),x(ptIdx_paw)) = true;
                otherwise
            end
        else    % there are reasonably green and/or red points along the tangent line from the other view - keep those
            processed_greenMask{iView} = processed_greenMask{iView} | new_green_mask{iView};
            processed_redMask{iView} = processed_redMask{iView} | new_red_mask{iView};
            added_pts = added_pts | new_green_mask{iView} | new_red_mask{iView};
        end
            
    end
    
    if ~viewMatchFlags(iView,2) || viewMatchFlags(otherView,2)
        % find point(s) along the tangent line from the other view that
        % should be included in the current mask
        lowerEdge = bwmorph(lowerTestMask,'remove') & validEdgeMask;
%         lowerEdge = bwmorph(lowerTestMask,'remove') & searchRegionMask{iView};
        Pvals = repmat(double(lowerEdge),[1,1,3]) .* regionProbs;
        new_red_mask{iView} = new_red_mask{iView} | Pvals(:,:,2) > 0.5;
        new_green_mask{iView} = new_green_mask{iView} | Pvals(:,:,1) > 0.5;
        
        if any(shelfOverlap(:))
            new_mask_shelf_overlap = (new_green_mask{iView} | new_red_mask{iView}) & boxRegions.shelfMask;
        else
            new_mask_shelf_overlap = false;
        end
        
        if (~any(new_red_mask{iView}(:)) && ~any(new_green_mask{iView}(:))) || any(new_mask_shelf_overlap(:))  % there aren't any reasonably green and/or red points along the tangent line from the other view - find the closest point OR look at the previous frame?
            % just find the points along the tangent line closest to the blob and add them in
            [y,x] = find(lowerEdge);
            if any(processed_greenMask{iView}(:))
                [min_d_green,ptIdx_green] = findPointsClosestToBlob([x,y],processed_greenMask{iView});
            else
                min_d_green = 1000;
            end
            if any(processed_redMask{iView}(:))
                [min_d_red,ptIdx_red] = findPointsClosestToBlob([x,y],processed_redMask{iView});
            else
                min_d_red = 1000;
            end
            if any(pawMask{iView}(:))
                [min_d_paw,ptIdx_paw] = findPointsClosestToBlob([x,y],pawMask{iView});
            else
                min_d_paw = 1000;
            end
            
            min_d = [min_d_green,min_d_red,min_d_paw];
            
            switch min(min_d)
                case min_d_green
                    processed_greenMask{iView}(y(ptIdx_green),x(ptIdx_green)) = true;
                    added_pts(y(ptIdx_green),x(ptIdx_green)) = true;
                case min_d_red
                    processed_redMask{iView}(y(ptIdx_red),x(ptIdx_red)) = true;
                    added_pts(y(ptIdx_red),x(ptIdx_red)) = true;
                case min_d_paw
                    pawMask{iView}(y(ptIdx_paw),x(ptIdx_paw)) = true;
                    added_pts(y(ptIdx_paw),x(ptIdx_paw)) = true;
                otherwise
            end
        else
            processed_greenMask{iView} = processed_greenMask{iView} | new_green_mask{iView};
            processed_redMask{iView} = processed_redMask{iView} | new_red_mask{iView};
            added_pts = added_pts | new_green_mask{iView} | new_red_mask{iView};
        end
            
    end
    
    tempFullMask{iView} = processed_greenMask{iView} | processed_redMask{iView} | pawMask{iView};
        
end    % for iView...

% now cut off anything that's outside the projection of the new masks
newProjMask = cell(1,2);
for iView = 1 : 2
    otherView = 3 - iView;
    newProjMask{otherView} = projMaskFromTangentLines(tempFullMask{otherView}, dorsum_F, [1,1,h-1,w-1],[h,w]);
    limitMask = newProjMask{otherView} | added_pts;    % don't get rid of points we added in to make the reflection work because they're maybe just outside the projection mask
    greenMask{iView} = processed_greenMask{iView} & limitMask;
    redMask{iView} = processed_redMask{iView} & limitMask;
end


end    % function
% 
% 