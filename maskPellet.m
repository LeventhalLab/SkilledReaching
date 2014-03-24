function [pelletCenters] = maskPellet(videoFile, pelletCenter)
    video = VideoReader(videoFile);
    pelletCenters = NaN(video.NumberOfFrames,2);
    
    for i=1:video.NumberOfFrames
        image = read(video,i);
        hsv = rgb2hsv(image);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        % bound the hue element using all three bounds
        h(s > .12) = 0;
        h(v < .79) = 0;

        % bounds
        boundsRadius = 30;
        boundsMask = zeros(size(h));
        boundsMask((pelletCenter(2)-boundsRadius):(pelletCenter(2)+boundsRadius),...
            (pelletCenter(1)-boundsRadius):(pelletCenter(1)+boundsRadius)) = 1;
        h = h&boundsMask;

        mask = bwdist(h) < 3;
        mask = imfill(mask, 'holes');
        mask = imerode(mask, strel('disk',1));
        bwmask = bwdist(~mask);
        [maxGravityValue,~] = max(bwmask(:));
        if(maxGravityValue > 5)
            [centerGravityColumns,centerGravityRows] = find(bwmask == maxGravityValue);
            centerGravityRow = mean(centerGravityRows);
            centerGravityColumn = mean(centerGravityColumns);
            image = insertShape(image,'FilledCircle',...
                [centerGravityRow centerGravityColumn 5],'Color','blue');
            pelletCenter = round([centerGravityRow centerGravityColumn]);
            pelletCenters(i,:) = pelletCenter;
        end
        imshow(image)
    end
end