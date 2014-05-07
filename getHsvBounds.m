function h=getHsvBounds(h)
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);

    allh = [];
    alls = [];
    allv = [];
    steps = [100,250];
    for i=1:numel(steps)
        im = read(video,steps(i));
        figure;
        h_im = imshow(im);
        mask = createMask(imfreehand,h_im); %imrect
        mask = imfill(mask,'holes');
        close;

        if(~isempty(mask(mask>0)))
            hsv = rgb2hsv(im);
            hue = hsv(:,:,1);
            sat = hsv(:,:,2);
            val = hsv(:,:,3);

            % apply mask
            hue = hue.*mask;
            sat = sat.*mask;
            val = val.*mask;

            % remove zeros and put into a single dimension array
            hue = hue(hue>0);
            sat = sat(sat>0);
            val = val(val>0);
            allh = [hue(:)' allh];
            alls = [sat(:)' alls];
            allv = [val(:)' allv];
        end
    end
    
    xvalues = 0:.01:1;
    plotColor = [0 .6 .6];
    if(~exist('h','var'))
        h = figure('Position', [0,0,800,800]);
    end
    
    data = {allh,alls,allv};
    titles = {'Hue','Saturation','Value'};
    for i=1:3
        figure(h);
        subplot(3,1,i);
        hold on;
        set(gca,'xlim',[0 1]);
        hist(data{i},xvalues);
        title(titles{i});
        hsub = findobj(gca,'Type','patch');
        set(hsub,'FaceColor',plotColor,'EdgeColor','w');
    end
end