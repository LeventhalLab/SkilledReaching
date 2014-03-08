image = imread('testavg.jpg');
hsv = rgb2hsv(image);

h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

h(h < .25 | h > .45) = 0;
h(s < .15) = 0;
h(v < .07) = 0;

%h = imopen(h, strel('disk', 1, 0));
h = imclose(h, strel('disk', 5, 0));
h = imfill(h, 'holes');
h = imdilate(h, strel('disk', 5, 0));

mask = logical(h);
%imshow(edge(mask, 'sobel'));
figure;
imshow(mask);