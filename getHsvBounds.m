function [hsvBounds]=getHsvBounds(videoFile,step)
    video = VideoReader(videoFile);
    
    hBounds = zeros(size(1:step:video.NumberOfFrames,1),2);
    sBounds = hBounds;
    vBounds = hBounds;
    
    count = 1;
    for i=1:step:video.NumberOfFrames
        im = read(video,i);
        h_im = imshow(im);
        mask = createMask(imfreehand,h_im); %imrect
        mask = imfill(mask,'holes');
        close;

        hsv = rgb2hsv(im);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        % get rid of extremes
        s(s < .05 | s > .95) = 0;
        v(v < .05 | v > .95) = 0;
        h = h.*mask;
        s = s.*mask;
        v = v.*mask;

        % remove zeros and put into a single dimension array
        hRmZero = h(h>0);
        sRmZero = s(s>0);
        vRmZero = v(v>0);

        % create bounds +/- one standard deviation
        hBounds(count,:) = [mean(hRmZero)-std(hRmZero),mean(hRmZero)+std(hRmZero)];
        sBounds(count,:) = [mean(sRmZero)-std(sRmZero),mean(sRmZero)+std(sRmZero)];
        vBounds(count,:) = [mean(vRmZero)-std(vRmZero),mean(vRmZero)+std(vRmZero)];

        count = count+1;
    end
    
    hVals = hBounds(any(~isnan(hBounds),2),:);
    sVals = sBounds(any(~isnan(sBounds),2),:);
    vVals = vBounds(any(~isnan(vBounds),2),:);
    
    hsvBounds = [mean(hVals),mean(sVals),mean(vVals)];
    
%     im = bsxfun(@times,im,cast(mask,class(im)));
%     imshow(im);
end