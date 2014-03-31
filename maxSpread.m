function [hullPoints,maxArea]=maxSpread(hull,centerPoint)
    

    maxArea = 0;
    for i=1:size(hull,1)
        firstPoint = hull(i,:);
        for j=1:size(hull)
            if(i==j)
                continue;
            end
            secondPoint = hull(j,:);
            allPoints = [centerPoint;firstPoint;secondPoint];
            triArea = polyarea(allPoints(:,1),allPoints(:,2));
            if(triArea>maxArea)
                maxArea=triArea;
                hullPoints = allPoints(2:3,:);
            end
        end
    end
end