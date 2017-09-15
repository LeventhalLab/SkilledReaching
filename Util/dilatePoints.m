function newPoints = dilatePoints(oldPoints, dilateFactor, imSize)
%
% function to take a set of x,y points, dilate by dilateFactor, and return
% the [x,y] coordinates of the points that are in the new mask

tempMask = false(imSize);

for i_pt = 1 : size(oldPoints,1)
    tempMask(oldPoints(i_pt,2),oldPoints(i_pt,1)) = true;
end
tempMask = imdilate(tempMask,strel('disk',dilateFactor));
[y,x] = find(tempMask);

newPoints = [x,y];
