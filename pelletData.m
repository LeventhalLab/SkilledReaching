function [pelletCenter] = pelletData(image,pelletCenter)
    % consider allowing 2-3 NaN entries come by as a buffer
    if(isnan(pelletCenter(1)))
       return 
    end
    
    hsv = rgb2hsv(image);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % bound the hue element using all three bounds
    h(s > .15) = 0;
    h(v < .65) = 0;

    % bounds
    boundsMask = zeros(size(h));
    boundsMask = insertShape(boundsMask,'FilledCircle',[pelletCenter 35],'Color','white');
    h = h&rgb2gray(boundsMask);

    mask = bwdist(h) < 3;
    mask = imfill(mask, 'holes');
    mask = imerode(mask, strel('disk',1));
    bwmask = bwdist(~mask);
    [maxGravityValue,~] = max(bwmask(:));
    if(maxGravityValue > 4)
        [centerGravityColumns,centerGravityRows] = find(bwmask == maxGravityValue);
        centerGravityRow = mean(centerGravityRows);
        centerGravityColumn = mean(centerGravityColumns);
        pelletCenter = round([centerGravityRow centerGravityColumn]);
    else
        pelletCenter = NaN(1,2);
    end
end