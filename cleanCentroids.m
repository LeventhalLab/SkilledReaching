function [rawCentroids] = cleanCentroids(rawCentroids)
    [rows,~,~] = find(~isnan(rawCentroids));
    minIndex = min(rows);
    maxIndex = max(rows);
    cleanCentroids = rawCentroids(minIndex:maxIndex,:);
    
    % only perform median/avg filtering on decently sized data sets
    if(maxIndex - minIndex > 15)
        cleanCentroids = inpaint_nans(cleanCentroids);
        medianWindow = 7;
        averageWindow = 3;

        x = cleanCentroids(:,1);
        y = cleanCentroids(:,2);

        x = medfilt1(x, medianWindow);
        y = medfilt1(y, medianWindow);
        x = smooth(x, averageWindow);
        y = smooth(y, averageWindow);

        cleanCentroids(:,1) = x;
        cleanCentroids(:,2) = y;
    end
    rawCentroids(minIndex:maxIndex,:) = cleanCentroids;
end