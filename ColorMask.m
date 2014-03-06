image = imread('R0000wb.jpg');
hsv = rgb2hsv(image);

h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

h(h < .25 | h > .35) = 0;
h(s < .07) = 0;
h(v < .07) = 0;

mask = logical(h);
figure;
imshow(mask);