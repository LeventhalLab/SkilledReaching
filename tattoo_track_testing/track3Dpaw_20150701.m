function centroids = track3Dpaw_20150625(video, ...
                                         BGimg, ...
                                         peakFrameNum, ...
                                         F, ...
                                         startPawMask, ...
                                         digitMirrorMask_dorsum, ...
                                         digitCenterMask, ...
                                         rat_metadata, ...
                                         register_ROI, ...
                                         boxMarkers, ...
                                         varargin)
%
%
%
% INPUTS:
%    video - video reader object containing the current video under
%       analysis
%    BGimg - 
%    peakFrameNum - frame in which the paw and digits were initially
%       identified
%    F - 
%    digitMirrorMask_dorsum - m x n x 5 matrix, where each m x n matrix contains a mask
%       for a part of the paw. 1st row - dorsum of paw, 2nd through 5th
%       rows are each digit from index finger to pinky. Obviously, this is
%       the mask for the dorsum of the paw in the "peakFrame"
%    digitCenterMask - m x n x 5 matrix, where each m x n matrix contains a mask
%       for a part of the paw. 1st row - dorsum of paw, 2nd through 5th
%       rows are each digit from index finger to pinky. Obviously, this is
%       the mask for the direct view in the "peakFrame"
%   rat_metadata - needed to know whether to look to the left or right of
%       the dorsal aspect of the paw to exclude points that can't be digits
%   register_ROI - 
%   boxMarkers - 
%
% VARARGS:
%    bgimg - background image 
%
% OUTPUTS:
%

decorrStretchMean_center  = [127.5 100.0 100.0     % to isolate dorsum of paw
                             127.5 100.0 127.5     % to isolate blue digits
                             127.5 100.0 127.5     % to isolate red digits
                             127.5 100.0 127.5     % to isolate green digits
                             127.5 100.0 127.5];   % to isolate red digits
decorrStretchSigma_center = [075 075 075       % to isolate dorsum of paw
                             075 075 075       % to isolate blue digits
                             075 075 075       % to isolate red digits
                             075 075 075       % to isolate green digits
                             075 075 075];     % to isolate red digits

decorrStretchMean_mirror  = [150.0 100.0 150.0     % to isolate dorsum of paw
                             100.0 127.5 100.0     % to isolate blue digits
                             150.0 100.0 150.0     % to isolate red digits
                             127.5 100.0 127.5     % to isolate green digits
                             150.0 100.0 150.0];   % to isolate red digits

decorrStretchSigma_mirror = [050 025 025       % to isolate dorsum of paw
                      050 050 050       % to isolate blue digits
                      050 025 025       % to isolate red digits
                      050 050 050       % to isolate green digits
                      050 025 025];     % to isolate red digits
                  
centerPawBlob = vision.BlobAnalysis;
centerPawBlob.AreaOutputPort = true;
centerPawBlob.CentroidOutputPort = true;
centerPawBlob.BoundingBoxOutputPort = true;
centerPawBlob.ExtentOutputPort = true;
centerPawBlob.LabelMatrixOutputPort = true;
centerPawBlob.MinimumBlobArea = 0;
centerPawBlob.MaximumBlobArea = 30000;

mirrorPawBlob = vision.BlobAnalysis;
mirrorPawBlob.AreaOutputPort = true;
mirrorPawBlob.CentroidOutputPort = true;
mirrorPawBlob.BoundingBoxOutputPort = true;
mirrorPawBlob.ExtentOutputPort = true;
mirrorPawBlob.LabelMatrixOutputPort = true;
mirrorPawBlob.MinimumBlobArea = 0000;
mirrorPawBlob.MaximumBlobArea = 10000;

minErodedBlobSize = 225;

startTimeFromPeak = 0.2;    % in seconds
diff_threshold = 45;
maxDistPerFrame = 25;
% RGBradius = 0.1;
% color_zlim = 3;
hue_stdev_thresh = 3;
sat_stdev_thresh = 3;
val_stdev_thresh = 3;

pthresh = 0.9;

hBinEdges = linspace(0,1,17);
sBinEdges = linspace(0,1,17);
binEdges{1} = hBinEdges;
binEdges{2} = sBinEdges;
minSatForTracking = 0.0;

h = video.Height;
w = video.Width;

for iarg = 1 : 2 : nargin - 10
    switch lower(varargin{iarg})
        case 'numbgframes',
            numBGframes = varargin{iarg + 1};
        case 'trigger_roi',
            ROI_to_find_trigger_frame = varargin{iarg + 1};
        case 'graypawlimits',
            gray_paw_limits = varargin{iarg + 1};
        case 'bgimg',
            BGimg = varargin{iarg + 1};
        case 'starttimebeforepeak',
            startTimeFromPeak = varargin{iarg + 1};
        case 'diffthreshold',
            diff_threshold = varargin{iarg + 1};
        case 'decorrstretchmean_mirror',
            decorrStretchMean_mirror = varargin{iarg + 1};
        case 'decorrstretchsigma_mirror',
            decorrStretchSigma_mirror = varargin{iarg + 1};
        case 'decorrstretchmean_center',
            decorrStretchMean_center = varargin{iarg + 1};
        case 'decorrstretchsigma_center',
            decorrStretchSigma_center = varargin{iarg + 1};
    end
end

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
peakTime = ((peakFrameNum-1) / video.FrameRate);    % need to subtract one because readFrame reads the NEXT frame, not the current frame
video.CurrentTime = peakTime;
image = readFrame(video);

hsv_image = rgb2hsv(image);

paw_img = cell(1,3);
for ii = 1 : 3
    paw_img{ii} = image(register_ROI(ii,2):register_ROI(ii,2) + register_ROI(ii,4),...
                        register_ROI(ii,1):register_ROI(ii,1) + register_ROI(ii,3),:);
	if ii ~= 2
        paw_img{ii} = fliplr(paw_img{ii});
    end
end

% create a mask for the box front in the left and right mirrors
boxFrontMask = poly2mask(boxMarkers.frontPanel_x(1,:), ...
                         boxMarkers.frontPanel_y(1,:), ...
                         h, w);
boxFrontMask = boxFrontMask | poly2mask(boxMarkers.frontPanel_x(2,:), ...
                                        boxMarkers.frontPanel_y(2,:), ...
                                        h, w);
                        
if strcmpi(rat_metadata.pawPref, 'right')
    pawDorsumMirrorImg = paw_img{1};
else
    pawDorsumMirrorImg = paw_img{3};
end
% initialize one track each for the dorsum of the paw and each digit in the
% mirror and center views

tracks = initializeTracks();
numTracks = 0;
prev_paw_mask_mirror = false(size(BGimg, 1), size(BGimg, 2));
prev_paw_mask_center = false(size(BGimg, 1), size(BGimg, 2));
s = struct('Centroid', {}, ...
           'BoundingBox', {});
num_elements_to_track = size(digitMirrorMask_dorsum, 3);
imgDigitMirrorMask = false(size(BGimg,1),size(BGimg,2),num_elements_to_track);
imgDigitCenterMask = false(size(BGimg,1),size(BGimg,2),num_elements_to_track);
for ii = 1 : num_elements_to_track
    
    temp = fliplr(squeeze(digitMirrorMask_dorsum(:,:,ii)));
    
    if strcmpi(rat_metadata.pawPref,'right')
        imgDigitMirrorMask(register_ROI(1,2):register_ROI(1,2)+register_ROI(1,4), ...
                           register_ROI(1,1):register_ROI(1,1)+register_ROI(1,3),ii) = temp;
    else
        imgDigitMirrorMask(register_ROI(3,2):register_ROI(3,2)+register_ROI(3,4), ...
                           register_ROI(3,1):register_ROI(3,3)+register_ROI(3,3),ii) = temp;
    end

    temp = squeeze(digitCenterMask(:,:,ii));
    imgDigitCenterMask(register_ROI(2,2):register_ROI(2,2)+register_ROI(2,4), ...
                       register_ROI(2,1):register_ROI(2,1)+register_ROI(2,3),ii) = temp;
                   
    s(ii) = regionprops(imgDigitMirrorMask(:,:,ii),'Centroid','BoundingBox');
    s(ii + num_elements_to_track) = regionprops(imgDigitCenterMask(:,:,ii),'Centroid','BoundingBox');
    
    prev_paw_mask_mirror = prev_paw_mask_mirror | imgDigitMirrorMask(:,:,ii);
    prev_paw_mask_center = prev_paw_mask_center | imgDigitCenterMask(:,:,ii);
end
prev_paw_mask_mirror = imdilate(prev_paw_mask_mirror, strel('disk', maxDistPerFrame));
prev_paw_mask_mirror = imfill(prev_paw_mask_mirror,'holes');
masked_mirror_img = uint8(repmat(prev_paw_mask_mirror,1,1,3));
masked_mirror_img = masked_mirror_img  .* image;

prev_paw_mask_center = imdilate(prev_paw_mask_center, strel('disk', maxDistPerFrame));
prev_paw_mask_center = imfill(prev_paw_mask_center,'holes');
masked_center_img = uint8(repmat(prev_paw_mask_center,1,1,3));
masked_center_img = masked_center_img  .* image;

meanRGBenh = zeros(1,3);stdRGBenh = zeros(1,3);
for ii = 1 : num_elements_to_track
    
%     masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...
%                                               decorrStretchMean_mirror(ii,:), ...
%                                               decorrStretchSigma_mirror(ii,:), ...
%                                               'mask',prev_paw_mask_mirror);
    masked_mirror_img_enh = enhanceColorImage(image, ...
                                              decorrStretchMean_mirror(ii,:), ...
                                              decorrStretchSigma_mirror(ii,:), ...
                                              'mask',prev_paw_mask_mirror);
	masked_mirror_hsv = rgb2hsv(masked_mirror_img_enh);
                                          
%     masked_center_img_enh = enhanceColorImage(masked_center_img, ...
%                                               decorrStretchMean_center(ii,:), ...
%                                               decorrStretchSigma_center(ii,:), ...
%                                               'mask',prev_paw_mask_center);
    masked_center_img_enh = enhanceColorImage(image, ...
                                              decorrStretchMean_center(ii,:), ...
                                              decorrStretchSigma_center(ii,:), ...
                                              'mask',prev_paw_mask_center);
	masked_center_hsv = rgb2hsv(masked_center_img_enh);

	kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
        s(ii).Centroid, [200, 50], [100, 25], 100);
    CAMshiftTracker = vision.HistogramBasedTracker;
    initializeObject(CAMshiftTracker, masked_mirror_hsv(:,:,1), round(s(ii).BoundingBox));
    
    tempMask = squeeze(imgDigitMirrorMask(:,:,ii));
    tempMask = tempMask & (masked_mirror_hsv(:,:,2) > minSatForTracking);
%     tempMask = imerode(tempMask,strel('disk',2));
    hue = squeeze(masked_mirror_hsv(:,:,1));
    masked_hue = hue(tempMask(:));
    sat = squeeze(masked_mirror_hsv(:,:,2));
    masked_sat = sat(tempMask(:));
    v = squeeze(masked_mirror_hsv(:,:,3));
    masked_v = v(tempMask(:));
    
    % calculate mean hue - this must be a circular mean
    mean_hsv = zeros(1,3);std_hsv = zeros(1,3);
    mean_hsv(1) = wrapTo2Pi(circ_mean(masked_hue*2*pi)) / (2*pi);
    std_hsv(1)  = wrapTo2Pi(circ_std(masked_hue*2*pi)) / (2*pi);
    mean_hsv(2) = mean(masked_sat);
    std_hsv(2)  = std(masked_sat);
    mean_hsv(3) = mean(masked_v);
    std_hsv(3)  = std(masked_v);
    
    newTrack = struct(...
        'id', ii, ...
        'bbox', s(ii).BoundingBox, ...
        'kalmanFilter', kalmanFilter, ...
        'CAMshiftTracker', CAMshiftTracker, ...
        'mean_hsv', mean_hsv, ...
        'std_hsv', std_hsv, ...
        'currentMask', squeeze(imgDigitMirrorMask(:,:,ii)), ...
        'age', 1, ...
        'totalVisibleCount', 1, ...
        'consecutiveInvisibleCount', 0);
    numTracks = numTracks + 1;
    tracks(ii) = newTrack;
    
	kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
        s(ii+num_elements_to_track).Centroid, [200, 50], [100, 25], 100);
    CAMshiftTracker = vision.HistogramBasedTracker;
    initializeObject(CAMshiftTracker, masked_center_hsv(:,:,1), round(s(ii+num_elements_to_track).BoundingBox));
    
    tempMask = squeeze(imgDigitCenterMask(:,:,ii));
    tempMask = tempMask & (masked_mirror_hsv(:,:,2) > minSatForTracking);
%     tempMask = imerode(tempMask,strel('disk',2));
    hue = squeeze(masked_center_hsv(:,:,1));
    masked_hue = hue(tempMask(:));
    sat = squeeze(masked_center_hsv(:,:,2));
    masked_sat = sat(tempMask(:));
    X = [masked_hue,masked_sat];
    sh_hist = hist3(X, 'Edges', binEdges);
    sh_hist = sh_hist ./ max(max(sh_hist));

    newTrack = struct(...
        'id', ii+num_elements_to_track, ...
        'bbox', s(ii+num_elements_to_track).BoundingBox, ...
        'kalmanFilter', kalmanFilter, ...
        'CAMshiftTracker', CAMshiftTracker, ...
        'mean_hsv', mean_hsv, ...
        'std_hsv', std_hsv, ...
        'currentMask', squeeze(imgDigitCenterMask(:,:,ii)), ...
        'age', 1, ...
        'totalVisibleCount', 1, ...
        'consecutiveInvisibleCount', 0);
    
    numTracks = numTracks + 1;
    tracks(ii+num_elements_to_track) = newTrack;
end
% create tracks for the full paw
% masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...
%                                           decorrStretchMean_mirror(1,:), ...
%                                           decorrStretchSigma_mirror(1,:), ...
%                                           'mask',prev_paw_mask_mirror);
masked_mirror_img_enh = enhanceColorImage(image, ...
                                          decorrStretchMean_mirror(1,:), ...
                                          decorrStretchSigma_mirror(1,:), ...
                                          'mask',prev_paw_mask_mirror);
masked_mirror_hsv = rgb2hsv(masked_mirror_img_enh);
s_mirror = regionprops(prev_paw_mask_mirror,'Centroid','BoundingBox');

% masked_center_img_enh = enhanceColorImage(masked_center_img, ...
%                                           decorrStretchMean_center(1,:), ...
%                                           decorrStretchSigma_center(1,:), ...
%                                           'mask',prev_paw_mask_center);
masked_center_img_enh = enhanceColorImage(image, ...
                                          decorrStretchMean_center(1,:), ...
                                          decorrStretchSigma_center(1,:), ...
                                          'mask',prev_paw_mask_center);
masked_center_hsv = rgb2hsv(masked_center_img_enh);
s_center = regionprops(prev_paw_mask_center,'Centroid','BoundingBox');

kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
    s_mirror.Centroid, [200, 50], [100, 25], 100);
CAMshiftTracker = vision.HistogramBasedTracker;
initializeObject(CAMshiftTracker, masked_mirror_hsv(:,:,1), round(s_mirror.BoundingBox));

newTrack = struct(...
    'id', ii, ...
    'bbox', s(ii).BoundingBox, ...
    'kalmanFilter', kalmanFilter, ...
    'CAMshiftTracker', CAMshiftTracker, ...
    'mean_hsv', mean_hsv, ...
    'std_hsv', std_hsv, ...
    'currentMask', prev_paw_mask_mirror, ...
    'age', 1, ...
    'totalVisibleCount', 1, ...
    'consecutiveInvisibleCount', 0);
numTracks = numTracks + 1;
tracks(numTracks) = newTrack;

kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
    s_center.Centroid, [200, 50], [100, 25], 100);
CAMshiftTracker = vision.HistogramBasedTracker;
initializeObject(CAMshiftTracker, masked_center_hsv(:,:,1), round(s_center.BoundingBox));

newTrack = struct(...
    'id', ii, ...
    'bbox', s(ii).BoundingBox, ...
    'kalmanFilter', kalmanFilter, ...
    'CAMshiftTracker', CAMshiftTracker, ...
    'mean_hsv', mean_hsv, ...
    'std_hsv', std_hsv, ...
    'currentMask', prev_paw_mask_center, ...
    'age', 1, ...
    'totalVisibleCount', 1, ...
    'consecutiveInvisibleCount', 0);
numTracks = numTracks + 1;
tracks(numTracks) = newTrack;
    
numImages = 0;
while video.CurrentTime < video.Duration
    numImages = numImages + 1
    mirror_visible = false(1,num_elements_to_track);
    center_visible = false(1,num_elements_to_track);
    
    image  = readFrame(video);
    imdiff = imabsdiff(image, BGimg);
    thresh_mask = rgb2gray(imdiff) > diff_threshold;
    
    SE = strel('disk',2);
    thresh_mask = bwdist(thresh_mask) < 2;
    thresh_mask = imopen(thresh_mask, SE);
    thresh_mask = imclose(thresh_mask,SE);
    thresh_mask = imfill(thresh_mask,'holes');
    thresh_mask = imdilate(thresh_mask,strel('disk',4));
    
    % could use the Kalman filter here to predict where the digit centroid
    % shoud be next to narrow down where to move the mask from the previous
    % detection
    curr_paw_mask_mirror = imdilate(tracks(11).currentMask, strel('disk', maxDistPerFrame)) & thresh_mask;
    curr_paw_mask_mirror = bwdist(curr_paw_mask_mirror) < 2;
    curr_paw_mask_mirror = imopen(curr_paw_mask_mirror, SE);
    curr_paw_mask_mirror = imclose(curr_paw_mask_mirror, SE);
    curr_paw_mask_mirror = imfill(curr_paw_mask_mirror, 'holes');
    curr_paw_mask_mirror = imdilate(curr_paw_mask_mirror, strel('disk',6));
    
    % within that mask, look for regions that match with the previous digit
    % colors
    currentDigitMirrorMask = false(h,w,num_elements_to_track);
    curr_mirror_img_enh_hsv = zeros(size(image,1),size(image,2),3,num_elements_to_track);
    for ii = 2 : num_elements_to_track    % do the digits first
        curr_mirror_img_enh = enhanceColorImage(image, ...
                                                decorrStretchMean_mirror(ii,:), ...
                                                decorrStretchSigma_mirror(ii,:), ...
                                                'mask', curr_paw_mask_mirror);
                                            
        curr_mirror_img_enh_hsv(:,:,:,ii) = rgb2hsv(curr_mirror_img_enh);
        
        prev_digit_mask = imdilate(tracks(ii).currentMask, strel('disk',maxDistPerFrame)) & thresh_mask;
        prev_digit_mask = bwdist(prev_digit_mask) < 2;
        prev_digit_mask = imopen(prev_digit_mask, SE);
        prev_digit_mask = imclose(prev_digit_mask, SE);
        prev_digit_mask = imfill(prev_digit_mask, 'holes');
        
        % find points near the previous hsv means
        h_thresh = [tracks(ii).mean_hsv(1), tracks(ii).std_hsv(1) * hue_stdev_thresh];
        s_thresh = tracks(ii).mean_hsv(2) + sat_stdev_thresh * tracks(ii).std_hsv(2) * [-1,1];
        v_thresh = tracks(ii).mean_hsv(3) + val_stdev_thresh * tracks(ii).std_hsv(3) * [-1,1];
        hsvThresholds = [h_thresh, s_thresh, v_thresh];
        
        masked_mirror_hsv = squeeze(curr_mirror_img_enh_hsv(:,:,:,ii)) .* double(repmat(prev_digit_mask,1,1,3));
        [mirror_bbox,~,sc] = step(tracks(ii).CAMshiftTracker, masked_mirror_hsv(:,:,1));
        hsv_mask = HSVthreshold(masked_mirror_hsv, hsvThresholds);
        
        mirror_visible(ii) = true;    % need to add a check here in case the digit isn't visible in the mirror
        
        % only take blobs that overlap with the bounding box predicted by
        % the CAMshiftTracker object
        bbox_mask = false(size(image,1),size(image,2));
        bbox_mask(mirror_bbox(2):mirror_bbox(2) + mirror_bbox(4), ...
                  mirror_bbox(1):mirror_bbox(1) + mirror_bbox(3)) = true;
              
        [~,~,~,~,labelMask] = step(mirrorPawBlob, hsv_mask);
        bbox_overlap = labelMask .* uint8(bbox_mask);
        validIdx = unique(bbox_overlap(:));
        validIdx = validIdx(validIdx > 0);
        tempDigitMask = false(size(image,1),size(image,2));
        for jj = 1 : length(validIdx)
            tempDigitMask = tempDigitMask | (labelMask == validIdx(jj));
        end
        tempDigitMask = (bbox_overlap > 0);
        
        if length(validIdx) > 1
            tempDigitMask = connectBlobs(tempDigitMask);
        end
        SE = strel('disk',2);
        tempDigitMask = bwdist(tempDigitMask) < 2;
        tempDigitMask = imopen(tempDigitMask, SE);
        tempDigitMask = imclose(tempDigitMask, SE);
        tempDigitMask = imfill(tempDigitMask, 'holes');
        
        currentDigitMirrorMask(:,:,ii) = tempDigitMask;%imerode(tempDigitMask, SE);                
    end
    
    % now find the dorsum of the paw
    curr_mirror_img_enh = enhanceColorImage(image, ...
                                        decorrStretchMean_mirror(1,:), ...
                                        decorrStretchSigma_mirror(1,:), ...
                                        'mask', curr_paw_mask_mirror);
                                            
    curr_mirror_img_enh_hsv(:,:,:,1) = rgb2hsv(curr_mirror_img_enh);
    prev_digit_mask = imdilate(tracks(1).currentMask, strel('disk',maxDistPerFrame)) & thresh_mask;
    prev_digit_mask = bwdist(prev_digit_mask) < 2;
    prev_digit_mask = imopen(prev_digit_mask, SE);
    prev_digit_mask = imclose(prev_digit_mask, SE);
    prev_digit_mask = imfill(prev_digit_mask, 'holes');
    
    % find points near the previous hsv means
    h_thresh = [tracks(1).mean_hsv(1), tracks(1).std_hsv(1) * hue_stdev_thresh];
    s_thresh = tracks(1).mean_hsv(2) + sat_stdev_thresh * tracks(1).std_hsv(2) * [-1,1];
    v_thresh = tracks(1).mean_hsv(3) + val_stdev_thresh * tracks(1).std_hsv(3) * [-1,1];
    hsvThresholds = [h_thresh, s_thresh, v_thresh];
    
    masked_mirror_hsv = squeeze(curr_mirror_img_enh_hsv(:,:,:,1)) .* double(repmat(prev_digit_mask,1,1,3));
    [mirror_bbox,~,sc] = step(tracks(1).CAMshiftTracker, masked_mirror_hsv(:,:,1));
    hsv_mask = HSVthreshold(masked_mirror_hsv, hsvThresholds);
   
    mirror_visible(1) = true;    % need to add a check here in case the digit isn't visible in the mirror
    
    % only take blobs that overlap with the bounding box predicted by
    % the CAMshiftTracker object
    bbox_mask = false(size(image,1),size(image,2));
    bbox_mask(mirror_bbox(2):mirror_bbox(2) + mirror_bbox(4), ...
              mirror_bbox(1):mirror_bbox(1) + mirror_bbox(3)) = true;
          
    [~,~,~,~,labelMask] = step(mirrorPawBlob, hsv_mask);
    bbox_overlap = labelMask .* uint8(bbox_mask);
    validIdx = unique(bbox_overlap(:));
    validIdx = validIdx(validIdx > 0);
    tempDigitMask = false(size(image,1),size(image,2));
    for jj = 1 : length(validIdx)
        tempDigitMask = tempDigitMask | (labelMask == validIdx(jj));
    end
    
    tempDigitMask = (bbox_overlap > 0);

    if length(validIdx) > 1
        tempDigitMask = connectBlobs(tempDigitMask);
    end
    SE = strel('disk',2);
    tempDigitMask = bwdist(tempDigitMask) < 2;
    tempDigitMask = imopen(tempDigitMask, SE);
    tempDigitMask = imclose(tempDigitMask, SE);
    tempDigitMask = imfill(tempDigitMask, 'holes');

    currentDigitMirrorMask(:,:,1) = tempDigitMask;%imerode(tempDigitMask, SE); 

    masked_mirror_img = uint8(repmat(curr_paw_mask_mirror,1,1,3));
    masked_mirror_img = masked_mirror_img  .* image;
%     masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...
%                                               decorrStretchMean_mirror(2,:), ...
%                                               decorrStretchSigma_mirror(2,:), ...
%                                               'mask',curr_paw_mask_mirror);
    masked_mirror_img_enh = enhanceColorImage(image, ...
                                              decorrStretchMean_mirror(2,:), ...
                                              decorrStretchSigma_mirror(2,:), ...
                                              'mask',curr_paw_mask_mirror);

	% check to make sure masks don't overlap, which will kill the
	% segmentation based on geodesic distance
%     testMask = false(size(image,1),size(image,2));
    for ii = 1 : num_elements_to_track - 1
        for jj = ii + 1 : num_elements_to_track
            testMask = currentDigitMirrorMask(:,:,ii) & currentDigitMirrorMask(:,:,jj);
            currentDigitMirrorMask(:,:,ii) = currentDigitMirrorMask(:,:,ii) & ~testMask;
            currentDigitMirrorMask(:,:,jj) = currentDigitMirrorMask(:,:,jj) & ~testMask;
        end
        currentDigitMirrorMask(:,:,ii) = imerode(currentDigitMirrorMask(:,:,ii), SE);
    end
    currentDigitMirrorMask(:,:,num_elements_to_track) = imerode(currentDigitMirrorMask(:,:,num_elements_to_track), SE);
    
    [~,mirror_P] = imseggeodesic(masked_mirror_img_enh, currentDigitMirrorMask(:,:,2), currentDigitMirrorMask(:,:,3), currentDigitMirrorMask(:,:,4));
    [~,mirror_P2] = imseggeodesic(masked_mirror_img_enh, currentDigitMirrorMask(:,:,1), currentDigitMirrorMask(:,:,4), currentDigitMirrorMask(:,:,5));
    
    % WORKING HERE - NEED TO SEE IF NOT MASKING OUT ALL "NON-PAW" AREAS IN
    % THE BOUNDING REGION INFLUENCES CAMSHIFTTRACKER PERFORMANCE
    currentDigitMirrorMask(:,:,1) = (mirror_P2(:,:,1) > 0.9);
    currentDigitMirrorMask(:,:,2) = (mirror_P(:,:,1) > 0.9);
    currentDigitMirrorMask(:,:,3) = (mirror_P(:,:,2) > 0.9);
    currentDigitMirrorMask(:,:,4) = (mirror_P2(:,:,2) > 0.9);
    currentDigitMirrorMask(:,:,5) = (mirror_P2(:,:,3) > 0.9);
    
    % update the tracks
    mirror_fullPawMask = false(size(image,1),size(image,2));
    center_fullPawMask = false(size(image,1),size(image,2));
    for ii = 1 : num_elements_to_track
        tracks(ii).age = tracks(ii).age + 1;
        if mirror_visible(ii)
            % take only the largest region for each digit
            [A,~,~,~,labelMask] = step(mirrorPawBlob, currentDigitMirrorMask(:,:,ii));
            validIdx = find(A == max(A));
            tracks(ii).currentMask = (labelMask == validIdx);
            mirror_fullPawMask = mirror_fullPawMask | tracks(ii).currentMask;
            
            s = regionprops(tracks(ii).currentMask,'Centroid','BoundingBox');
            tracks(ii).bbox = s.BoundingBox;
            
            % update the CAMshiftTracker
            masked_mirror_hsv = squeeze(curr_mirror_img_enh_hsv(:,:,:,ii));
            initializeObject(tracks(ii).CAMshiftTracker, masked_mirror_hsv(:,:,1), round(s.BoundingBox));
            
            % update the Kalman filter
            predict(tracks(ii).kalmanFilter);
            correct(tracks(ii).kalmanFilter, s.Centroid);
            
            % update mean and standard deviation of hsv values
            tempMask = squeeze(tracks(ii).currentMask);
            tempMask = tempMask & (squeeze(curr_mirror_img_enh_hsv(:,:,2,ii)) > minSatForTracking);
            
            % erode the mask so that only the really representative color
            % at the middle of the blob remains (I hope) - DL 20150707
            tempMask = erodeToMinimumSize(tempMask, minErodedBlobSize);
            tempMask = connectBlobs(tempMask);
            
            hue = squeeze(curr_mirror_img_enh_hsv(:,:,1,ii));
            masked_hue = hue(tempMask(:));
            sat = squeeze(curr_mirror_img_enh_hsv(:,:,2,ii));
            masked_sat = sat(tempMask(:));
            v = squeeze(curr_mirror_img_enh_hsv(:,:,3,ii));
            masked_v = v(tempMask(:));
            
            % calculate mean hue - this must be a circular mean
            mean_hsv = zeros(1,3);std_hsv = zeros(1,3);
            mean_hsv(1) = wrapTo2Pi(circ_mean(masked_hue*2*pi)) / (2*pi);
            std_hsv(1)  = wrapTo2Pi(circ_std(masked_hue*2*pi)) / (2*pi);
            mean_hsv(2) = mean(masked_sat);
            std_hsv(2)  = std(masked_sat);
            mean_hsv(3) = mean(masked_v);
            std_hsv(3)  = std(masked_v);
            
            tracks(ii).mean_hsv = mean_hsv;
            tracks(ii).std_hsv  = std_hsv;
            
            tracks(ii).totalVisibleCount = tracks(ii).totalVisibleCount + 1;
            tracks(ii).consecutiveInvisibleCount = 0;
        else
            % was the object visible in the center view?
            
            tracks(ii).consecutiveInvisibleCount = tracks(ii).consecutiveInvisibleCount + 1;
        end
    end
    
    % update tracks for the full paw
    tracks(11).currentMask = mirror_fullPawMask;
    mirror_fullPawMask = connectBlobs(mirror_fullPawMask);
    s = regionprops(mirror_fullPawMask,'Centroid','BoundingBox');
    tracks(11).bbox = s.BoundingBox;
    
    % not sure if I need to update the CAMshiftTracker and/or Kalman
    % filter, or not
    
    tracks(11).totalVisibleCount = tracks(11).totalVisibleCount + 1;
    tracks(ii).consecutiveInvisibleCount = 0;

    
end


    
        
        
        
    
%         newTrack = struct(...
%             'id', ii, ...
%             'bbox', s(ii).BoundingBox, ...
%             'kalmanFilter', kalmanFilter, ...
%             'CAMshiftTracker', CAMshiftTracker, ...
%             'mean_hsv', mean_hsv, ...
%             'std_hsv', std_hsv, ...
%             'currentMask', squeeze(imgDigitMirrorMask(:,:,ii)), ...
%             'age', 1, ...
%             'totalVisibleCount', 1, ...
%             'consecutiveInvisibleCount', 1);
%     
%     % now figure out if part of the paw is hidden behind the front panel
%     s = regionprops(curr_paw_mask_mirror,'Area','BoundingBox', 'Centroid','ConvexHull','ConvexImage');
%     if length(s) > 1
%         [fullMask, fullHull] = multiRegionConvexHullMask(curr_paw_mask_mirror);
%         % does the full mask overlap with the front panel?
%         testMask = (boxFrontMask & fullMask);
%         if any(testMask(:))
%             % do some crude thresholding to determine 
%         end
%         
%     end
%     
%     masked_mirror_img = uint8(repmat(prev_paw_mask_mirror,1,1,3));
%     masked_mirror_img = masked_mirror_img  .* image;
% 
%     masked_center_img = uint8(repmat(prev_paw_mask_center,1,1,3));
%     masked_center_img = masked_center_img  .* image;
%     
% 
%     mirror_zmask = false(h,w,num_elements_to_track);
%     center_zmask = false(h,w,num_elements_to_track);
%     for ii = 2 : num_elements_to_track    % do all the digits first
%         masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...
%                                                   decorrStretchMean_mirror(ii,:), ...
%                                                   decorrStretchSigma_mirror(ii,:), ...
%                                                   'mask',prev_paw_mask_mirror);
%         masked_mirror_hsv = rgb2hsv(masked_mirror_img_enh);
% 
%         masked_center_img_enh = enhanceColorImage(masked_center_img, ...
%                                                   decorrStretchMean_center(ii,:), ...
%                                                   decorrStretchSigma_center(ii,:), ...
%                                                   'mask',prev_paw_mask_center);
%         masked_center_hsv = rgb2hsv(masked_center_img_enh);
%         
%         mirror_bbox = step(tracks(ii).CAMshiftTracker, masked_mirror_hsv(:,:,1));
%         center_bbox = step(tracks(ii+num_elements_to_track).CAMshiftTracker, masked_center_hsv(:,:,1));
%         
%         % create a "scribble" mask for each digit using the previous
%         % meanRGB values for that digit. Look only within the bounding box
%         % defined by the histogram tracker
%         mirror_bboxMask = false(h,w);
%         center_bboxMask = false(h,w);
%         mirror_bboxMask(mirror_bbox(2):mirror_bbox(2)+mirror_bbox(4)-1,...
%                         mirror_bbox(1):mirror_bbox(1)+mirror_bbox(3)-1) = true;
%         center_bboxMask(center_bbox(2):center_bbox(2)+center_bbox(4)-1,...
%                         center_bbox(1):center_bbox(1)+center_bbox(3)-1) = true;
%         mirror_RGBz = zeros(h,w,3);
%         center_RGBz = zeros(h,w,3);
%         for jj = 1 : 3
%             colPlane = squeeze(masked_mirror_img_enh(:,:,jj));
%             mirror_RGBz(:,:,jj) = (colPlane - tracks(ii).meanRGBenh(jj)) / ...
%                 tracks(ii).stdRGBenh(jj);
%             
%             colPlane = squeeze(masked_center_img_enh(:,:,jj));
%             center_RGBz(:,:,jj) = (colPlane - tracks(ii+num_elements_to_track).meanRGBenh(jj)) / ...
%                 tracks(ii+num_elements_to_track).stdRGBenh(jj);
%         end
%         
%         mirror_RGBzdist = sqrt(sum(mirror_RGBz.^2, 3));
%         center_RGBzdist = sqrt(sum(center_RGBz.^2, 3));
%         
%         mirror_zmask(:,:,ii) = (abs(mirror_RGBzdist) < color_zlim);
%         center_zmask(:,:,ii) = (abs(center_RGBzdist) < color_zlim);
%         
%         mirror_zmask(:,:,ii) = mirror_zmask(:,:,ii) & mirror_bboxMask;
%         center_zmask(:,:,ii) = center_zmask(:,:,ii) & center_bboxMask;
%         
%     end
%     masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...
%                                               decorrStretchMean_mirror(2,:), ...
%                                               decorrStretchSigma_mirror(2,:), ...
%                                               'mask',prev_paw_mask_center);
%     [~,mirror_P] = imseggeodesic(masked_mirror_img_enh, mirror_zmask(:,:,2), mirror_zmask(:,:,3), mirror_zmask(:,:,4));
%     [~,mirror_P2] = imseggeodesic(masked_mirror_img_enh, mirror_zmask(:,:,3), mirror_zmask(:,:,4), mirror_zmask(:,:,5));
%     
%     masked_center_img_enh = enhanceColorImage(masked_center_img, ...
%                                               decorrStretchMean_center(2,:), ...
%                                               decorrStretchSigma_center(2,:), ...
%                                               'mask',prev_paw_mask_center);
%     [~,center_P] = imseggeodesic(masked_center_img_enh, center_zmask(:,:,2), center_zmask(:,:,3), center_zmask(:,:,4));
%     [~,center_P2] = imseggeodesic(masked_center_img_enh, center_zmask(:,:,3), center_zmask(:,:,4), center_zmask(:,:,5));
%         
%     mirrorMask = false(h,w,num_elements_to_track);
%     centerMask = false(h,w,num_elements_to_track);
%     SE = strel('disk',2);
%     for ii = 2 : num_elements_to_track
%         switch ii,
%             case 2,   % index finger
%                 mirrorMask(:,:,ii) = (mirror_P(:,:,1) > pthresh);
%                 centerMask(:,:,ii) = (center_P(:,:,1) > pthresh);
%             case 3,   % middle finger
%                 mirrorMask(:,:,ii) = (mirror_P(:,:,2) > pthresh);
%                 centerMask(:,:,ii) = (center_P(:,:,2) > pthresh);
%             case 4,   % ring finger
%                 mirrorMask(:,:,ii) = (mirror_P2(:,:,2) > pthresh);
%                 centerMask(:,:,ii) = (center_P2(:,:,2) > pthresh);
%             case 5,   % pinky finger
%                 mirrorMask(:,:,ii) = (mirror_P2(:,:,3) > pthresh);
%                 centerMask(:,:,ii) = (center_P2(:,:,3) > pthresh);
%         end
%     
%         mirrorMask(:,:,ii) = imopen(mirrorMask(:,:,ii), SE);
%         mirrorMask(:,:,ii) = imclose(mirrorMask(:,:,ii), SE);
%         mirrorMask(:,:,ii) = imfill(mirrorMask(:,:,ii), 'holes');
%         
%         centerMask(:,:,ii) = imopen(centerMask(:,:,ii), SE);
%         centerMask(:,:,ii) = imclose(centerMask(:,:,ii), SE);
%         centerMask(:,:,ii) = imfill(centerMask(:,:,ii), 'holes');
%         
%     end
%     
%     % we have the previous paw mask, let's assume
% 
%     
%     masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...    % for paw dorsum
%                                               decorrStretchMean_center(1,:), ...
%                                               decorrStretchSigma_center(1,:), ...
%                                               'mask',prev_paw_mask_center);
%         
%         
% %         mirror_idx = find(mirror_bboxMask);
% %         center_idx = find(center_bboxMask);
% %         
% %         RGBdist = zeros(h,w);
% %         for jj = 1 : 3
% %             masked_mirror_img_enh(mirror_bbox(2):mirror_bbox(2)+mirror_bbox(4)-1,...
% %                         mirror_bbox(1):mirror_bbox(1)+mirror_bbox(3)-1)
% %             colPlane = squeeze(masked_mirror_img_enh(:,:,jj));
% %             mirror_RGBdist(jj) = colPlane(mirror_idx) - tracks(ii).meanRGBenh(jj);
% %             
% %             colPlane = squeeze(masked_center_img_enh(:,:,jj));
% %             center_RGBdist(jj) = colPlane(center_idx) - tracks(ii+num_elements_to_track).meanRGBenh(jj);
% %         end
% % %         mirror_RGBdist = 
% %         figure(1)
% %         rectangle('position',mirror_bbox,'edgecolor','r');
% %         rectangle('position',center_bbox,'edgecolor','r');
% %         
% %         figure(2)
% %         if ii == 1
% %             imshow(masked_mirror_img_enh)
% %         end
% %         rectangle('position',mirror_bbox,'edgecolor','r');
% %         
% %         figure(3)
% %         if ii == 1
% %             imshow(masked_center_img_enh)
% %         end
% %         rectangle('position',center_bbox,'edgecolor','r');
%     
%         
% %     paw_mask = maskPaw_moving(image, BGimg, prev_paw_mask, register_ROI, F, rat_metadata, boxMarkers);
% %     diff_image  = imabsdiff(image, BGimg);
% %     thresh_mask = (rgb2gray(diff_image) > diff_threshold);
% %     
% %     curr_mask = thresh_mask & prev_paw_mask;
% %     
% %     hsv_image = rgb2hsv(image.*uint8(repmat(curr_mask,1,1,3)));
% %     figure(1)
% %     imshow(image)
% %     hold on
% 
% %     for ii = 1 : numTracks
% %         bbox = step(tracks(ii).CAMshiftTracker, hsv_image(:,:,1));
% %         rectangle('position',bbox,'edgecolor','r');
% %     end
% %     paw_mask = maskPaw_moving(image, BGimg, digitMirrorMask_dorsum, digitCenterMask, register_ROI, F, rat_metadata, boxMarkers);
%     
%     
% %     figure(2)
% %     imshow(image);
% end
% % detector = vision.ForegroundDetector(...
% %    'NumTrainingFrames', 50, ... % 5 because of short video
% %    'InitialVariance', 30*30); % initial standard deviation of 30
% % blob = vision.BlobAnalysis(...
% %    'CentroidOutputPort', false, 'AreaOutputPort', false, ...
% %    'BoundingBoxOutputPort', true, ...
% %    'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 200);
% 
% sTime = (peakFrameNum / video.FrameRate);
% figure(1)
% frameNum = 0;
% while video.CurrentTime < video.Duration
%     image = readFrame(video);
%     fgMask = step(detector, image);
%     imshow(fgMask);
%     frameNum = frameNum + 1;
% end
% mirrorTracks_dorsum = initializeTracks();
% centerTracks        = initializeTracks();
% 
% % rewind 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tracks = initializeTracks()
    % create an empty array of tracks
    tracks = struct(...
        'id', {}, ...
        'bbox', {}, ...
        'kalmanFilter', {}, ...
        'CAMshiftTracker', {}, ...
        'mean_hsv', {}, ...
        'std_hsv', {}, ...
        'currentMask', {}, ...
        'age', {}, ...
        'totalVisibleCount', {}, ...
        'consecutiveInvisibleCount', {});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function obj = setupSystemObjects()
        % Initialize Video I/O
        % Create objects for reading a video from a file, drawing the tracked
        % objects in each frame, and playing the video.

        % Create a video file reader.
        obj.reader = vision.VideoFileReader('atrium.avi');

        % Create two video players, one to display the video,
        % and one to display the foreground mask.
        obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
        obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);

        % Create System objects for foreground detection and blob analysis

        % The foreground detector is used to segment moving objects from
        % the background. It outputs a binary mask, where the pixel value
        % of 1 corresponds to the foreground and the value of 0 corresponds
        % to the background.

        obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);

        % Connected groups of foreground pixels are likely to correspond to moving
        % objects.  The blob analysis System object is used to find such groups
        % (called 'blobs' or 'connected components'), and compute their
        % characteristics, such as area, centroid, and the bounding box.

        obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 400);
    end