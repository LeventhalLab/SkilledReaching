%dellens@umich.edu

%display color histograms of ROI from RGB images
%imhist displays a histogram of a grayscale or binary images
%will save cropped image if given input name

function [croppedImageX] = getColorHist(imageName, xmin, ymin, width, height);
imageX = imageName;

%show image 'fname' in new figure window, with rectangle overlay for ROI
%imrect uses [xmin, ymin, width, height]
imName = inputname(1);
figtitle = strcat('Source Image:', imName);
figure('name', figtitle), imshow(imageX);
I = imrect(gca,[xmin, ymin, width, height]);

%show cropped image
position = getPosition(I);
croppedImageX = imcrop(imageX, position);
figure('name', figtitle); imshow(croppedImageX);

%split into RGB Channels
Red = croppedImageX(:,:,1);
Green = croppedImageX(:,:,2);
Blue = croppedImageX(:,:,3);

%Get color values as histograms for each channel
[yRed, x] = imhist(Red);
[yGreen, x] = imhist(Green);
[yBlue, x] = imhist(Blue);

%Plot color values together in one histogram plot, in helnew figure window
figtitle2 = strcat('RGB Hist:', imName);
figure('name', figtitle2), plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');

end
