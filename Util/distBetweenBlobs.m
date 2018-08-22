function d = distBetweenBlobs(blob1, blob2)

ext_pts1 = bwmorph(blob1,'remove');
ext_pts2 = bwmorph(blob2,'remove');

[y1,x1] = find(ext_pts1);
[y2,x2] = find(ext_pts2);

all_d = zeros(length(y1),1);
for i_pt1 = 1 : length(y1)
    
    [all_d(i_pt1),~] = findNearestNeighbor([x1(i_pt1),y1(i_pt1)],[x2,y2]);
    
end
d = min(all_d);
