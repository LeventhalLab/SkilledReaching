function imDiff = HSVdiff(hsv1, hsv2)

h1 = squeeze(hsv1(:,:,1));
% s1 = squeeze(hsv1(:,:,2));
% v1 = squeeze(hsv1(:,:,3));

h2 = squeeze(hsv2(:,:,1));
% s2 = squeeze(hsv2(:,:,2));
% v2 = squeeze(hsv2(:,:,3));

imDiff = zeros(size(hsv1,1),size(hsv1,2),3);
imDiff(:,:,2:3) = abs(hsv1(:,:,2:3)-hsv2(:,:,2:3));

h1 = h1 * 2 * pi;
h2 = h2 * 2 * pi;

hdiff = abs(wrapToPi(h1 - h2));
hdiff = hdiff / (2*pi);

imDiff(:,:,1) = hdiff;