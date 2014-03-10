function [centroids] = plotCentroids(centroids)
    centroids = inpaint_nans(centroids);
    medianWindow = 7;
    averageWindow = 3;
    
    x = centroids(:,1);
    y = centroids(:,2);
    
%     for i=1:15
%         [x ip] = func_despike_phasespace3d(x,0,2);
%         [y ip] = func_despike_phasespace3d(y,0,2);
%     end
%     
    x = medfilt1(x, medianWindow);
    y = medfilt1(y, medianWindow);
    x = smooth(x, averageWindow);
    y = smooth(y, averageWindow);
    
%     figure;
%     plot(x, max(y)-y, 'Color', 'green');
%     hold on;
%     plot(x(1), max(y)-y(1), '*');
    
    centroids(:,1) = x;
    centroids(:,2) = y;
end