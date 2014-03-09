function [hBounds, sBounds, vBounds] = findHsvBounds(imageFile)
    image = imread(imageFile);
    hsv = rgb2hsv(image);
    
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % get rid of extremes
    s(s < .05 | s > .95) = 0;
    v(v < .05 | v > .95) = 0;
    
    % make mask so bad entries are removed from all arrays
    mask = s & v;
    h = h.*mask;
    s = s.*mask;
    v = v.*mask;
 
    % remove zeros and put into a single dimension array
    hRmZero = h(h >0);
    sRmZero = s(s >0);
    vRmZero = v(v >0);

    hBounds = [mean(hRmZero) - std(hRmZero), mean(hRmZero) + std(hRmZero)];
    sBounds = [mean(sRmZero) - std(sRmZero), mean(sRmZero) + std(sRmZero)];
    vBounds = [mean(vRmZero) - std(vRmZero), mean(vRmZero) + std(vRmZero)];
end