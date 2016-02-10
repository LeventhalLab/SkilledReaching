function cdiff = circDiff(y1,y2,minVal,maxVal)

y1_scaled = (y1 / (maxVal-minVal)) * 2 * pi;
y1_scaled = wrapTo2Pi(y1_scaled);

y2_scaled = (y2 / (maxVal-minVal)) * 2 * pi;
y2_scaled = wrapTo2Pi(y2_scaled);

y_diff = abs(y1_scaled - y2_scaled);

cdiff = (wrapTo2Pi(y_diff) * (maxVal-minVal)) / (2*pi);