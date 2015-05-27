%dellens@umich.edu

%display color histograms of ROI from RGB images
%NB: ROI coordinates are hard-coded, line 16
%imhist displays a histogram of a grayscale or binary images

function [imageX] = getColorHist(imageName);
imageX = imageName;

%show image 'fname' in new figure window, with rectangle overlay for ROI,
%imrect uses [xmin, ymin, width, height]
imName = inputname(1);
figtitle = strcat('Source Image:', imName);
figure('name', figtitle), imshow(imageX);
I = imrect(gca,[120 610 50 50]);

%show cropped image
position = getPosition(I)
croppedImageX = imcrop(imageX, position);
figure('name', figtitle); imshow(croppedImageX);

%split into RGB Channels
Red = croppedImageX(:,:,1);
Green = croppedImageX(:,:,2);
Blue = croppedImageX(:,:,3);

%Get histValues for each channel
[yRed, x] = imhist(Red);
[yGreen, x] = imhist(Green);
[yBlue, x] = imhist(Blue);

%Plot them together in one plot, new figure window
figtitle2 = strcat('RGB Hist:', imName);
figure('name', figtitle2), plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');

end
