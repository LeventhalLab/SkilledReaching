function box3d = find_3d_boundingbox(mask,boxCalibration,pawPref)

h = size(mask{1},1);w = size(mask{1},2);

switch pawPref
    case 'right'
        dorsum_F = squeeze(boxCalibration.srCal.F(:,:,1));   % F that relates direct view to mirror view of dorsum of paw
        palmar_F = squeeze(boxCalibration.srCal.F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
    case 'left'
        dorsum_F = squeeze(boxCalibration.srCal.F(:,:,2));   % F that relates direct view to mirror view of dorsum of paw
        palmar_F = squeeze(boxCalibration.srCal.F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
end
boxMask = cell(1,2);
boxProjMask = cell(1,2);

for iView = 1 : 2
    convMask{iView} = bwconvhull(mask{iView});
    s = regionprops(convMask{iView},'boundingbox');
    boxMask{iView} = false(h,w);
    boxBorders = round([s.BoundingBox(1),s.BoundingBox(2),s.BoundingBox(1) + s.BoundingBox(3),s.BoundingBox(2) + s.BoundingBox(4)];
    boxMask{iView}(boxBorders(2):boxBorders(4),boxBorders(1):boxBorders(3)) = true;
    boxProjMask{iView} = projMaskFromTangentLines(boxMask{iView}, dorsum_F, [1,1,h-1,w-1], [h,w]);
end

fullProjMask = boxProjMask{1} | boxProjMask{2};

% extend the boxes so the corners touch the full projection mask
for iView = 1 : 2
    testMask = boxMask{iView} & ~fullProjMask;
    
    if any(testMask(:))    % the box