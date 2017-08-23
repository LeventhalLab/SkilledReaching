function findGreen_and_red_paw_regions(img, pawMask, F, pawPref, tanLines)
projection_dilate_factor = 10;

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
for iView = 1 : 2
    projMask{iView} = projMaskFromTangentLines(pawMask{iView}, dorsum_F, [1,1,w-1,h-1], [h,w]);
end

fullProjMask = projMask{1} | projMask{2};

for iView = 1 : 2
    testRegion = fullProjMask & pawMask{iView};
    s = regionprops(testRegion,'boundingbox');
    bbox_left = s.BoundingBox(1); %- projection_dilate_factor;
    bbox_right = s.BoundingBox(1) + s.BoundingBox(3); 5 + projection_dilate_factor;
    
    tempMask = false(h,w);
    tempMask(1:h,bbox_left:bbox_right) = true;
    
    searchRegionMask = (tempMask & fullProjMask);
    s = regionprops(searchRegionMask,'boundingbox');
    
    searchRegion = [s.BoundingBox(1)-projection_dilate_factor, s.BoundingBox(2)-projection_dilate_factor,...
                    s.BoundingBox(1)+s.BoundingBox(3)+projection_dilate_factor,s.BoundingBox(2)+s.BoundingBox(4)+projection_dilate_factor];
                
	searchImg = img(searchRegion(2):searchRegion(4),searchRegion(1):searchRegion(3),:);
    
end