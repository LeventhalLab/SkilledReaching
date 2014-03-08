function [hBounds, sBounds, vBounds] = findHsvBounds(imageFile)
    image = imread(imageFile);
    hsv = rgb2hsv(image);
    
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    
    % get rid of pure white
    h = h(h > 0 & h < 1);
    s = s(s > .01 & s < .98);
    v = v(v > .01 & v < .98);
    
    hBounds = [mean(h) - std(h), mean(h) + std(h)];
    sBounds = [mean(s) - std(s), mean(s) + std(s)];
    vBounds = [mean(v) - std(v), mean(v) + std(v)];
end