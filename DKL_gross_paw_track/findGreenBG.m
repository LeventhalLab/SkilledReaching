function greenBGmask = findGreenBG(BGimg_ud, boxRegions,pawHSVrange, pawPref)

w = size(BGimg_ud,2);h = size(BGimg_ud,1);
floorMask = boxRegions.floorMask;
[y,~] = find(floorMask);
ROI_bot = min(y);

shelfLims = regionprops(boxRegions.shelfMask,'boundingbox');
switch lower(pawPref),
    case 'right',
        ROI = [1,1,floor(shelfLims.BoundingBox(1) + shelfLims.BoundingBox(3)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)),1,ceil(shelfLims.BoundingBox(3)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),1,w-ceil(shelfLims.BoundingBox(1)+shelfLims.BoundingBox(3)),ROI_bot];
    case 'left',
        ROI = [ceil(shelfLims.BoundingBox(1)),1,w-ceil(shelfLims.BoundingBox(1)),ROI_bot;...
               ceil(shelfLims.BoundingBox(1)),1,ceil(shelfLims.BoundingBox(3)),ROI_bot;...
               1,1,floor(shelfLims.BoundingBox(1)),ROI_bot];
end

% mirror_image_ud = image_ud(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:);
direct_image_ud = BGimg_ud(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:);
other_mirror_image_ud = BGimg_ud(ROI(3,2):ROI(3,2)+ROI(3,4),ROI(3,1):ROI(3,1)+ROI(3,3),:);
lh  = stretchlim(other_mirror_image_ud,0.05);
direct_str_img = imadjust(direct_image_ud,lh,[]);
% mirror_str_img = imadjust(mirror_image_ud,lh,[]);
direct_green = decorrstretch(direct_str_img,'tol',0.02);
% mirror_green = decorrstretch(mirror_str_img,'tol',0.02);
decorr_BG = BGimg_ud;
% decorr_green(ROI(1,2):ROI(1,2)+ROI(1,4),ROI(1,1):ROI(1,1)+ROI(1,3),:) = mirror_green;
decorr_BG(ROI(2,2):ROI(2,2)+ROI(2,4),ROI(2,1):ROI(2,1)+ROI(2,3),:) = direct_green;

% slotMask = boxRegions.slotMask;
% slotMask = imdilate(slotMask,strel('line',6,0)) | imdilate(slotMask,strel('line',6,180));
% decorr_BG = decorrstretch(BGimg_ud,'targetmean',targetMean,'targetsigma',targetSigma);
BGhsv = rgb2hsv(decorr_BG);

greenBGmask = HSVthreshold(BGhsv, pawHSVrange);
% greenBGmask = greenBG & slotMask;

end