[blueMask, blueCentroids] = colorBlob('R0016_front.avi', [.577 .666 .22 .57 .24 .35]);
save('blue.mat','blueMask','blueCentroids');

[greenMask, greenCentroids] = colorBlob('R0016_front.avi', [.208 .27 .25 .49 .35 .55]);
save('green.mat','greenMask','greenCentroids');

[yellowMask, yellowCentroids] = colorBlob('R0016_front.avi', [.122 .1666 .42 .65 .57 .9]);
save('yellow.mat','yellowMask', 'yellowCentroids');

[redMask redCentroids] = colorBlob('R0016_front.avi', [0 .0277 .5 .85 .6 1]);
save('red.mat','redMask', 'redCentroids');

% videoFromMasks({blueMask greenMask yellowMask redMask},'R0016_front.avi',...
%     [.61 .23 .14 .01], 'all_masks.avi');

%save('session1.mat');

% videoFromMasks(blueMask, 'R0016_front.avi', .62, '1.avi');
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

% 
% 
% blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
%     'AreaOutputPort', true, 'CentroidOutputPort', true, ...
%     'MinimumBlobArea', 40, 'MajorAxisLengthOutputPort', true,...
%     'MinorAxisLengthOutputPort', true, 'OrientationOutputPort', true);
% 
% video = VideoReader('R0016_front.avi');
% figure
% for i=100:200
%     disp(i)
%     image = read(video, i);
%     g = greenMask(:,:,i);
%     [~, centroids, bboxes, majoraxis, minoraxis, orientation] = blobAnalyser.step(logical(g));
%     imshow(image)
%     line(bboxes(:,1), bboxes(:,2), 'LineWidth',3,'Color',[1 0 0]);
% end