function [idx1,idx2] = nearestPointsInSets(x1,x2)

for ii = 1 : size(x1,1)
    
    x2_diff = bsxfun(@minus,x2,x1(ii,:));
    x2_dist = sum(x2_diff.^2,2);
    
    if ii == 1
        minDist = min(x2_dist);
        idx1 = ii;
        idx2 = find(x2_dist == min(x2_dist));
    elseif min(x2_dist) < minDist
        minDist = min(x2_dist);
        idx1 = ii;
        idx2 = find(x2_dist == min(x2_dist));
    end
end
    
    