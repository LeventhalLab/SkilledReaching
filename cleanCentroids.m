% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% "Cleans" a centroid (x,y) array by interpolating between values and filling any NaN entries
function [rawCentroids] = cleanCentroids(rawCentroids)
    [rows,~,~] = find(~isnan(rawCentroids));
    minIndex = min(rows);
    maxIndex = max(rows);
    newCentroids = rawCentroids(minIndex:maxIndex,:);
    
    % only perform median/avg filtering on decently sized data sets
    if(maxIndex - minIndex > 15)
        newCentroids = inpaint_nans(newCentroids);
        medianWindow = 7;
        averageWindow = 3;

        x = newCentroids(:,1);
        y = newCentroids(:,2);

        x = medfilt1(x, medianWindow);
        y = medfilt1(y, medianWindow);
        x = smooth(x, averageWindow);
        y = smooth(y, averageWindow);

        newCentroids(:,1) = x;
        newCentroids(:,2) = y;
    end
    rawCentroids(minIndex:maxIndex,:) = newCentroids;
end