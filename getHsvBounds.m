function hsvBounds=getHsvBounds(pixelBounds,step)
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);
    hsvBounds = pixelBounds;
    
    fields = fieldnames(pixelBounds);
    for j=1:size(fields,1)
        disp(['Mark paw for "',fields{j},'"...']);
        
        hMin = 1;
        hMax = 0;
        sMin = 1;
        sMax = 0;
        vMin = 1;
        vMax = 0;
                    
        for i=1:step:video.NumberOfFrames
            im = read(video,i);
            coords = pixelBounds.(fields{j}); % x1 y1 x2 y2
            im = im(coords(2):coords(4),coords(1):coords(3),:);
            h_im = imshow(im);
            mask = createMask(imfreehand,h_im); %imrect
            mask = imfill(mask,'holes');
            close;
            
            
            if(~isempty(mask(mask>0)))
                hsv = rgb2hsv(im);
                h = hsv(:,:,1);
                s = hsv(:,:,2);
                v = hsv(:,:,3);

                % apply mask
                h = h.*mask;
                s = s.*mask;
                v = v.*mask;

                % remove zeros and put into a single dimension array
                h = h(h>0);
                s = s(s>0);
                v = v(v>0);
                
                % set values
                hMin = min(hMin,min(h));
                hMax = max(hMax,max(h));
                sMin = min(sMin,min(s));
                sMax = max(sMax,max(s));
                vMin = min(vMin,min(v));
                vMax = max(vMax,max(v));
            end
        end

        hsvBounds.(fields{j}) = [hMin hMax sMin sMax vMin vMax];
    end
end