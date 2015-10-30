function hsum = hueSum(hue1,hue2)

hue1_angle = hue1 * 2 * pi;
hue2_angle = hue2 * 2 * pi;

hsum_angle = hue1_angle + hue2_angle;

hsum = wrapTo2Pi(hsum_angle) / (2*pi);