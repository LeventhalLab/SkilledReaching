function pxToMm=rubiksPxToMm(boundNames)
    knownMm = 15; % each square is 15mm
    [imageName,imagePath] = uigetfile({'.PNG'});
    imageFile = fullfile(imagePath,imageName);
    im = imread(imageFile);
    imHsv = rgb2hsv(im);
    
    pxToMm = {};
    figure;
    for i=1:size(boundNames,2)
        disp(['Select Rubiks squares for "',boundNames{i},'", press ENTER when done...']);
        imshow(im);
        [xList,yList] = ginput;

        avgPxToMm = 0;
        for j=1:numel(xList)
            x = round(xList(j));
            y = round(yList(j));
            tolerance = .1;
            spanPixels = 30;
            avgHue = mean(reshape(imHsv((y-spanPixels):(y+spanPixels),(x-spanPixels):(x+spanPixels),1),1,[]));
            avgSaturation = mean(reshape(imHsv((y-spanPixels):(y+spanPixels),(x-spanPixels):(x+spanPixels),2),1,[]));
            avgValue = mean(reshape(imHsv((y-spanPixels):(y+spanPixels),(x-spanPixels):(x+spanPixels),3),1,[]));
            hsvBounds = [avgHue-tolerance,avgHue+tolerance,avgSaturation-tolerance,...
                avgSaturation+tolerance,avgValue-tolerance,avgValue+tolerance];

            h = imHsv(:,:,1);
            s = imHsv(:,:,2);
            v = imHsv(:,:,3);

            % bound the hue element using all three bounds
            h(h < hsvBounds(1) | h > hsvBounds(2)) = 0;
            h(s < hsvBounds(3) | s > hsvBounds(4)) = 0;
            h(v < hsvBounds(5) | v > hsvBounds(6)) = 0;

            mask = bwdist(h) < 5;
            imshow(mask);
            SE = strel('disk',5);
            mask = imopen(mask,SE);
            mask = imfill(mask,'holes');

            props = regionprops(mask,'Area','BoundingBox','PixelList');

            for k=1:size(props,1)
                memberInfo = ismember([x,y],props(k).PixelList);
                if(memberInfo(1)&&memberInfo(2) == 1)
                    im = insertShape(im,'FilledRectangle',props(k).BoundingBox);
                    if(avgPxToMm == 0)
                        avgPxToMm = knownMm/sqrt(props(k).Area);
                    else
                        avgPxToMm = mean([avgPxToMm,knownMm/sqrt(props(k).Area)]);
                    end
                end
            end
        end
        
        pxToMm.(boundNames{i}) = avgPxToMm;
        imshow(im);
    end
end