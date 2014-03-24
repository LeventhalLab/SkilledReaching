function [centers,hulls] = testColorBlob(videoFile,hsvBounds)
    video = VideoReader(videoFile);

    centers = NaN(video.NumberOfFrames,2);
    for i=1:video.NumberOfFrames
       hulls{i} = NaN(1,2);
    end
    
    for i=1:video.NumberOfFrames
        disp(['Masking... ' num2str(i)])
        image = read(video,i);
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
            centers(i,:) = [centerGravityRow centerGravityColumn];

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

            hulls{i} = props(maxIndex).ConvexHull;

%             imshow(image)
%             maxCentroid = props(maxIndex).Centroid;

        end
    end
    
    centers = cleanCentroids(centers);
    
    newVideo = VideoWriter('right/cropped_right_R0016_20140306_13-06-25_013_processed.avi', 'Motion JPEG AVI');
    newVideo.Quality = 90;
    newVideo.FrameRate = 30;
    open(newVideo);
    
    for i=1:video.NumberOfFrames
        disp(['Writing Video... ' num2str(i)])
        image = read(video,i);
        
        if(~isnan(centers(i,1)))
            image = insertShape(image,'FilledCircle',[centers(i,:) 8]);
        end

        if(~isnan(hulls{i}(1)))
            simpleHullIndexes = convhull(hulls{i},'simplify',true);
            for j=1:(size(simpleHullIndexes)-1)
                % lines to hull points
                if(~isnan(centers(i,1)))
                    image = insertShape(image,'Line',[centers(i,:)... 
                        hulls{i}(simpleHullIndexes(j),1) hulls{i}(simpleHullIndexes(j),2)]);
                end
                % hull points
                if(~isnan(hulls{i}(1)))
                    image = insertShape(image,'FilledCircle',...
                        [hulls{i}(simpleHullIndexes(j),1) hulls{i}(simpleHullIndexes(j),2) 3],'Color','red');
                end
            end
        end
        
        writeVideo(newVideo,image);

%         [northPole,southPole] = poles(hull);
%         if(abs(mean(northPole-southPole)) > 10)
%             image = insertShape(image,'Line',[centerGravityRow centerGravityColumn northPole;...
%                 centerGravityRow centerGravityColumn southPole]);
%             image = insertShape(image,'FilledCircle',[northPole 3]);
%             image = insertShape(image,'FilledCircle',[southPole 3]);
%         end
    end
    
    close(newVideo);
end