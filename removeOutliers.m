function [data_centroids] = removeOutliers(data_centroids)
    x = squeeze(data_centroids(:,1,:));
    y = squeeze(data_centroids(:,2,:));

    x(isnan(x)) = 0;
    y(isnan(y)) = 0;

    xfilt = imopen(logical(x), strel('disk', 1, 0));
    yfilt = imopen(logical(y), strel('disk', 1, 0));

    x = x.*xfilt;
    y = y.*yfilt;

    data_centroids(:,1,:) = x;
    data_centroids(:,2,:) = y;
end