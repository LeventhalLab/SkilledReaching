function [pawCenters,pawHulls,pelletCenters] = skilledReaching(videoFile,hsvBounds,pelletCenter)
    video = VideoReader(videoFile);

    pawCenters = NaN(video.NumberOfFrames,2);
    pawHulls = cell(1,video.NumberOfFrames);
    pelletCenters = NaN(video.NumberOfFrames,2);
    
    for i=1:video.NumberOfFrames
        disp(['Masking... ' num2str(i)])
        image = read(video,i);
        [pawCenters(i,:),pawHulls{i}] = pawData(image,hsvBounds);
        [pelletCenter] = pelletData(image,pelletCenter);
        pelletCenters(i,:) = pelletCenter;
    end 
end

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
    h(s > .12) = 0;
    h(v < .7) = 0;

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
    if(maxGravityValue > 4)
        [centerGravityColumns,centerGravityRows] = find(bwmask == maxGravityValue);
        centerGravityRow = mean(centerGravityRows);
        centerGravityColumn = mean(centerGravityColumns);
        pelletCenter = round([centerGravityRow centerGravityColumn]);
    else
        pelletCenter = NaN(1,2);
    end
end

function [pawCenter,pawHull] = pawData(image,hsvBounds)
    hsv = rgb2hsv(image);

    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % bound the hue element using all three bounds
    h(h < hsvBounds(1) | h > hsvBounds(2)) = 0;
    h(s < hsvBounds(3) | s > hsvBounds(4)) = 0;
    h(v < hsvBounds(5) | v > hsvBounds(6)) = 0;

    mask = bwdist(h) < 3;
    mask = imfill(mask, 'holes');
    mask = imerode(mask, strel('disk',1));

    % find "center of gravity"
    bwmask = bwdist(~mask);
    [maxGravityValue,~] = max(bwmask(:));

    % make sure there is actually a reliable "center"
    if(maxGravityValue > 3)
        [centerGravityColumns,centerGravityRows] = find(bwmask == maxGravityValue);
        centerGravityRow = mean(centerGravityRows);
        centerGravityColumn = mean(centerGravityColumns);
        pawCenter = [centerGravityRow centerGravityColumn];

        % draw lines between blobs and centroid
        networkMask = zeros(size(image,1),size(image,2),3);
        CC = bwconncomp(mask);
        L = labelmatrix(CC);
        props = regionprops(L,'Centroid');
        regions = size(props,1);

        for j=1:regions
            % only draw lines to centroids near center of gravity
            % (eliminates noise)
            if(pdist([centerGravityRow centerGravityColumn;props(j).Centroid]) < 100)
                networkMask = insertShape(networkMask,'Line',[centerGravityRow centerGravityColumn...
                    props(j).Centroid],'Color','White');
            end
        end
        networkMask = im2bw(rgb2gray(networkMask));
        networkMask = imdilate(networkMask,strel('disk',2));

        % this convex hull needs to belong to the largest centroid
        CC = bwconncomp(networkMask|mask);
        L = labelmatrix(CC);
        props = regionprops(L,'Area','ConvexHull');
        [maxArea,maxIndex] = max([props.Area]);
        pawHull = props(maxIndex).ConvexHull;
%       maxCentroid = props(maxIndex).Centroid;
    else
        pawCenter = NaN(1,2);
        pawHull = NaN(1,2);
    end
end