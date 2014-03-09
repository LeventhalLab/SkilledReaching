function plotCentroids(data_centroids)
    x = squeeze(data_centroids(:,1,:));
    y = squeeze(data_centroids(:,2,:));
    
    % remove NaN entries (for now)
    x(isnan(x)) = [];
    y(isnan(y)) = [];

    xfilt = imopen(logical(x), strel('disk', 1, 0));
    yfilt = imopen(logical(y), strel('disk', 1, 0));

    x = x.*xfilt;
    y = y.*yfilt;
    
    figure;
    plot(x, max(y)-y, 'Color', 'green');
    hold on;
    plot(x(1), max(y)-y(1), '*');
end