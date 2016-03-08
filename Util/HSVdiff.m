function imDiff = HSVdiff(hsv1, hsv2)


if size(hsv1,1) == 1
    imDiff = zeros(size(hsv2));
    if ndims(imDiff) == 3
        imDiff(:,:,2) = abs(hsv1(2)-hsv2(:,:,2));
        imDiff(:,:,3) = abs(hsv1(3)-hsv2(:,:,3));
        h2 = squeeze(hsv2(:,:,1));
    else
        imDiff(:,2) = abs(hsv1(2)-hsv2(:,2));
        imDiff(:,3) = abs(hsv1(3)-hsv2(:,3));
        h2 = squeeze(hsv2(:,1));
    end
    
    h1 = squeeze(hsv1(1));
    
elseif size(hsv2,1) == 1
    imDiff = zeros(size(hsv1));
    
    if ndims(imDiff) == 3
        imDiff(:,:,2) = abs(hsv2(2)-hsv1(:,:,2));
        imDiff(:,:,3) = abs(hsv2(3)-hsv1(:,:,3));
        h1 = squeeze(hsv1(:,:,1));
    else
        imDiff(:,2) = abs(hsv2(2)-hsv1(:,2));
        imDiff(:,3) = abs(hsv2(3)-hsv1(:,3));
        h1 = squeeze(hsv1(:,1));
    end
    
    h2 = squeeze(hsv2(1));
    
elseif size(hsv1) == size(hsv2)
    imDiff = zeros(size(hsv1));
    if ndims(imDiff) == 3
        imDiff(:,:,2:3) = abs(hsv1(:,:,2:3)-hsv2(:,:,2:3));
        h1 = squeeze(hsv1(:,:,1));
        h2 = squeeze(hsv2(:,:,1));
    else
        imDiff(:,2:3) = abs(hsv1(:,2:3)-hsv2(:,2:3));
        h1 = squeeze(hsv1(:,1));
        h2 = squeeze(hsv2(:,1));
    end


else
    error('hsv1 and hsv2 must be the same size or one of them must be a single point')
end

h1 = h1 * 2 * pi;
h2 = h2 * 2 * pi;

hdiff = abs(wrapToPi(h1 - h2));
hdiff = hdiff / (2*pi);

if ndims(imDiff) == 3
    imDiff(:,:,1) = hdiff;
else
    imDiff(:,1) = hdiff;
end