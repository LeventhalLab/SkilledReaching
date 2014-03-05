input = VideoReader('R0016.avi');
image = read(input, 1);
figure;
imshow(image);
title('Rat');
boxPoints = detectSURFFeatures(image);
grayImage = rgb2gray(image);
imshow(grayImage)
imshow(grayImage);
hold on;
plot(boxPoints.selectStrongest(100));

imwrite(image, 'test.jpg');