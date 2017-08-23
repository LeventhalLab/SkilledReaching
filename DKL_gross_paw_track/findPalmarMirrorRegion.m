function palmarMask = findPalmarMirrorRegion(mask,boxCalibration,pawPref)

h = size(mask{1},1);w = size(mask{1},2);

switch pawPref
    case 'right'
        dorsum_F = squeeze(boxCalibration.srCal.F(:,:,1));   % F that relates direct view to mirror view of dorsum of paw
        palmar_F = squeeze(boxCalibration.srCal.F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
        otherPaw = 'left';
    case 'left'
        dorsum_F = squeeze(boxCalibration.srCal.F(:,:,2));   % F that relates direct view to mirror view of dorsum of paw
        palmar_F = squeeze(boxCalibration.srCal.F(:,:,2));   % F that relates direct view to mirror view of palmar aspect of paw
        otherPaw = 'right';
end

[~,epipole] = isEpipoleInImage(dorsum_F,[h,w]);

ext_pts = cell(1,2);
convMask = cell(1,2);
tanPts = zeros(2,2,2);
tanLines = zeros(2,3,2);

for iView = 1 : 2
    convMask{iView} = bwconvhull(mask{iView});
    mask_ext = bwmorph(convMask{iView},'remove');
    [y,x] = find(mask_ext);
    s = regionprops(mask_ext,'Centroid');
    ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
    
    [tanPts(:,:,iView), tanLines(:,:,iView)] = findTangentToBlob(convMask{iView}, epipole);
end

bboxes = zeros(2,4);
bboxes(1,:) = [1,1,h-1,w-1];
bboxes(2,:) = bboxes(1,:);

[points3d,matchedPoints] = bordersTo3D_bothDirs(ext_pts, boxCalibration, bboxes, tanPts, [h,w]);

points3d_projection1 = project3d_to_2d(points3d{1},boxCalibration,otherPaw);
points3d_projection2 = project3d_to_2d(points3d{2},boxCalibration,otherPaw);
palmarPts = squeeze(points3d_projection1(:,:,2));
palmarPts = [palmarPts;squeeze(points3d_projection2(:,:,2))];

palmarMask = bwconvhull(palmarPts);

end