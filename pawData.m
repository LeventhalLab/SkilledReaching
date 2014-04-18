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
    SE = strel('disk',3);
    mask = imopen(mask,SE);
    mask = imfill(mask,'holes');
    %mask = imerode(mask,SE);

    % find "center of gravity"
    bwmask = bwdist(~mask);
    [maxGravityValue,~] = max(bwmask(:));

    % make sure there is actually a reliable "center"
    if(maxGravityValue > 5)
        % get center coordinates
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
            if(pdist([centerGravityRow centerGravityColumn;props(j).Centroid]) < 50)
                networkMask = insertShape(networkMask,'Line',[centerGravityRow centerGravityColumn...
                    props(j).Centroid],'Color','White');
            end
        end
        networkMask = im2bw(rgb2gray(networkMask));
        networkMask = imdilate(networkMask,strel('disk',2));

        % this convex hull needs to belong to the largest centroid
        % probably don't need CC,L, just pass in mask
        CC = bwconncomp(networkMask|mask);
        L = labelmatrix(CC);
        props = regionprops(L,'Area','ConvexHull');
        [maxArea,maxIndex] = max([props.Area]);
        pawHull = props(maxIndex).ConvexHull;
        pawHull = cleanHull(pawHull);
    else
        pawCenter = NaN(1,2);
        pawHull = NaN(1,2);
    end
end