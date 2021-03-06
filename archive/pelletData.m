function [pelletCenter,pelletBbox] = pelletData(image,pelletCenter,searchRadius)
  
    % consider allowing 2-3 NaN entries come by as a buffer
    if(isnan(pelletCenter(1)))
       return 
    end
    
    hsv = rgb2hsv(image);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % bound starting with the saturation channel
    s(s > .15) = 0;
    s(v < .7) = 0;

    % bound the pellet based on starting position
    boundsMask = zeros(size(s));
    boundsMask = insertShape(boundsMask,'FilledCircle',[pelletCenter searchRadius],'Color','white');
    % doesn't need further masking, too small of an area
    mask = s&rgb2gray(boundsMask);
    %imshow(mask);
    
    % get blob properties
    props = regionprops(mask,'Area','Centroid','BoundingBox');
    if(~isempty(props))
        [maxArea,maxIndex] = max([props.Area]);
        % make sure this is a pellet by windowing area
        if(maxArea > 150 && maxArea < 1200)
            pelletCenter = props(maxIndex).Centroid;
            pelletBbox = props(maxIndex).BoundingBox;
        else
            pelletCenter = NaN(1,2);
            pelletBbox = NaN(1,4);
        end
    else
        pelletCenter = NaN(1,2);
        pelletBbox = NaN(1,4);
    end
end