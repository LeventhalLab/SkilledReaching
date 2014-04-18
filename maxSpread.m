function [maxIndexes,maxDistB]=maxSpread(point,dataSet)
    [maxDistA,maxIndexA] = pdistMax(point(1,:),dataSet);
    [maxDistB,maxIndexB] = pdistMax(dataSet(maxIndexA,:),dataSet);
    maxIndexes = [maxIndexA maxIndexB];
end

function [maxDist,maxIndex]=pdistMax(point,dataSet)
    allDist = zeros(size(dataSet,1),1);
    for i=1:size(dataSet,1)
        allDist(i) = pdist([point;dataSet(i,:)]);
    end
    [maxDist,maxIndex] = max(allDist);
end