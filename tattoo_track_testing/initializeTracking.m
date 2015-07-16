function tracks = initializeTracking(video, peakFrameNum, ...
                                              digitMirrorMask_dorsum, ...
                                              digitCenterMask, ...
                                              rat_metadata, ...
                                              register_ROI, ...
                                              boxMarkers, ...
                                              varargin)
                                          
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
                             100.0 100.0 150.0     % to isolate blue digits
                             150.0 100.0 150.0     % to isolate red digits
                             127.5 100.0 127.5     % to isolate green digits
                             150.0 100.0 150.0];   % to isolate red digits

decorrStretchSigma_mirror = [050 025 025       % to isolate dorsum of paw
                             025 025 050       % to isolate blue digits
                             050 025 025       % to isolate red digits
                             050 050 050       % to isolate green digits
                             050 025 025];     % to isolate red digits
                         
diff_threshold = 45;
maxDistPerFrame = 25;

colorList = {'darkgreen','blue','red','green','red'};
minSaturation = [0.00001,0.8,0.8,0.8,0.8];
max_Value = 0.15;
hueLimits = [0.00, 0.16;
             0.33, 0.16;
             0.66, 0.16];
         
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
im_hsv = rgb2hsv(image);

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
prev_paw_mask_mirror = false(h,w);
prev_paw_mask_center = false(h,w);
s = struct('Centroid', {}, ...
           'BoundingBox', {});
num_elements_to_track = size(digitMirrorMask_dorsum, 3);
imgDigitCenterMask = false(h,w,num_elements_to_track);
for ii = 1 : num_elements_to_track
    temp = squeeze(digitCenterMask(:,:,ii));
    imgDigitCenterMask(register_ROI(2,2):register_ROI(2,2)+register_ROI(2,4), ...
                       register_ROI(2,1):register_ROI(2,1)+register_ROI(2,3),ii) = temp;
                   
    s(ii) = regionprops(digitMirrorMask_dorsum(:,:,ii),'Centroid','BoundingBox');
    s(ii + num_elements_to_track) = regionprops(imgDigitCenterMask(:,:,ii),'Centroid','BoundingBox');
    
    prev_paw_mask_mirror = prev_paw_mask_mirror | digitMirrorMask_dorsum(:,:,ii);
    prev_paw_mask_center = prev_paw_mask_center | imgDigitCenterMask(:,:,ii);
end
prev_paw_mask_mirror = imdilate(prev_paw_mask_mirror, strel('disk', maxDistPerFrame));
prev_paw_mask_mirror = imfill(prev_paw_mask_mirror,'holes');
prev_paw_mask_mirror = prev_paw_mask_mirror & ~boxFrontMask;
% take the largest portion of the paw mask, in case there are parts
% on both sides of the mirror. This should be OK, at least for the
% initial frame.
labMask = bwlabel(prev_paw_mask_mirror);
s_paw = regionprops(prev_paw_mask_mirror,'area');
A = [s_paw.Area];
validIdx = find(A == max(A));
prev_paw_mask_mirror = (labMask == validIdx);
    
masked_mirror_img = uint8(repmat(prev_paw_mask_mirror,1,1,3));
masked_mirror_img = masked_mirror_img  .* image;

prev_paw_mask_center = imdilate(prev_paw_mask_center, strel('disk', maxDistPerFrame));
prev_paw_mask_center = imfill(prev_paw_mask_center,'holes');
masked_center_img = uint8(repmat(prev_paw_mask_center,1,1,3));
masked_center_img = masked_center_img  .* image;

meanRGBenh = zeros(1,3);stdRGBenh = zeros(1,3);
for ii = 1 : num_elements_to_track
    mirror_img_enh = enhanceColorImage(image, ...
                                       decorrStretchMean_mirror(ii,:), ...
                                       decorrStretchSigma_mirror(ii,:), ...
                                       'mask',prev_paw_mask_mirror);
	mirror_enh_hsv = rgb2hsv(mirror_img_enh);
    
    center_img_enh = enhanceColorImage(image, ...
                                       decorrStretchMean_center(ii,:), ...
                                       decorrStretchSigma_center(ii,:), ...
                                       'mask',prev_paw_mask_center);
	center_enh_hsv = rgb2hsv(center_img_enh);

	kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
        s(ii).Centroid, [200, 50], [100, 25], 100);
    CAMshiftTracker = vision.HistogramBasedTracker;

    initializeObject(CAMshiftTracker, im_hsv(:,:,1), round(s(ii).BoundingBox));

    tempMask = squeeze(digitMirrorMask_dorsum(:,:,ii));
    tempMask = tempMask & (mirror_enh_hsv(:,:,2) > minSaturation(ii));
    hue = squeeze(mirror_enh_hsv(:,:,1));
    masked_hue = hue(tempMask(:));
    sat = squeeze(mirror_enh_hsv(:,:,2));
    masked_sat = sat(tempMask(:));
    v = squeeze(mirror_enh_hsv(:,:,3));
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
        'currentMask', squeeze(digitMirrorMask_dorsum(:,:,ii)), ...
        'age', 1, ...
        'totalVisibleCount', 1, ...
        'consecutiveInvisibleCount', 0);
    numTracks = numTracks + 1;
    tracks(ii) = newTrack;

	kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
        s(ii+num_elements_to_track).Centroid, [200, 50], [100, 25], 100);
    CAMshiftTracker = vision.HistogramBasedTracker;
    initializeObject(CAMshiftTracker, im_hsv(:,:,1), round(s(ii+num_elements_to_track).BoundingBox));
    
    tempMask = squeeze(imgDigitCenterMask(:,:,ii));
    tempMask = tempMask & (center_enh_hsv(:,:,2) > minSaturation(ii));
%     hue = squeeze(center_enh_hsv(:,:,1));
%     masked_hue = hue(tempMask(:));
%     sat = squeeze(center_enh_hsv(:,:,2));
%     masked_sat = sat(tempMask(:));

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
masked_mirror_img_enh = enhanceColorImage(image, ...
                                          decorrStretchMean_mirror(1,:), ...
                                          decorrStretchSigma_mirror(1,:), ...
                                          'mask',prev_paw_mask_mirror);
% masked_mirror_hsv = rgb2hsv(masked_mirror_img_enh);
s_mirror = regionprops(prev_paw_mask_mirror,'Centroid','BoundingBox');

masked_center_img_enh = enhanceColorImage(image, ...
                                          decorrStretchMean_center(1,:), ...
                                          decorrStretchSigma_center(1,:), ...
                                          'mask',prev_paw_mask_center);
% masked_center_hsv = rgb2hsv(masked_center_img_enh);
s_center = regionprops(prev_paw_mask_center,'Centroid','BoundingBox');

kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
    s_mirror.Centroid, [200, 50], [100, 25], 100);
CAMshiftTracker = vision.HistogramBasedTracker;
initializeObject(CAMshiftTracker, im_hsv(:,:,1), round(s_mirror.BoundingBox));

numTracks = numTracks + 1;
newTrack = struct(...
    'id', numTracks, ...
    'bbox', s_mirror.BoundingBox, ...
    'kalmanFilter', kalmanFilter, ...
    'CAMshiftTracker', CAMshiftTracker, ...
    'mean_hsv', mean_hsv, ...
    'std_hsv', std_hsv, ...
    'currentMask', prev_paw_mask_mirror, ...
    'age', 1, ...
    'totalVisibleCount', 1, ...
    'consecutiveInvisibleCount', 0);
tracks(numTracks) = newTrack;

kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
    s_center.Centroid, [200, 50], [100, 25], 100);
CAMshiftTracker = vision.HistogramBasedTracker;
initializeObject(CAMshiftTracker, im_hsv(:,:,1), round(s_center.BoundingBox));

numTracks = numTracks + 1;
newTrack = struct(...
    'id', numTracks, ...
    'bbox', s_center.BoundingBox, ...
    'kalmanFilter', kalmanFilter, ...
    'CAMshiftTracker', CAMshiftTracker, ...
    'mean_hsv', mean_hsv, ...
    'std_hsv', std_hsv, ...
    'currentMask', prev_paw_mask_center, ...
    'age', 1, ...
    'totalVisibleCount', 1, ...
    'consecutiveInvisibleCount', 0);
tracks(numTracks) = newTrack;

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