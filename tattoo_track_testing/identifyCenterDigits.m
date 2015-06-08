function digitMask = identifyCenterDigits(im, digitMirrorMask, fundmat, register_ROI, varargin)
%
% usage: 
%
% INPUTS:
%
% OUTPUTS:

hsv_digitBounds = [0.55 0.25 0.00 0.40 0.20 0.50
                   0.70 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.35 0.60 0.40 1.00
                   0.25 0.10 0.40 1.00 0.40 1.00
                   0.00 0.10 0.60 1.00 0.40 1.00];

paw_hsv_thresh = [0.5 0.5 0.20 0.6 0.20 0.7];

pawBlob = vision.BlobAnalysis;
pawBlob.AreaOutputPort = true;
pawBlob.CentroidOutputPort = true;
pawBlob.BoundingBoxOutputPort = true;
pawBlob.LabelMatrixOutputPort = true;
pawBlob.MinimumBlobArea = 1000;
pawBlob.MaximumBlobArea = 5000;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case digitBounds,
            hsv_digitBounds = varargin{iarg + 1};
    end
end

ctrImg = uint8(im(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                  register_ROI(2,1):register_ROI(2,1) + register_ROI(2,3), :));

ctrMask = HSVthreshold(rgb2hsv(ctrImg), paw_hsv_thresh);
SE = strel('disk',2);
ctrMask = bwdist(tempMask) < 2;
ctrMask = imopen(tempMask, SE);
ctrMask = imclose(tempMask, SE);
ctrMask = imfill(tempMask, 'holes');
    

[paw_a, paw_c, paw_bbox, paw_labMat] = step(pawBlob, ctrMask);
figure
imshow(ctrMask);
% threshold the center image to find where the paw grossly should be
% located

figure(1);imshow(ctrImg);hold on
for ii = 1 : size(digitMirrorMask, 1)
    [epi_y, epi_x] = find(squeeze(digitMirrorMask(:,:,ii)));
    epiLines = epipolarLine(fundmat, [epi_x,epi_y]);
    pts = lineToBorderPoints(epiLines, [size(ctrImg,1),size(ctrImg,2)]);
    line(pts(:,[1,3])', pts(:,[2,4])');
    
end