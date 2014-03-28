function [pelletCenter,pelletBbox] = pelletData(image,pelletCenter)
    pelletCenter = NaN(1,2);
    pelletBbox = NaN(1,4);
    
    % consider allowing 2-3 NaN entries come by as a buffer
    if(isnan(pelletCenter(1)))
       return 
    end
    
    hsv = rgb2hsv(image);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % bound the hue element using all three bounds
    h(s > .12) = 0;
    h(v < .70) = 0;

    % bound the pellet based on starting position
    boundsMask = zeros(size(h));
    boundsMask = insertShape(boundsMask,'FilledCircle',[pelletCenter 50],'Color','white');
    % doesn't need further masking, too small of an area
    mask = h&rgb2gray(boundsMask);
    
    % get blob properties
    props = regionprops(mask,'Area','Centroid','BoundingBox');
    if(~isempty(props))
        [maxArea,maxIndex] = max([props.Area]);
        % make sure this is a pellet by windowing area
        if(maxArea > 100 && maxArea < 1200)
            pelletCenter = props(maxIndex).Centroid;
            pelletBbox = props(maxIndex).BoundingBox;
        end
    end
end