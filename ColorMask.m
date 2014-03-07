image = imread('R0016_20140306_13-06-25_013_s_f217.jpg');
hsv = rgb2hsv(image);

h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

h(h < .25 | h > .45) = 0;
h(s < .15) = 0;
h(v < .07) = 0;

h = imopen(h, strel('disk', 3, 0));
%h = imclose(h, strel('disk', 2, 0));
h = imdilate(h, strel('disk', 1, 0));
h = imfill(h, 'holes');

mask = logical(h);
figure;
imshow(edge(mask, 'sobel'));