function [idx1,idx2] = farthestPointsInSets(x1,x2)

for ii = 1 : size(x1,1)
    
    x2_diff = bsxfun(@minus,x2,x1(ii,:));
    x2_dist = sum(x2_diff.^2,2);
    
    if ii == 1
        maxDist = max(x2_dist);
        idx1 = ii;
        idx2 = find(x2_dist == max(x2_dist));
    elseif max(x2_dist) < maxDist
        maxDist = max(x2_dist);
        idx1 = ii;
        idx2 = find(x2_dist == max(x2_dist));
    end
end