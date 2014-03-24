function [out] = motionMask(videoFile,hsvBounds)
    video = VideoReader(videoFile);

    detector = vision.ForegroundDetector(...
       'NumTrainingFrames', 5, ... % 5 because of short video
       'InitialVariance', 30*30); % initial standard deviation of 30
    blob = vision.BlobAnalysis(...
       'CentroidOutputPort', false, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 200);
   
   shapeInserter = vision.ShapeInserter('BorderColor','White');
   
   for i=1:video.NumberOfFrames
        image = read(video,i);
       
        hsv = rgb2hsv(image);

        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        % bound the hue element using all three bounds
        h(h < hsvBounds(1) | h > hsvBounds(2)) = 0;
        h(s < hsvBounds(3) | s > hsvBounds(4)) = 0;
        h(v < hsvBounds(5) | v > hsvBounds(6)) = 0;
       
        rgb = hsv2rgb(h);
        
        fgMask = step(detector, image);
        bbox = step(blob, fgMask);
        out = step(shapeInserter, image, bbox);
        imshow(out);
   end