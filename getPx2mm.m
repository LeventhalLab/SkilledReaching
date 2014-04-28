function pxToMm=getPx2mm(knownDistMm)
    [videoName,videoPath] = uigetfile('*.avi');
    videoFile = fullfile(videoPath,videoName);
    video = VideoReader(videoFile);
    imshow(read(video,1));
    disp('Identify points, press ENTER when done...');
    [x,y] = ginput;
    close;
    
    pxToMm = knownDistMm / pdist([x,y]);
end