%dellens@umich.edu

%beta
%display color histograms of RGB images
%imhist displays a histogram of a grayscale or binary images

function imageX = getColorHist(fname);
imageX = fname;

%show image 'fname' in new figure window
imName = inputname(1);
figtitle = strcat('Source Image:', imName);
figure('name', figtitle), imshow(fname);

%split into RGB Channels
Red = imageX(:,:,1);
Green = imageX(:,:,2);
Blue = imageX(:,:,3);

%Get histValues for each channel
[yRed, x] = imhist(Red);
[yGreen, x] = imhist(Green);
[yBlue, x] = imhist(Blue);

%Plot them together in one plot, new figure window
figtitle2 = strcat('RGB Hist:', imName);
figure('name', figtitle2), plot(x, yRed, 'Red', x, yGreen, 'Green', x, yBlue, 'Blue');

end
