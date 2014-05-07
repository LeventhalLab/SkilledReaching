function [pawCenter,pawHull] = pawData(im,hsvBounds)
    hsv = rgb2hsv(im);

    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    % bound the hue element using all three bounds
    h(h < hsvBounds(1) | h > hsvBounds(2)) = 0;
    h(s < hsvBounds(3) | s > hsvBounds(4)) = 0;
    h(v < hsvBounds(5) | v > hsvBounds(6)) = 0;
    
    pawCenter = NaN(1,2);
    pawHull = NaN(1,2);

    % if there is no pixel information, no need to mask
    if(sum(logical(h(:))) > 50)
        mask = bwdist(h) < 2;
        SE = strel('disk',2);
        mask = imopen(mask,SE);
        mask = imclose(mask,SE);
        mask = imfill(mask,'holes');

        %mask = imerode(mask,SE);

        % find "center of gravity"
        bwmask = bwdist(~mask);
        [maxGravityValue,~] = max(bwmask(:));

        % make sure there is actually a reliable "center"
        if(maxGravityValue > 5)
            % get center coordinates
            [centerGravityColumns,centerGravityRows] = find(bwmask == maxGravityValue);
            centerGravityRow = round(mean(centerGravityRows));
            centerGravityColumn = round(mean(centerGravityColumns));
            pawCenter = [centerGravityRow centerGravityColumn];

            % draw lines between blobs and centroid
            props = regionprops(mask,'Centroid');
            regions = size(props,1);
            networkMask = zeros(size(im,1),size(im,2),3);
            for j=1:regions
                % only draw lines to centroids near center of gravity
                % (eliminates noise)
                if(pdist([centerGravityRow centerGravityColumn;round(props(j).Centroid)]) < 50)
                    networkMask = insertShape(networkMask,'Line',[centerGravityRow centerGravityColumn...
                        round(props(j).Centroid)],'Color','White','LineWidth',2);
                end
            end
            networkMask = im2bw(rgb2gray(networkMask));
            % this is mainly so the inserted lines
            networkMask = imdilate(networkMask,strel('disk',2));

            % find convex hull which encapsulates the max gravity area
            props = regionprops(networkMask|mask,'ConvexHull','PixelList');
            for i=1:size(props,1)
                memberInfo = ismember(pawCenter,props(i).PixelList);
                if(memberInfo(1)&&memberInfo(2) == 1)
                    pawHull = cleanHull(props(i).ConvexHull);
                end
            end          
        end
    end
end