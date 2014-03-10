blueMask = colorBlob('R0000_20140308_11-49-12_008_MIDDLE.avi', [.577 .666 .22 .57 .24 .35]);
greenMask = colorBlob('R0000_20140308_11-49-12_008_MIDDLE.avi', [.208 .2638 .27 .44 .35 .51]);
yellowMask = colorBlob('R0000_20140308_11-49-12_008_MIDDLE.avi', [.122 .1666 .42 .65 .57 .9]);
redMask = colorBlob('R0000_20140308_11-49-12_008_MIDDLE.avi', [0 .0277 .5 .85 .6 1]);

%save('session1.mat');

% videoFromMasks(blueMask, 'R0000_20140308_11-49-12_008_MIDDLE.avi', .62, '1.avi');
% videoFromMasks(greenMask, '1.avi', .235, '2.avi');
% videoFromMasks(yellowMask, '2.avi', .152, '3.avi');
% videoFromMasks(redMask, '3.avi', .014, '4.avi');
% 
% blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
%         'AreaOutputPort', true, 'CentroidOutputPort', true, ...
%         'MinimumBlobArea', 50, 'MajorAxisLengthOutputPort', true,...
%         'MinorAxisLengthOutputPort', true, 'OrientationOutputPort', true);
%     
% [~, centroids, bboxes, majoraxis, minoraxis, orientation] = blobAnalyser.step(logical(b));
% newim = ellipseMatrix(centroids(1,1), centroids(1,2), majoraxis(1), minoraxis(1), orientation(1), image, .6);
% load('session1.mat');



blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 40, 'MajorAxisLengthOutputPort', true,...
    'MinorAxisLengthOutputPort', true, 'OrientationOutputPort', true);

video = VideoReader('R0000_20140308_11-49-12_008_MIDDLE.avi');
figure
for i=100:200
    disp(i)
    image = read(video, i);
    g = greenMask(:,:,i);
    [~, centroids, bboxes, majoraxis, minoraxis, orientation] = blobAnalyser.step(logical(g));
    imshow(image)
    line(bboxes(:,1), bboxes(:,2), 'LineWidth',3,'Color',[1 0 0]);
end