function hdiff = hueDiff(h1,h2)

h1 = h1 * 2 * pi;
h2 = h2 * 2 * pi;

hdiff = abs(wrapToPi(h1 - h2));
hdiff = hdiff / (2*pi);