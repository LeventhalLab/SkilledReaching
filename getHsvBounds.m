function hsvBounds=getHsvBounds(pixelBounds,step)
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);
    hsvBounds = pixelBounds;
    
    fields = fieldnames(pixelBounds);
    allh = [];
    alls = [];
    allv = [];

    for j=1:size(fields,1)
        disp(['Mark paw for "',fields{j},'"...']);
        
        for i=1:step:video.NumberOfFrames
            im = read(video,i);
            coords = pixelBounds.(fields{j}); % x1 y1 x2 y2
            figure;
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
                allh = [h(:)' allh];
                alls = [s(:)' alls];
                allv = [v(:)' allv];
            end
        end
    end
    
    xvalues = 0:.01:1;
    h = figure('Position', [0,0,500,800]);
    subplot(3,1,1);
    hist(allh,xvalues);
    set(gca,'xlim',[0 1])
    title('Hue');
    
    subplot(3,1,2);
    hist(alls,xvalues);
    set(gca,'xlim',[0 1])
    title('Saturation');
    
    subplot(3,1,3);
    hist(allv,xvalues);
    set(gca,'xlim',[0 1])
    title('Value');
end