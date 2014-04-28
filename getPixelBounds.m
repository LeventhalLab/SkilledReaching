% >> pixelBounds = getPixelBounds({'left','center','right'});
function pixelBounds=getPixelBounds(boundNames)
    disp('Select one of your videos...');
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);
    pixelBounds = {};
    im = read(video,1);
    figure;
    
    for i=1:size(boundNames,2)
       disp(['Create ROI for "',boundNames{i},'"...']);
       h_im = imshow(im);
       mask = createMask(imrect,h_im);
       poly = mask2poly(mask);
       pixelBounds.(boundNames{i}) = [poly(1,:),poly(size(poly,1),:)];
    end
    close;
end