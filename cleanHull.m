function hull=cleanHull(hull)
    hull = unique(round(hull),'rows');
    hullIndexes = convhull(hull(:,1),hull(:,2),'simplify',true);
    hull = hull(hullIndexes,:);
end