image = imread('R0000_20140308_11-49-12_008_MIDDLE_f250.jpg');
hsv = rgb2hsv(image);

h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

h(h < .208 | h > .2638) = 0;
h(s < .175 | s > .5) = 0;
h(v < .1888 | v > .5) = 0;
%imshow(h)

%h = imopen(h, strel('disk', 1, 0));
h = imclose(h, strel('disk', 1, 0));
h = imfill(h, 'holes');
h = imdilate(h, strel('disk', 3, 0));
imshow(h)
mask = logical(h);
%imshow(edge(mask, 'sobel'));
%imshow(mask);