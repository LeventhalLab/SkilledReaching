image = imread('R0000_20140308_11-49-12_008_f250.jpg');
hsv = rgb2hsv(image);

h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

h(h < .4164 | h > .8207) = 0;
h(s < .0957 | s > .4350) = 0;
h(v < .2364 | v > .3732) = 0;

h = imopen(h, strel('disk', 1, 0));
%h = imclose(h, strel('disk', 5, 0));
h = imfill(h, 'holes');
h = imdilate(h, strel('disk', 3, 0));

mask = logical(h);
%imshow(edge(mask, 'sobel'));
figure;
imshow(mask);