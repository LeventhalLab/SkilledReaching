function digitTrajectories = track3Dpaw_forward(video, ...
                                         BGimg_ud, ...
                                         refImageTime, ...
                                         initDigitMasks, ...
                                         init_mask_bbox, ...
                                         currentDigitMarkers, ...
                                         rat_metadata, ...
                                         boxCalibration, ...
                                         varargin)
%
%
%
% INPUTS:
%    video - video reader object containing the current video under
%       analysis
%    BGimg_ud - undistorted background image
%    refImageTime - time in the video at which the initial digit
%       identification was made. Plan is to track backwards and forwards in
%       time
%    initDigitMasks - cell array. initDigitMasks{1} for the left mirror,
%       initDigitMasks{2} is the direct view, initDigitMasks{3} is the
%       right mirror. These are binary masks the size of the bounding box
%       around the initial paw masking
%    init_mask_bbox - 3 x 4 matrix, where each row contains the bounding
%       box for each viewMask. Format of each row is [x,y,w,h], where x,y
%       is the upper left corner of the bounding box, and w and h are the
%       width and height, respectively
%   currentDigitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)
%   rat_metadata - rat metadata structure containing the following fields:
%       .ratID - integer containing the rat identification number
%       .localizers_present - boolean indicating whether or not box
%           localizers (e.g., beads/checkerboards are present in the video.
%       	probably not necessary, but will leave in for now. -DL 20150831
%       .camera_distance - camera focal length; this is now stored
%           elsewhere, will probably be able to get rid of this
%       .pawPref - string or cell containing a string 'left' or 'right'
%   boxCalibration - 
%
% VARARGS:
%
% OUTPUTS:
%


% NEXT STEP - SEE HOW TRACKING DOES OVER TIME, THEN WORK ON ALGORITHM TO
% GUESS AT LOCATIONS OF HIDDEN DIGITS (AND DETERMINE IF DIGITS ARE
% PARTIALLY OBSCURED). IF DIGITS ARE PARTIALLY OBSCURED, WHAT'S THE BEST
% WAY TO GUESS AT THE "TRUE" 3D COORDINATES? MAY BE ABLE TO START WITH PAW
% DORSUM IN THE FIRST IMAGE...
% CAN WE DO SOMETHING WITH PREDICTING BASED ON HOW THE OTHER DIGITS MOVED?



decorrStretchMean  = cell(1,3);
decorrStretchSigma = cell(1,3);
decorrStretchMean{1}  = [075.0 127.5 075.0     % to isolate dorsum of paw
                         127.5 127.5 100.0     % to isolate blue digits
                         100.0 127.5 127.5     % to isolate red digits
                         100.0 025.0 100.0     % to isolate green digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 127.5 127.5
                         127.5 127.5 127.5];

decorrStretchSigma{1} = [050 075 050       % to isolate dorsum of paw
                         075 075 075       % to isolate blue digits
                         075 075 075       % to isolate red digits
                         075 075 075       % to isolate green digits
                         075 075 075       % to isolate red digits
                         075 075 075
                         075 075 075];
                     
decorrStretchMean{2}  = [075.0 127.5 075.0     % to isolate dorsum of paw
                         127.5 127.5 100.0     % to isolate blue digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 100.0 127.5     % to isolate green digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 127.5 127.5
                         127.5 127.5 127.5];
                     
decorrStretchSigma{2} = [050 075 050       % to isolate dorsum of paw
                         075 075 075       % to isolate blue digits
                         075 075 075       % to isolate red digits
                         075 075 075       % to isolate green digits
                         075 075 075       % to isolate red digits
                         075 075 075
                         075 075 075];
                     
decorrStretchMean{3}  = [075.0 127.5 075.0     % to isolate dorsum of paw
                         127.5 127.5 100.0     % to isolate blue digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 100.0 127.5     % to isolate green digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 127.5 127.5
                         127.5 127.5 127.5];
                     
decorrStretchSigma{3} = [050 075 050       % to isolate dorsum of paw
                         075 075 075       % to isolate blue digits
                         075 075 075       % to isolate red digits
                         075 075 075       % to isolate green digits
                         075 075 075       % to isolate red digits
                         075 075 075
                         075 075 075];
for ii = 1 : 3
    decorrStretchMean{ii} = decorrStretchMean{ii} / 255;
    decorrStretchSigma{ii} = decorrStretchSigma{ii} / 255;
end

HSVthresh_parameters.min_thresh(1) = 0.05;    % minimum distance hue threshold must be from mean. Note hue is circular (hue = 1 is the same as hue = 0)
HSVthresh_parameters.min_thresh(2) = 0.02;    % minimum distance saturation threshold must be from mean 
HSVthresh_parameters.min_thresh(3) = 0.02;    % minimum distance value threshold must be from mean 
HSVthresh_parameters.max_thresh(1) = 0.16;    % maximum distance hue threshold can be from mean. Note hue is circular (hue = 1 is the same as hue = 0)
HSVthresh_parameters.max_thresh(2) = 0.15;    % maximum distance saturation threshold can be from mean 
HSVthresh_parameters.max_thresh(3) = 0.30;    % maximum distance value threshold can be from mean 
HSVthresh_parameters.num_stds(1) = 2;         % number of standard deviations hue can deviate from mean (unless less than min_thresh or greater than max_thresh)
HSVthresh_parameters.num_stds(2) = 2;         % number of standard deviations saturation can deviate from mean (unless less than min_thresh or greater than max_thresh)
HSVthresh_parameters.num_stds(3) = 2;         % number of standard deviations value can deviate from mean (unless less than min_thresh or greater than max_thresh)
HSVthresh_parameters.dorsum_min_thresh(1) = 0.05;
HSVthresh_parameters.dorsum_min_thresh(2) = 0.15;
HSVthresh_parameters.dorsum_min_thresh(3) = 0.15;
HSVthresh_parameters.dorsum_max_thresh(1) = 0.16;
HSVthresh_parameters.dorsum_max_thresh(2) = 0.25;
HSVthresh_parameters.dorsum_max_thresh(3) = 0.25;
HSVthresh_parameters.dorsum_num_stds(1) = 3;
HSVthresh_parameters.dorsum_num_stds(2) = 3;
HSVthresh_parameters.dorsum_num_stds(3) = 3;

diff_threshold = 35;
raw_threshold = 0.2;
whiteFurThresh = 0.35;
maxDistPerFrame = 20;
dorsum_gray_thresh = 0.35;
% <<<<<<< HEAD
RGBradius = 0.1;
color_zlim = 2;
pthresh = 0.9;

h = video.Height;
w = video.Width;

boxMarkers = boxCalibration.boxMarkers;
F = boxCalibration.F;
P = boxCalibration.P;
K = boxCalibration.cameraParams.IntrinsicMatrix;

blueBeadMask = boxMarkers.beadReflectionMasks(:,:,3);

pawPref = lower(rat_metadata.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

BGimg_info = whos('BGimg_ud');
if strcmpi(BGimg_info.class,'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

% list of tattooed colors - first is paw dorsum, then index to pinky finger
colorList = {'darkgreen','blue','red','green','red'};

satLimits{1} = [0.20000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00];
valLimits{1} = [0.20000    1.00
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00];
hueLimits{1} = [0.00, 0.16;    % red
             0.33, 0.16;    % green
             0.66, 0.05;    % blue
             0.33, 0.16];   % dark green
         
satLimits{2} = [0.20000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00];
valLimits{2} = [0.20000    1.00
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00];
hueLimits{2} = [0.00, 0.16;    % red
             0.33, 0.16;    % green
             0.66, 0.05;    % blue
             0.50, 0.16];   % dark green
         
satLimits{3} = [0.20000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00];
valLimits{3} = [0.20000    1.00
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00];
hueLimits{3} = [0.00, 0.16;    % red
             0.33, 0.16;    % green
             0.66, 0.05;    % blue
             0.50, 0.16];   % dark green
         
% satLimits = [0.20000    1.00
%              0.90000    1.00
%              0.90000    1.00
%              0.90000    1.00
%              0.90000    1.00];
% valLimits = [0.00001    1.00
%              0.95000    1.00
%              0.95000    1.00
%              0.95000    1.00
%              0.95000    1.00];
% hueLimits = [0.00, 0.16;    % red
%              0.33, 0.16;    % green
%              0.66, 0.05;    % blue
%              0.33, 0.16];   % dark green
         
digitBlob = cell(1,2);
digitBlob{1} = vision.BlobAnalysis;
digitBlob{1}.AreaOutputPort = true;
digitBlob{1}.CentroidOutputPort = true;
digitBlob{1}.BoundingBoxOutputPort = true;
digitBlob{1}.ExtentOutputPort = true;
digitBlob{1}.LabelMatrixOutputPort = true;
digitBlob{1}.MinimumBlobArea = 100;
digitBlob{1}.MaximumBlobArea = 30000;

digitBlob{2} = vision.BlobAnalysis;
digitBlob{2}.AreaOutputPort = true;
digitBlob{2}.CentroidOutputPort = true;
digitBlob{2}.BoundingBoxOutputPort = true;
digitBlob{2}.ExtentOutputPort = true;
digitBlob{2}.LabelMatrixOutputPort = true;
digitBlob{2}.MinimumBlobArea = 40;
digitBlob{2}.MaximumBlobArea = 30000;

pdBlob{1} = vision.BlobAnalysis;
pdBlob{1}.AreaOutputPort = true;
pdBlob{1}.CentroidOutputPort = true;
pdBlob{1}.BoundingBoxOutputPort = true;
pdBlob{1}.ExtentOutputPort = true;
pdBlob{1}.LabelMatrixOutputPort = true;
pdBlob{1}.MinimumBlobArea = 100;
pdBlob{1}.MaximumBlobArea = 30000;

pdBlob{2} = vision.BlobAnalysis;
pdBlob{2}.AreaOutputPort = true;
pdBlob{2}.CentroidOutputPort = true;
pdBlob{2}.BoundingBoxOutputPort = true;
pdBlob{2}.ExtentOutputPort = true;
pdBlob{2}.LabelMatrixOutputPort = true;
pdBlob{2}.MinimumBlobArea = 100;
pdBlob{2}.MaximumBlobArea = 30000;

trackCheck.maxDistPerFrame = 1.5;    % in mm
trackCheck.maxReprojError = 0.1;   % not sure what this needs to be, will need some trial and error
trackCheck.maxPixelsPerFrame = 30;  % not sure what this needs to be, will need some trial and error
trackCheck.maxEpiLineDist = 10;     % how far a point in the mirror view can be from the epipolar line passing through the corresponding point in the direct view
trackCheck.frameHistoryLength = 5;    % number of frames to look back in estimating next frame

projectionDilation = 10;

HSVupdateRate = 0.1;    % rate at which to update mean and std HSV values
dorsumAngle = -6*pi/16;
% further down, will draw a line between the base of the 1st and 4th
% digits. The paw dorsum is assumed to lie on one side of this line,
% constrained by the geometry of the reach.

% =======
% >>>>>>> origin/master


for iarg = 1 : 2 : nargin - 8
    switch lower(varargin{iarg})
        case 'graypawlimits',
            gray_paw_limits = varargin{iarg + 1};
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
        case 'colorlist',
            colorList = varargin{iarg + 1};
        case 'maxdistperframe',
            trackCheck.maxDistPerFrame = varargin{iarg + 1};
        case 'maxreprojerror',
            trackCheck.maxReprojError = varargin{iarg + 1};
        case 'maxEpiLineDist',
            trackCheck.maxEpiLineDist = varargin{iarg + 1};
    end
end

digitColors = unique(colorList(2:5));   % possible digit colors
if diff_threshold > 1
    diff_threshold = diff_threshold / 255;
end

if raw_threshold > 1
    raw_threshold = raw_threshold / 255;
end

[~, center_region_mask] = reach_region_mask(boxMarkers, [h,w]);
leftRegion = false(h,w);
rightRegion = false(h,w);
frontPanelMask = false(h,w);

leftRegion(:,1:round(w/2)) = true;
leftRegion = leftRegion & ~center_region_mask;
rightRegion(:,round(w/2):end) = true;
rightRegion = rightRegion & ~center_region_mask;

for iSide = 1 : 2
    frontPanelMask = frontPanelMask | ...
        poly2mask(boxMarkers.frontPanel_x(iSide,:), ...
                  boxMarkers.frontPanel_y(iSide,:), ...
                  h,w);
end
SE = strel('disk',6);
frontPanelMask = imdilate(frontPanelMask,SE);
sideRegion = cell(1,2);
fundMat = zeros(3,3,2);
switch pawPref
    case 'left',
        dMirrorIdx = 3;   % index of mirror with dorsal view of paw
        pMirrorIdx = 1;   % index of mirror with palmar view of paw
        fundMat(:,:,1) = F.right;
        fundMat(:,:,2) = F.left;
        P2 = P.right;
        scale = boxCalibration.scale(2);
        sideRegion{1} = rightRegion;
        sideRegion{2} = leftRegion;
        dorsumAngle = -dorsumAngle;
        d_frontPanel_x = boxMarkers.frontPanel_x(2,:);
        d_frontPanel_y = boxMarkers.frontPanel_y(2,:);
    case 'right',
        dMirrorIdx = 1;   % index of mirror with dorsal view of paw
        pMirrorIdx = 3;   % index of mirror with palmar view of paw
        fundMat(:,:,1) = F.left;
        fundMat(:,:,2) = F.right;
        P2 = P.left;
        scale = boxCalibration.scale(1);
        sideRegion{1} = leftRegion;
        sideRegion{2} = rightRegion;
        d_frontPanel_x = boxMarkers.frontPanel_x(1,:);
        d_frontPanel_y = boxMarkers.frontPanel_y(1,:);
end
pelletMasks = cell(1,3);
SE = strel('disk',2);
pelletMasks{1} = imdilate(boxCalibration.boxMarkers.pelletMasks{2}, SE);    % direct view
pelletMasks{2} = imdilate(boxCalibration.boxMarkers.pelletMasks{dMirrorIdx}, SE);    % dorsum mirror view
pelletMasks{3} = imdilate(boxCalibration.boxMarkers.pelletMasks{pMirrorIdx}, SE);    % palmar mirror view

trackingBoxParams.K = K;
trackingBoxParams.F = fundMat;
P1 = eye(4,3);
trackingBoxParams.P1 = P1;
trackingBoxParams.P2 = P2;
trackingBoxParams.scale = scale;
trackingBoxParams.epipole = zeros(2,2);
trackingBoxParams.imSize = [h,w];
for iSide = 1 : 2
    [~,trackingBoxParams.epipole(iSide,:)] = isEpipoleInImage(fundMat(:,:,iSide),[size(BGimg_ud,1),size(BGimg_ud,2)]);
end

% make the first view the direct view, the second view is the mirror view
digitMasks = cell(2,1);
digitMasks{1} = initDigitMasks{2};
digitMasks{2} = initDigitMasks{dMirrorIdx};
digitMasks{3} = initDigitMasks{pMirrorIdx};
mask_bbox = zeros(3,4);
mask_bbox(1,:) = init_mask_bbox(2,:);
mask_bbox(2,:) = init_mask_bbox(dMirrorIdx,:);
mask_bbox(3,:) = init_mask_bbox(pMirrorIdx,:);

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = refImageTime;
image = readFrame(video);
image_ud = undistortImage(image, boxCalibration.cameraParams);
image_ud = double(image_ud) / 255;
numFrames = video.Duration * video.FrameRate;
currentFrame = video.FrameRate * refImageTime;

digitTrajectories = zeros(numFrames - currentFrame + 1, 5, 3, 3);    % numFrames by numPawParts by 3 pointsPerDigit by (x,y,z)
pawTrajectory = zeros(numFrames - currentFrame + 1, 3);
meanDigitTrajectory = zeros(numFrames - currentFrame + 1, 3);
% initialize one track each for the dorsum of the paw and each digit in the
% mirror and center views

tracks = initializeTracks();

s = struct('Centroid', {}, ...
           'BoundingBox', {});
num_elements_to_track = size(digitMasks{2}, 3) + 1;   % tracks(6) is the whole paw mask, tracks(7) is the pellet 
meanHSV = zeros(3,num_elements_to_track-1,3);
stdHSV = zeros(3,num_elements_to_track-1,3);
isVisible = false(num_elements_to_track-1, 3);
totalVisCount = zeros(num_elements_to_track-1, 3);
consecInvisibleCount = zeros(num_elements_to_track-1, 3);
for ii = 1 : num_elements_to_track - 1

    for iView = 1 : 3

        temp = digitMasks{iView}(:,:,ii);
        if any(temp(:))   % the digit was found in this view
            isVisible(ii,iView) = true;
            totalVisCount(ii,iView) = totalVisCount(ii,iView) + 1;
            
            s(iView,ii) = regionprops(squeeze(digitMasks{iView}(:,:,ii)),'centroid','BoundingBox');
            s(iView,ii).Centroid = s(iView,ii).Centroid + mask_bbox(iView,1:2);
            s(iView,ii).BoundingBox(1:2) = floor(s(iView,ii).BoundingBox(1:2)) + mask_bbox(iView,1:2);
            s(iView,ii).BoundingBox(3:4) = s(iView,ii).BoundingBox(3:4) + 2;

            paw_img = image_ud(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                               mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3),:);
            paw_enh = enhanceColorImage(paw_img, ...
                                        decorrStretchMean{iView}(ii,:), ...
                                        decorrStretchSigma{iView}(ii,:), ...
                                        'mask', digitMasks{iView}(:,:,6));
            paw_hsv = rgb2hsv(paw_enh);
            
            [meanHSV(iView,ii,:), stdHSV(iView,ii,:)] = ...
                calcHSVstats(paw_hsv, digitMasks{iView}(:,:,ii));
        else
            consecInvisibleCount(ii,iView) = consecInvisibleCount(ii,iView) + 1;
            switch lower(colorList{ii}),
                case 'red',
                    colorIdx = 1;
                case 'green',
                    colorIdx = 2;
                case 'blue',
                    colorIdx = 3;
                case 'darkgreen',
                    colorIdx = 4;
            end
            meanHSV(iView,ii,1) = hueLimits{iView}(colorIdx,1);
            stdHSV(iView,ii,1) = hueLimits{iView}(colorIdx,2) / HSVthresh_parameters.num_stds(1);
            meanHSV(iView,ii,2) = mean(satLimits{iView}(ii,:),2);
            stdHSV(iView,ii,2) = range(satLimits{iView}(ii,:)) / HSVthresh_parameters.num_stds(2);
            meanHSV(iView,ii,3) = mean(valLimits{iView}(ii,:),2);
            stdHSV(iView,ii,3) = range(valLimits{iView}(ii,:)) / HSVthresh_parameters.num_stds(3);
            s(iView,ii).BoundingBox = zeros(1,4);
        end
    end
    
end

% establish the track for the pellet
mean_pelletHSV = zeros(3,3);
std_pelletHSV  = zeros(3,3);
isPelletVisible = false(1,3);
pellet_bbox = [1 1 h-1 w-1];
fullPelletMarkers = zeros(3,2);
for iView = 1 : 3
    s_pellet(iView) = regionprops(pelletMasks{iView},'centroid','boundingbox');
    fullPelletMarkers(iView,:) = s_pellet(iView).Centroid;

    BGhsv = rgb2hsv(BGimg_ud);
    isPelletVisible(iView) = any(pelletMasks{iView}(:));
    [mean_pelletHSV(iView,:), std_pelletHSV(iView,:)] = ...
        calcHSVstats(BGhsv, pelletMasks{iView});
end
direct_pellet_norm = normalize_points(s_pellet(1).Centroid, trackingBoxParams.K);
mirror_pellet_norm = normalize_points(s_pellet(2).Centroid, trackingBoxParams.K);
[points3d,~,~] = triangulate_DL(direct_pellet_norm, ...
                                mirror_pellet_norm, ...
                                P1, P2);
points3d = points3d * trackingBoxParams.scale;

bbox = [s_pellet.BoundingBox];
bbox = reshape(bbox,[4,3])';

pelletTrack = struct(...
    'id', num_elements_to_track, ...
    'bbox', bbox, ...
    'color', 'multi', ...
    'digitmask1', pelletMasks{1}, ...
    'digitmask2', pelletMasks{2}, ...
    'digitmask3', pelletMasks{3}, ...
    'prevmask1', pelletMasks{1}, ...
    'prevmask2', pelletMasks{2}, ...
    'prevmask3', pelletMasks{3}, ...
    'meanHSV', mean_pelletHSV, ...
    'stdHSV', std_pelletHSV, ...
    'markers3D', points3d, ...
    'prev_markers3D', points3d, ...
    'currentDigitMarkers', fullPelletMarkers, ...
    'previousDigitMarkers', fullPelletMarkers, ...
    'age', 1, ...
    'isvisible', isPelletVisible, ...
    'markersCalculated', false(1,3), ...
    'totalVisibleCount', double(isPelletVisible), ...
    'consecutiveInvisibleCount', double(~isPelletVisible));

tracks = initializeTracks();
markers3D = zeros(num_elements_to_track-1,3,3);
% markers3D(2:5,:,:) = currentDigitMarkersTo3D(currentDigitMarkers, trackingBoxParams, mask_bbox);
markers3D = currentDigitMarkersTo3D(currentDigitMarkers, trackingBoxParams, mask_bbox);

pawMarkers = zeros(1,2,1,2);
pawMask = cell(1,2);
meanDigitMarkers = zeros(1,2,1,2);
for iView = 1 : 2
    pawMask{iView} = multiRegionConvexHullMask(digitMasks{iView}(:,:,6));
    s_paw = regionprops(pawMask{iView});
    pawMarkers(1,:,1,iView) = s_paw.Centroid;
    fullDigitMask = false(h,w);
    tempMask = false(h,w);
    for ii = 2 : 5
        tempMask(mask_bbox(iView,2):mask_bbox(iView,2) + mask_bbox(iView,4), ...
                 mask_bbox(iView,1):mask_bbox(iView,1) + mask_bbox(iView,3)) = digitMasks{iView}(:,:,ii);
        fullDigitMask = fullDigitMask | tempMask;
    end
    fullDigitMask = multiRegionConvexHullMask(fullDigitMask);
    s_meanDigit = regionprops(fullDigitMask,'centroid');
    meanDigitMarkers(1,:,1,iView) = s_meanDigit.Centroid - mask_bbox(iView,1:2);
end
pawTrajectory(1,:) = squeeze(currentDigitMarkersTo3D(pawMarkers, trackingBoxParams, mask_bbox))';
meanDigitTrajectory(1,:) = squeeze(currentDigitMarkersTo3D(meanDigitMarkers, trackingBoxParams, mask_bbox))';
digitTrajectories(1,:,:,:) = markers3D(1:5,:,:);

fullDigMarkers = zeros(6,2,3,2);
fullDigMarkers(1:5,:,:,:) = currentDigitMarkers;
for ii = 1 : num_elements_to_track - 1
    
    bbox = [s(:,ii).BoundingBox];
    bbox = reshape(bbox,[4,3])';
%   currentDigitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)

    if ii < 6
        curColor = colorList{ii};
        current3D = squeeze(markers3D(ii,:,:));
    else
        curColor = 'multi';
        current3D = zeros(3,3);
        current3D(2,:) = pawTrajectory(1,:);
    end
    newTrack = struct(...
        'id', ii, ...
        'bbox', bbox, ...
        'color', curColor, ...
        'digitmask1', squeeze(digitMasks{1}(:,:,ii)), ...
        'digitmask2', squeeze(digitMasks{2}(:,:,ii)), ...
        'digitmask3', squeeze(digitMasks{3}(:,:,ii)), ...
        'prevmask1', squeeze(digitMasks{1}(:,:,ii)), ...
        'prevmask2', squeeze(digitMasks{2}(:,:,ii)), ...
        'prevmask3', squeeze(digitMasks{3}(:,:,ii)), ...
        'meanHSV', squeeze(meanHSV(:,ii,:)), ...
        'stdHSV', squeeze(stdHSV(:,ii,:)), ...
        'markers3D', current3D, ...
        'prev_markers3D', current3D, ...
        'currentDigitMarkers', squeeze(fullDigMarkers(ii,:,:,:)), ...
        'previousDigitMarkers', squeeze(fullDigMarkers(ii,:,:,:)), ...
        'age', 1, ...
        'isvisible', isVisible(ii,:), ...
        'markersCalculated', false(1,2), ...
        'totalVisibleCount', totalVisCount(ii,:), ...
        'consecutiveInvisibleCount', consecInvisibleCount(ii,:));
    tracks(ii) = newTrack;
end
tracks(num_elements_to_track) = pelletTrack;

% now that tracks are initialized, do the actual tracking
paw_hsv = cell(1,2);
paw_img = cell(1,2);
HSVlimits = zeros(num_elements_to_track-1, 6, 2);
numFrames = 1;
current_BG_mask = cell(1,3);
current_paw_mask = cell(1,3);

dorsum_decorrStretchMean = cell(1,2);
dorsum_decorrStretchSigma = cell(1,2);
for iView = 1 : 2
    dorsum_decorrStretchMean{iView} = decorrStretchMean{iView}(1,:);
    dorsum_decorrStretchSigma{iView} = decorrStretchSigma{iView}(1,:);
end

dorsum_past_frontPanel = false;

plotTracks(tracks, image_ud, mask_bbox,[d_frontPanel_x;d_frontPanel_y])

while video.CurrentTime < video.Duration
    numFrames = numFrames + 1;
    fprintf('frame number: %d\n', numFrames)
    
    currentFrame = currentFrame + 1;
    image = readFrame(video);
    image_ud = undistortImage(image, boxCalibration.cameraParams);
    image_ud = double(image_ud) / 255;
    
    BG_diff = imabsdiff(BGimg_ud,image_ud);
    
    BG_mask = false(h,w);
    for iCh = 1 : 3
        BG_mask = BG_mask | (squeeze(BG_diff(:,:,iCh)) > diff_threshold);
    end
    
    SE = strel('disk',2);
    BG_mask = bwdist(BG_mask) < 2;
    BG_mask = imopen(BG_mask, SE);
    BG_mask = imclose(BG_mask,SE);
    BG_mask = BG_mask & ~frontPanelMask;    % semi-opaque front panels sometimes pop out in the difference image as rats pass behind them
    BG_mask = imfill(BG_mask,'holes');
    BG_mask = BG_mask & ~frontPanelMask;

    prev_mask_bbox = mask_bbox;
%     prev_paw_mask = false(h,w);
    
%     prev_digitMask = cell(1,2);
    prev_paw_mask = false(h,w,3);
    for iView = 1 : 3
        digitMaskStr = sprintf('digitmask%d',iView);
        pawMask = tracks(num_elements_to_track-1).(digitMaskStr);
        
        if iView == 2
            pawMask = pawMask | tracks(1).(digitMaskStr);    % makes sure paw dorsum behind the front panel edge gets counted
            pawMask = multiRegionConvexHullMask(pawMask);
%             pawMask = imdilate(pawMask, strel('disk',2));
        end
        
        % HAVE TO FIGURE OUT WHAT TO DO WITH THE NON-PAW DORSUM VIEW HERE;
        % NEED TO DECIDE WHETHER TO GENERATE A MASK FOR IT AT THE END OR
        % JUST IGNORE TRYING TO FIGURE OUT WHEN IT PASSES BEHIND THE BOX
        % FRONT
        prev_paw_mask(prev_mask_bbox(iView,2) : prev_mask_bbox(iView,2) + prev_mask_bbox(iView,4),...
                      prev_mask_bbox(iView,1) : prev_mask_bbox(iView,1) + prev_mask_bbox(iView,3),iView) = pawMask;

%         if iView < 3
%             prev_digitMask{iView} = false(h,w);
%             tempMask = false(h,w);
%             for ii = 2 : 5
%                 digitMask = eval(sprintf('tracks(ii).digitmask%d', iView));
%                 tempMask(mask_bbox(iView,2):mask_bbox(iView,2) + mask_bbox(iView,4), ...
%                          mask_bbox(iView,1):mask_bbox(iView,1) + mask_bbox(iView,3)) = digitMask;
%                 prev_digitMask{iView} = prev_digitMask{iView} | tempMask;
%             end
%             prev_digitMask{iView} = multiRegionConvexHullMask(prev_digitMask{iView});
%         else
%             prev_digitMask{iView} = false(h,w);
%             prev_digitMask{iView}(prev_mask_bbox(iView,2) : prev_mask_bbox(iView,2) + prev_mask_bbox(iView,4),...
%                                   prev_mask_bbox(iView,1) : prev_mask_bbox(iView,1) + prev_mask_bbox(iView,3)) = ...
%                                   pawMask;
%         end
    end
    
    full_prev_paw_mask = prev_paw_mask(:,:,1) | prev_paw_mask(:,:,2) | prev_paw_mask(:,:,3);
    
%     full_prev_digMask = prev_digitMask{1} | prev_digitMask{2} | prev_digitMask{3};
    % exclude anything too dark to be the paw (e.g., nose, etc.)
    grayMask = false(h,w);
    for iColor = 1 : 3
        grayMask = grayMask | (image_ud(:,:,iColor) > raw_threshold);
    end
    BG_mask = BG_mask & grayMask;
	% find overlap between previous mask and current mask, and keep those
    % parts of the background mask that overlapped with the previous mask
    overlapMask = full_prev_paw_mask & BG_mask;
    BG_mask = imreconstruct(overlapMask, BG_mask);
    BG_mask = BG_mask | (full_prev_paw_mask & frontPanelMask);
%         (imdilate(full_prev_paw_mask,strel('disk',trackCheck.maxPixelsPerFrame)) & frontPanelMask);
    
    % for the side views, let the paw start to drift behind the edge of the
    % front panel
    current_BG_mask{1} = center_region_mask & BG_mask;
    current_BG_mask{2} = sideRegion{1} & BG_mask;
    current_BG_mask{3} = sideRegion{2} & BG_mask;
%     predictedMask = false(h,w,3);
    
    for iView = 1 : 3
        current_BG_mask{iView} = current_BG_mask{iView} & imdilate(full_prev_paw_mask,strel('disk',trackCheck.maxPixelsPerFrame));
    end
%         current_BG_mask{2} = current_BG_mask{2} & imdilate(full_prev_paw_mask,strel('disk',trackCheck.maxPixelsPerFrame));
%     for iView = 2 : 3
%         hullMask = multiRegionConvexHullMask(current_BG_mask{iView});
%         s_BGmask = regionprops(hullMask,'centroid','BoundingBox');
%         s_prevMask = regionprops(prev_paw_mask(:,:,iView),'Centroid','BoundingBox');
%         
%         maskShift = s_BGmask.Centroid - s_prevMask.Centroid;
%         old_bbox = round(s_prevMask.BoundingBox);
%         new_bbox = round(s_prevMask.BoundingBox);
%         new_bbox(1:2) = round(new_bbox(1:2) + maskShift);
%         predictedMask(new_bbox(2) : new_bbox(2) + new_bbox(4), ...
%                       new_bbox(1) : new_bbox(1) + new_bbox(3), iView) = ...
%              prev_paw_mask(old_bbox(2) : old_bbox(2) + old_bbox(4), ...
%                            old_bbox(1) : old_bbox(1) + old_bbox(3), iView);
%         predictedMask(:,:,iView) = predictedMask(:,:,iView) & frontPanelMask;
%     end
    
    
%     BG_mask = BG_mask & ...
%         imdilate(full_prev_digMask,strel('disk',trackCheck.maxPixelsPerFrame));
%     BG_mask = BG_mask & ...
%         imdilate(prev_paw_mask,strel('disk',trackCheck.maxPixelsPerFrame));
    
%     figure(4); imshow(BG_mask);
    % will eventually need code here to deal with partial occlusions of the
    % full paw mask
    SE = strel('disk',5);    % only need this because of partial occlusion behind checkerboard
    % can probably eliminate the line above when we start analyzing boxes
    % without the checkerboards
    for iView = 1 : 3
        current_paw_mask{iView} = imdilate(current_BG_mask{iView}, SE);
    end
    projMask1 = pawProjectionMask(current_paw_mask{2}, fundMat(:,:,1)', [h,w]);
    projMask2 = pawProjectionMask(current_paw_mask{3}, fundMat(:,:,2)', [h,w]);
    projMask1 = imdilate(projMask1,strel('disk',projectionDilation));
    projMask2 = imdilate(projMask2,strel('disk',projectionDilation));
    
    current_paw_mask{1} = current_paw_mask{1} & projMask1 & projMask2;
    
    projMask1 = pawProjectionMask(current_BG_mask{2}, fundMat(:,:,1)', [h,w]);
    projMask2 = pawProjectionMask(current_BG_mask{3}, fundMat(:,:,2)', [h,w]);
    current_BG_mask{1} = current_BG_mask{1} & projMask1 & projMask2;
    
    for iView = 1 : 3
%         current_paw_mask{iView} = current_paw_mask{iView} | predictedMask(:,:,iView);
        current_paw_mask{iView} = multiRegionConvexHullMask(current_paw_mask{iView});
        current_paw_mask{iView} = current_paw_mask{iView} & ...
            imdilate(full_prev_paw_mask,strel('disk',trackCheck.maxPixelsPerFrame));    % don't let the mask grow too quickly - messes up prediction of digit marker locations
        
%         if iView == 2
%             figure(5);
%             imshow(current_paw_mask{2});
%         end
        % above line is in case there are multiple parts of the mask (for
        % example, if there is partial occlusion of the paw behind the box
        % front
        if iView == 1
            current_paw_mask_plus_front = current_paw_mask{iView};
        else
            hemiMask = false(h,w);
            if iView == 2 && dMirrorIdx == 1
                hemiMask(:,1:round(w/2)) = true;
            else
                hemiMask(:,round(w/2):w) = true;
            end
            frontMask = frontPanelMask & hemiMask;
            current_paw_mask_plus_front = current_paw_mask{iView} | frontMask;
            current_paw_mask_plus_front = multiRegionConvexHullMask(current_paw_mask_plus_front);
        end
        % make sure to include the front panel edge in the bounding box so
        % that we can use it later as the paw passes behind the edge of the
        % front panel
        s = regionprops(current_paw_mask_plus_front,'BoundingBox');
        mask_bbox(iView,:) = floor(s.BoundingBox) - 10;
        mask_bbox(iView,3:4) = mask_bbox(iView,3:4) + 30;
        
        tempMask = current_paw_mask{iView};
        current_paw_mask{iView} = tempMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                           mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
                                       
        tempMask = current_BG_mask{iView};
        current_BG_mask{iView} = tempMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                          mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
        current_BG_mask{iView} = imfill(current_BG_mask{iView},'holes');
        paw_hsv{iView} = zeros(mask_bbox(iView,4)+1,mask_bbox(iView,3)+1,3,num_elements_to_track-1);
    end
    % now, get rid of all the bits that are too small, the wrong shape, 
    % etc. This is where we need to start thinking about what to do when
    % the paw passes behind the edge of the box and there will be two paw 
    % parts. A model of the paw might solve this problem, but would like to 
    % get away with doing this without one...
    
%     tracks(num_elements_to_track-1).previousDigitMarkers = ...
%         tracks(num_elements_to_track-1).currentDigitMarkers;
%     for iView =1 : 3
%         digitMaskStr = sprintf('digitmask%d',iView);
%         tracks(num_elements_to_track-1).(digitMaskStr) = current_paw_mask{iView};
%         
%         if iView < 3
%             s_paw = regionprops(current_paw_mask{iView},'centroid');
%             tracks(num_elements_to_track-1).currentDigitMarkers(:,2,iView) = s_paw.Centroid';
%         end
%     end
    
    for ii = 1 : num_elements_to_track - 1
        
        for iView = 1 : 2
            paw_img{iView} = image_ud(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                      mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3),:);
            paw_enh = enhanceColorImage(paw_img{iView}, ...
                                        decorrStretchMean{iView}(ii,:), ...
                                        decorrStretchSigma{iView}(ii,:), ...
                                        'mask',current_paw_mask{iView});
            hsvMask = double(repmat(current_paw_mask{iView},1,1,3));
            paw_hsv{iView}(:,:,:,ii) = rgb2hsv(hsvMask .* paw_enh);
            
        end
    end
    
    % now do the thresholding
    hsv = cell(1,2);
    beadMask = cell(1,2);
    prelim_digitMask = cell(1,num_elements_to_track-2);
    
    startFrameIdx = max(numFrames - trackCheck.frameHistoryLength, 1);
    endFrameIdx   = numFrames - 1;

    recentDigitHistory = digitTrajectories(startFrameIdx:endFrameIdx,:,:,:);
    recentPawHistory = pawTrajectory(startFrameIdx:endFrameIdx,:);
    recentMeanDigitHistory = meanDigitTrajectory(startFrameIdx:endFrameIdx,:);

    nextPoints = predictNext3Dpoints(recentDigitHistory, ...
                                     recentPawHistory, ...
                                     current_paw_mask, ...
                                     mask_bbox, ...
                                     trackingBoxParams,...
                                     trackCheck);
                                     
    for ii = 2 : num_elements_to_track - 2    % do the digits first
        prelim_digitMask{ii} = cell(1,2);
        
        sameColIdx = find(strcmp(colorList{ii},colorList));
        numSameColorObjects = length(sameColIdx);
        
        for iView = 1 : 2
            hsv{iView} = squeeze(paw_hsv{iView}(:,:,:,ii));
            if strcmpi(colorList{ii},'blue')
                beadMask{iView} = blueBeadMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                               mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
            else
                beadMask{iView} = false(size(hsv{iView},1),size(hsv{iView},2));
            end
        end
    
        NP = squeeze(nextPoints(ii,2,:))';
        tempMask = thresholdDigits(tracks(ii), ...
                                   NP, ...
                                   HSVthresh_parameters, ...
                                   hsv, ...
                                   beadMask, ...
                                   mask_bbox, ...
                                   prev_mask_bbox, ...
                                   trackingBoxParams, ...
                                   trackCheck);
        for iView = 1 : 2
            s = regionprops(tempMask{iView},'centroid');
            if length(s) > numSameColorObjects    % found too many blobs
                labMat = bwlabel(tempMask{iView});
                % find the blob closest to the previous blob
                new_centroids = [s.Centroid];
                new_centroids = reshape(new_centroids,2,[])';
                prev_centroid = tracks(ii).currentDigitMarkers(:,2,iView)';
                [~, nnidx] = findNearestNeighbor(prev_centroid, new_centroids);
                
                tempMask{iView} = (labMat == nnidx);
            end
            prelim_digitMask{ii}{iView} = tempMask{iView};
        end
        
    end

    for iColor = 1 : length(digitColors)
        
        sameColIdx = find(strcmp(digitColors{iColor},colorList));
        numSameColorObjects = length(sameColIdx);
        colorTracks = initializeTracks();
        prelimMask = cell(numSameColorObjects, 2);
        for iDigit = 1 : numSameColorObjects
            colorTracks(iDigit) = tracks(sameColIdx(iDigit));
            for iView = 1 : 2
                prelimMask{iDigit,iView} = prelim_digitMask{sameColIdx(iDigit)}{iView};
            end
        end

        % this is where the digitmasks are updated within the tracks; need
        % to update the previous masks in the tracks here as well
        newTracks = assign_prelim_blobs_to_tracks(colorTracks, ...
                                                  prelimMask, ...
                                                  mask_bbox, ...
                                                  prev_mask_bbox, ...
                                                  trackingBoxParams, ...
                                                  trackCheck, ...
                                                  nextPoints(sameColIdx,:,:));
            
        for iDigit = 1 : numSameColorObjects
            tracks(sameColIdx(iDigit)) = newTracks(iDigit);
%             fullDigitMasks{1} = fullDigitMasks{1} | ...
%                                 tracks(sameColIdx(iDigit)).digitmask1;
%             fullDigitMasks{2} = fullDigitMasks{2} | ...
%                                 tracks(sameColIdx(iDigit)).digitmask2;
        end
    end    % end for iColor...
    % now that we have the digits, eliminate  where the pellet is/was
    % located as part of the paw mask, except for where digits have already
    % been identified
    fullDigitMask = cell(1,2);
    for iView = 1 : 2
        digMaskField = sprintf('digitmask%d',iView);
        fullDigitMask{iView} = false(size(tracks(2).(digMaskField)));
        for iTrack = 2 : 5
            fullDigitMask{iView} = fullDigitMask{iView} | tracks(iTrack).(digMaskField);
        end
        currentPelletMask = pelletMasks{iView}(mask_bbox(iView,2):mask_bbox(iView,2)+mask_bbox(iView,4),...
                                               mask_bbox(iView,1):mask_bbox(iView,1)+mask_bbox(iView,3));
        current_BG_mask{iView} = current_BG_mask{iView} & ~currentPelletMask;
        % keep only the largest blob
        s = regionprops(current_BG_mask{iView},'area');
        bg_label = bwlabel(current_BG_mask{iView});
        if ~isempty(s)
            max_A_idx = find([s.Area] == max([s.Area]));
            current_BG_mask{iView} = (bg_label == max_A_idx);
        end
        
        current_BG_mask{iView} = current_BG_mask{iView} | fullDigitMask{iView};
        current_BG_mask{iView} = connectBlobs(current_BG_mask{iView});
    end
    
    % now should have the digits - need to identify the dorsal aspect of
    % the paw...
    % first step is to make sure none of the digit masks bleed into the paw
    % dorsum region. Make sure that if we connect the base of the first and
    % last digits, no other digit masks cross that line (for example,
    % misidentifying part of the green paw dorsum as part of a green digit)

    % find the 3d points of all digits visible in both views, and the
    % general region in which the dorsum of the paw must appear
    [currentDigitMarkers, pts_transformed, digitsHull] = ...
        findDigitMarkers(tracks, pawPref, mask_bbox, prev_mask_bbox);
    for iTrack = 2 : 5
        tracks(iTrack).currentDigitMarkers = squeeze(currentDigitMarkers(iTrack-1,:,:,:));
    end

    % now have to deal with partially hidden objects
    tracks = reconstructPartiallyHiddenObjects(tracks, mask_bbox, fundMat, [h,w], current_BG_mask);

    % triangulate all available digit markers
    tracks(2:5) = digit3Dpoints(trackingBoxParams, tracks(2:5), mask_bbox);
    
    % now have to deal with completely hidden digits
    tracks = reconstructCompletelyHiddenObjects(tracks, ...
                                                mask_bbox, ...
                                                prev_mask_bbox, ...
                                                fundMat, ...
                                                [h,w], ...
                                                current_BG_mask, ...
                                                trackingBoxParams);
    NP = squeeze(nextPoints(1,2,:))';
    tracks = findDorsumRegion(tracks, ...
                              paw_img, ...
                              HSVthresh_parameters, ...
                              current_BG_mask, ...
                              dorsum_decorrStretchMean, ...
                              dorsum_decorrStretchSigma, ...
                              pdBlob, ...
                              trackingBoxParams, ...
                              NP, ...
                              mask_bbox, ...
                              prev_mask_bbox, ...
                              pts_transformed, ...
                              digitsHull, ...
                              d_frontPanel_x, ...
                              d_frontPanel_y, ...
                              dorsumAngle, ...
                              dorsum_past_frontPanel, ...
                              raw_threshold);
        
                                    
            %   currentDigitMarkers - nx2xmx2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is the site along each digit
%       (that is, proximal, centroid, distal, etc.), 4th dimension is the
%       view (1 = direct, 2 = mirror)
    % now have to do something about objects that aren't visible in one of
    % the views...
    
    tracks = updateHSVparams(tracks, paw_hsv, HSVupdateRate);
    
    tracks(num_elements_to_track-1).previousDigitMarkers = ...
        tracks(num_elements_to_track-1).currentDigitMarkers;
    for iView = 1 : 2
        digitMaskStr = sprintf('digitmask%d',iView);
        fullPawMask = false(size(tracks(1).(digitMaskStr)));
        for iDigit = 1 : 5
            fullPawMask = fullPawMask | tracks(iDigit).(digitMaskStr);
            
            for iPoint = 1 : 3
                if iDigit > 1 || iPoint == 2
                    ptCoord = round(tracks(iDigit).currentDigitMarkers(:,iPoint,iView));
                    fullPawMask(ptCoord(2),ptCoord(1)) = true;
                end
            end
        end
        fullPawMask = multiRegionConvexHullMask(fullPawMask);
        tracks(num_elements_to_track-1).(digitMaskStr) = fullPawMask;
        
        if iView < 3
            s_paw = regionprops(fullPawMask,'centroid');
            tracks(num_elements_to_track-1).currentDigitMarkers(:,2,iView) = s_paw.Centroid';
        end
    end
    tracks(6).prev_markers3D = tracks(6).markers3D;
    tracks(6) = digit3Dpoints(trackingBoxParams, tracks(6), mask_bbox);
    
    % now figure out where the palmar view of the paw was, so that can be
    % used in the next loop iteration.
    fullCenterMask = false(h,w);fullMirrorMask = false(h,w);
    fullCenterMask(mask_bbox(1,2) : mask_bbox(1,2) + mask_bbox(1,4),...
                   mask_bbox(1,1) : mask_bbox(1,1) + mask_bbox(1,3)) = tracks(num_elements_to_track-1).digitmask1;
    fullMirrorMask(mask_bbox(3,2) : mask_bbox(3,2) + mask_bbox(3,4),...
                   mask_bbox(3,1) : mask_bbox(3,1) + mask_bbox(3,3)) = current_BG_mask{3};
	projMask = pawProjectionMask(fullCenterMask, fundMat(:,:,2), [h,w]);
    fullMirrorMask = fullMirrorMask & projMask;
    tracks(num_elements_to_track-1).digitmask3 = ...
        fullMirrorMask(mask_bbox(3,2) : mask_bbox(3,2) + mask_bbox(3,4),...
                       mask_bbox(3,1) : mask_bbox(3,1) + mask_bbox(3,3));
                   
	% do the same for the paw dorsum view
    fullMirrorMask(mask_bbox(2,2) : mask_bbox(2,2) + mask_bbox(2,4),...
                   mask_bbox(2,1) : mask_bbox(2,1) + mask_bbox(2,3)) = tracks(num_elements_to_track-1).digitmask2;
	projMask = pawProjectionMask(fullCenterMask, fundMat(:,:,1), [h,w]);
    fullMirrorMask = fullMirrorMask & projMask;
    tracks(num_elements_to_track-1).digitmask2 = ...
        fullMirrorMask(mask_bbox(2,2) : mask_bbox(2,2) + mask_bbox(2,4),...
                       mask_bbox(2,1) : mask_bbox(2,1) + mask_bbox(2,3));
    
	% now establish all 3d points that are available from visible points in
	% both views
    for iTrack = 1 : length(tracks)
        if iTrack < 6
            digitTrajectories(numFrames,iTrack,:,:) = tracks(iTrack).markers3D;
            tracks(iTrack).markersCalculated = false(1,2);
            tracks(iTrack).previousDigitMarkers = tracks(iTrack).currentDigitMarkers;
            tracks(iTrack).prev_markers3D = tracks(iTrack).markers3D;
        end
        tracks(iTrack).age = tracks(iTrack).age + 1;
    end
    pawTrajectory(numFrames,:) = tracks(6).markers3D(2,:);
    currentDigitMask = cell(1,2);
    digitBlobCentroids = zeros(1,2,1,2);
    for iView = 1 : 2

        currentDigitMask{iView} = false(h,w);
        for ii = 2 : 5
            digitMask = eval(sprintf('tracks(ii).digitmask%d', iView));
            tempMask = false(h,w);
            tempMask(mask_bbox(iView,2):mask_bbox(iView,2) + mask_bbox(iView,4), ...
                     mask_bbox(iView,1):mask_bbox(iView,1) + mask_bbox(iView,3)) = digitMask;
            currentDigitMask{iView} = currentDigitMask{iView} | tempMask;
        end
        currentDigitMask{iView} = multiRegionConvexHullMask(currentDigitMask{iView});
        s_meanDigits = regionprops(currentDigitMask{iView},'centroid');
        digitBlobCentroids(1,:,1,iView) = s_meanDigits.Centroid;
    end

    meanDigitTrajectory(numFrames,:) = currentDigitMarkersTo3D(digitBlobCentroids, trackingBoxParams, mask_bbox);
    plotTracks(tracks, image_ud, mask_bbox,[d_frontPanel_x;d_frontPanel_y])
    
end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pdMask = thresholdDorsum(meanHSV, ...
                                  stdHSV, ...
                                  HSVthresh_parameters, ...
                                  hsv, ...
                                  currentDigitMarkers, ...    % might use this to verify whether we have the full paw dorsum
                                  dorsumRegionMask, ...
                                  pdBlob, ...
                                  trackingBoxParams, ...
                                  mask_bbox)
%
% INPUTS:
%   meanHSV - 3 element vector with mean hue, saturation, and value values,
%       respectively for the target region
%   stdHSV - 3 element vector with standard deviation of the hue, 
%       saturation, and value values, respectively for the target region
%   HSVthresh_parameters - structure with the following fields:
%       .min_thresh - 3 element vector containing mininum distance h/s/v
%           thresholds must be from their respective means
%       .num_stds - 3 element vector containing number of standard
%           deviations away from the mean h/s/v values to set threshold.
%           The threshold is set as whichever is further from the mean -
%           min_thresh or num_stds * std
%   hsv - 2-element cell array containing the enhanced hsv image of the paw
%       within the bounding box for the direct view (index 1) and mirror
%       view (index 2)
%   currentDigitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)
%   dorsumRegionMask - cell array containing masks for where the paw dorsum
%       can be with respect to the digits (index 1 id direct view, index 2
%       is mirror view)
%   pdBlob - cell array of blob objects containing blob parameters for
%       the direct view (index 1) and mirror view (index 2)
%
% OUTPUTS:
%   pdMask - 1 x 2 cell array containing the mask for the direct
%       (center) and mirror views, respectively


                        
    min_thresh = HSVthresh_parameters.min_thresh;
    max_thresh = HSVthresh_parameters.max_thresh;
    num_stds   = HSVthresh_parameters.num_stds;
    
    HSVlimits = zeros(2,6);
    pdMask = cell(1,2);
    
    currentMask = cell(1,2);

    for iView = 2 : -1 : 1   % easier to start with the mirror view
        
        currentMask{iView} = false(size(hsv{iView},1),size(hsv{iView},2));
        
        % construct HSV limits vector from track, HSVthresh_parameters
        % construct HSV limits vector from track, HSVthresh_parameters
        HSVlimits(iView,1) = meanHSV(iView,1);            % hue mean
        HSVlimits(iView,2) = max(min_thresh(1), stdHSV(iView,1) * num_stds(1));  % hue range
        HSVlimits(iView,2) = min(max_thresh(1), HSVlimits(iView,2));  % hue range

        s_range = max(min_thresh(2), stdHSV(iView,2) * num_stds(2));
        s_range = min(max_thresh(2), s_range);
        HSVlimits(iView,3) = max(0.001, meanHSV(iView,2) - s_range);    % saturation lower bound
        HSVlimits(iView,4) = min(1.000, meanHSV(iView,2) + s_range);    % saturation upper bound

%         v_range = max(min_thresh(3), stdHSV(iView,3) * num_stds(3));
%         v_range = min(max_thresh(3), v_range);
%         HSVlimits(iView,5) = max(0.001, meanHSV(iView,3) - v_range);    % value lower bound
%         HSVlimits(iView,6) = min(1.000, meanHSV(iView,3) + v_range);    % value upper bound  
        HSVlimits(iView,5:6) = [0.001 1.00];   % don't theshold on value for the paw dorsum
        
        
        % threshold the image
        tempMask = HSVthreshold(squeeze(hsv{iView}), ...
                                HSVlimits(iView,:));

        if ~any(tempMask(:)); continue; end

        SE = strel('disk',2);
        tempMask = imopen(tempMask, SE);
        tempMask = imclose(tempMask, SE);
        tempMask = imfill(tempMask, 'holes');

        tempMask = tempMask & dorsumRegionMask{iView};
        if iView == 1
            tempMask = tempMask & projMask;
        end
        
        [A,~,~,~,labMat] = step(pdBlob{iView}, tempMask);
        % take at most the numSameColorObjects largest blobs
        [~,idx] = sort(A, 'descend');
        if ~isempty(idx)
            tempMask = (labMat == idx(1));
        end
        
        % use the convex hull of the current mask, but make sure it doesn't
        % overlap with the digits
        tempMask = tempMask & dorsumRegionMask{iView};
        [tempMask,~] = multiRegionConvexHullMask(tempMask);
        
        if iView == 2
            % calculate projection into the direct view
            projMask = calcProjMask(tempMask, ...
                                    trackingBoxParams.F(:,:,1)', ...
                                    mask_bbox(2,:), ...
                                    trackingBoxParams.imSize);
            projMask = projMask(mask_bbox(1,2) : mask_bbox(1,2) + mask_bbox(1,4), ...
                                          mask_bbox(1,1) : mask_bbox(1,1) + mask_bbox(1,3));
        end
        % CHECK TO SEE THAT THE IDENTIFIED DORSUM REGIONS OVERLAP WELL?
        
        pdMask{iView} = tempMask;
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTracks = assign_prelim_blobs_to_tracks(colorTracks, ...
                                                   prelimMask, ...
                                                   mask_bbox, ...
                                                   prev_bbox, ...
                                                   trackingBoxParams, ...
                                                   trackCheck, ...
                                                   nextPoints)
%
% INPUTS:
%   colorTracks - cell array containing 
%   prelimMask - m x 2 cell array, where m is the number of digits with the
%       same coloring (should be one or two), and the second index is the
%       direct view (index 1) or mirror view (index 2)
%   prev_mask_bbox - 2 x 4 array, 1st row is bounding box for the direct
%       view, second row is for the mirror view
%   mask_bbox - 
%   trackingBoxParams - 
%   trackCheck -
%
% OUTPUTS:
%

% first, check 3D reconstructions of prelimMask in mirror and center views;
% is there a large reprojection error? If more than one blob in each view,
% which combo has the smallest reprojection errors?

if length(colorTracks) == 1
    % only one color to deal with
    newTracks = checkSingleTrack(colorTracks, ...
                                 prelimMask, ...
                                 mask_bbox, ...
                                 prev_bbox, ...
                                 trackingBoxParams, ...
                                 trackCheck);
else
    newTracks = checkTwoTracks(colorTracks, ...
                               prelimMask, ...
                               mask_bbox, ...
                               prev_bbox, ...
                               trackingBoxParams, ...
                               trackCheck, ...
                               nextPoints);
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTrack = selectValidView(prevTrack, ...
                                    new_centroids, ...
                                    prev_bbox, ...
                                    prelimMask, ...
                                    trackCheck)

newTrack = prevTrack;

validViews = true(1,2);

prev_centroids = zeros(2,2);
for iView = 1 : 2
    prev_centroids(iView,:) = prevTrack.currentDigitMarkers(:,2,iView)' +...
                              prev_bbox(iView,1:2) - 1;
end

temp = prev_centroids - new_centroids;
for iView = 1 : 2
    centroid_diffs_across_frames = norm(temp(iView,:));
    maskLabel = sprintf('digitmask%d',iView);
    if centroid_diffs_across_frames > trackCheck.maxPixelsPerFrame
        validViews(iView) = false;
        newTrack.(maskLabel) = false(size(prelimMask{iView}));
    else
        newTrack.(maskLabel) = prelimMask{iView};
    end
end

validViewIdx = find(validViews);
invalidViewIdx = find(~validViews);

newTrack.isvisible(1:2) = validViews;
newTrack.consecutiveInvisibleCount(validViewIdx) = 0;
newTrack.consecutiveInvisibleCount(invalidViewIdx) = ...
    newTrack.consecutiveInvisibleCount(invalidViewIdx) + 1;

newTrack.totalVisibleCount(validViewIdx) = ...
    newTrack.totalVisibleCount(validViewIdx) + 1;

end    % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTrack = checkSingleTrack(prevTrack, ...
                                     prelimMask, ...
                                     mask_bbox, ...
                                     prev_bbox, ...
                                     trackingBoxParams, ...
                                     trackCheck)

	newTrack = prevTrack;

    % several possibilities: a blob is visible in both views, a blob is
    % visible in one view but not the other, blob isn't visible in either view
    if any(prelimMask{1,1}(:)) && any(prelimMask{1,2}(:))
        % blob visible in both views
        
        new_centroids = zeros(2,2);
        % triangulate the centroids of the direct and mirror view blobs
        s_direct = regionprops(prelimMask{1,1},'Centroid');
        s_mirror = regionprops(prelimMask{1,2},'Centroid');

        new_centroids(1,:) = s_direct.Centroid + mask_bbox(1,1:2) - 1;
        new_centroids(2,:) = s_mirror.Centroid + mask_bbox(2,1:2) - 1;
        
        % do these centroids lie on the same epipolar line?
        epiLine = epipolarLine(trackingBoxParams.F(:,:,1), new_centroids(1,:));
        epiPts  = lineToBorderPoints(epiLine, trackingBoxParams.imSize);
        distanceToEpiLine = distanceToLine(epiPts(1:2),epiPts(3:4),new_centroids(2,:));
        
        if distanceToEpiLine > trackCheck.maxEpiLineDist
            newTrack = selectValidView(newTrack, ...
                                       new_centroids, ...
                                       prev_bbox, ...
                                       prelimMask, ...
                                       trackCheck);
            return;
        end

        new_centroids_norm = normalize_points(new_centroids, trackingBoxParams.K);
        [points3d,~,reprojErrors] = triangulate_DL(new_centroids_norm(1,:), ...
                                                new_centroids_norm(2,:), ...
                                                trackingBoxParams.P1, ...
                                                trackingBoxParams.P2); 
        % calculate mean reprojection error
        meanReprojError = mean(sqrt(sum(reprojErrors.^2,2)));
        points3d = points3d * trackingBoxParams.scale;

        % distance from previous point
        d3d = norm(points3d - prevTrack.markers3D(2,:));
        
        % if reprojection errors and/or 3-d distance don't make sense, is
        % one of the blobs off? Is the other OK, or are both mistakes? If
        % so, how do we estimate current 3D point?
        if d3d > trackCheck.maxDistPerFrame || ...
           meanReprojError > trackCheck.maxReprojError
            % WORKING HERE... NOW NEED TO DETERMINE IF REPROJECTION ERRORS ARE
            % SMALL ENOUGH AND CURRENT 3D POINT IS CLOSE ENOUGH TO THE PREVIOUS
            % POINT TO ACCEPT IT. IF SO, UPDATE NEW TRACK WITH THE NEW MASK. IF
            % NOT, DECIDE THAT THIS DIGIT IS NOT VISIBLE IN AT LEAST ONE OF THE
            % VIEWS; THEN NEED TO DECIDE IF ONE OF THE VIEWS IS VALID. 
            newTrack = selectValidView(newTrack, ...
                                       new_centroids, ...
                                       prev_bbox, ...
                                       prelimMask, ...
                                       trackCheck);
            return;
        else
            newTrack.markers3D(2,:) = points3d;
            newTrack.isvisible = [true,true,false];
            newTrack.totalVisibleCount(1:2) = newTrack.totalVisibleCount(1:2) + 1;
            newTrack.consecutiveInvisibleCount = [0 0];
        end
    else    % blob not visible in at least one of the views
        for iView = 1 : 2
            if any(prelimMask{1,iView}(:))
                newTrack.isvisible(iView) = true;
                newTrack.totalVisibleCount(iView) = newTrack.totalVisibleCount(iView) + 1;
                newTrack.consecutiveInvisibleCount(iView) = 0;
            else
                newTrack.isvisible(iView) = false;
                newTrack.consecutiveInvisibleCount(iView) = newTrack.consecutiveInvisibleCount(iView) + 1;
            end
        end
    end
    
    newTrack.prevmask1 = newTrack.digitmask1;
    newTrack.prevmask2 = newTrack.digitmask2;
    newTrack.digitmask1 = prelimMask{1,1};
    newTrack.digitmask2 = prelimMask{1,2};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTracks = checkTwoTracks(prevTracks, ...
                                    prelimMask, ...
                                    mask_bbox, ...
                                    prev_bbox, ...
                                    trackingBoxParams, ...
                                    trackCheck, ...
                                    nextPoints)

% INPUTS:
%   prevTracks - track structures for the two tracks that are the same
%       color
%   prelimMask - m x 2 cell array, where m is the number of digits with the
%       same coloring (should be one or two), and the second index is the
%       direct view (index 1) or mirror view (index 2)\
%   mask_bbox - 
%	trackingBoxParams - 
	newTracks = prevTracks;
    
    % several possibilities: two blobs visible in both views; one blob
    % visible in one view, two blobs in the other; none in one view, two in
    % the other, etc.
    
    % figure out how many blobs in each view
    numBlobs = zeros(2,2);
    s = cell(2,2);
    for iTrack = 1 : 2
        for iView = 1 : 2
            s{iTrack,iView} = regionprops(prelimMask{iTrack,iView},'area','centroid');
            numBlobs(iTrack,iView) = length(s{iTrack,iView});
%             digLabelMask{iTrack,iView} = bwlabel(prelimMask{iTrack,iView});
        end
        if all(numBlobs(iTrack,:) == 2)
            newTracks = matchTwoBlobs(newTracks, ...
                                      prelimMask, ...
                                      mask_bbox, ...
                                      trackingBoxParams, ...
                                      trackCheck, ...
                                      iTrack);
            % two blobs visible in each view
        elseif all(numBlobs(iTrack,:) == 1)
            % one blob seen in both views
            newTracks = matchSingleBlobs(newTracks, ...
                                         prelimMask, ...
                                         mask_bbox, ...
                                         prev_bbox, ...
                                         trackingBoxParams, ...
                                         trackCheck, ...
                                         iTrack);
        elseif sum(numBlobs(iTrack,:)) == 3
            newTracks = matchSingleToTwoBlobs(newTracks, ...
                                              prelimMask, ...
                                              mask_bbox, ...
                                              trackingBoxParams, ...
                                              trackCheck, ...
                                              iTrack, ...
                                              nextPoints);
        elseif sum(numBlobs(iTrack,:)) == 1    % only one of 4 possible blobs is visible
            newTracks = assignSingleBlob(newTracks, ...     
                                         prelimMask, ...
                                         mask_bbox, ...
                                         trackingBoxParams, ...
                                         trackCheck, ...
                                         iTrack, ...
                                         nextPoints);
        else   % no blobs are visible
            newTracks(iTrack).digitmask1 = false(mask_bbox(1,4:-1:3) + 1);
            newTracks(iTrack).digitmask2 = false(mask_bbox(2,4:-1:3) + 1);
            newTracks(iTrack).isvisible = false(1,3);
            newTracks(iTrack).consecutiveInvisibleCount(1:2) = ...
                newTracks(iTrack).consecutiveInvisibleCount(1:2) + 1;
        end

    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTracks = matchTwoBlobs(prevTracks, ...
                                   prelimMask, ...
                                   mask_bbox, ...
                                   trackingBoxParams, ...
                                   trackCheck, ...
                                   iTrack)

newTracks = prevTracks;
prev_3dpoints = zeros(2,3);
prev_3dpoints(1,:) = prevTracks(1).markers3D(2,:);
prev_3dpoints(2,:) = prevTracks(2).markers3D(2,:);
            
% figure out how many blobs in each view
numBlobs = zeros(2,2);
s = cell(2,2);
digLabelMask = cell(2,2);

for iView = 1 : 2
    s{iTrack,iView} = regionprops(prelimMask{iTrack,iView},'area','centroid');
    numBlobs(iTrack,iView) = length(s{iTrack,iView});
    digLabelMask{iTrack,iView} = bwlabel(prelimMask{iTrack,iView});
end
        
new_centroids = zeros(2,2,2);

for iView = 1 : 2
    for iBlob = 1 : 2
        new_centroids(iView,iBlob,:) = s{iTrack,iView}(iBlob).Centroid + mask_bbox(iView,1:2) - 1;
    end
end
            
% find intersections of lines connecting centroids of the blobs
% in the direct and mirror views
% for blobs that are correctly paired, they should interect at
% the epipole because of the planar mirror geometry
test_epipoles = zeros(2,2);
epi_error = zeros(2,2);
m = zeros(2,2);
b = zeros(2,2);

for iBlob = 1 : 2
    % match blob 1 in direct view with blob 1 in the mirror view
    Q(1,:) = new_centroids(1,iBlob,:);
    Q(2,:) = new_centroids(2,iBlob,:);
    
    [epi_error(1,iBlob),~] = findNearestPointToLine(Q, trackingBoxParams.epipole(1,:));
    
    % match blob 1 in direct view with blob 2 in the mirror view (and
    % vice-versa)
    Q(1,:) = new_centroids(1,iBlob,:);
    Q(2,:) = new_centroids(2,3-iBlob,:);
    
    [epi_error(2,iBlob),~] = findNearestPointToLine(Q, trackingBoxParams.epipole(1,:));
end
epi_error = mean(epi_error,2);

% figure out which "test" epipole is closest to the real
% epipole
direct_view_pts = squeeze(new_centroids(1,:,:));
if epi_error(1) < epi_error(2)    % indices of blobs in the two views match up
    mirror_view_pts = squeeze(new_centroids(2,:,:));
else    % indices of blobs in the two views don't match up
    mirror_view_pts = squeeze(new_centroids(2,2:-1:1,:));
end
            
direct_view_pts_norm = normalize_points(direct_view_pts, trackingBoxParams.K);
mirror_view_pts_norm = normalize_points(mirror_view_pts, trackingBoxParams.K);
[points3d,~,reprojErrors] = triangulate_DL(direct_view_pts_norm, ...
                                           mirror_view_pts_norm, ...
                                           trackingBoxParams.P1, ...
                                           trackingBoxParams.P2);
points3d = points3d * trackingBoxParams.scale;

% now need to assign one of these points to the current digit.
% To do this, find the distance between both 3d points and each
% of the previous digit 3d locations. Then pick the assignments
% that minimize the maximum distance between the current points
% and the previous points.
% does direct view centroid 1 correspond to previous 3d
% centroid from first or second track?
poss_3d_diffs = zeros(4,3);
maxDist = zeros(1,2);
poss_3d_diffs(1:2,:) = bsxfun(@minus,prev_3dpoints,points3d(1,:));
poss_3d_diffs(3:4,:) = bsxfun(@minus,prev_3dpoints,points3d(2,:));
poss_distances = sqrt(sum(poss_3d_diffs.^2,2));
% poss_distances is a 4 x 1 vector. The first and fourth
% entries go together, as do the 2nd and third
maxDist(1) = max(poss_distances([1,4]));
maxDist(2) = max(poss_distances(2:3));
   
if maxDist(1) < maxDist(2)
    % first center view blob corresponds with 1st track
    centerMask = (digLabelMask{iTrack,1} == iTrack);
    if epi_error(1) < epi_error(2)
        mirrorMask = (digLabelMask{iTrack,2} == iTrack);
    else
        mirrorMask = (digLabelMask{iTrack,2} == (3-iTrack));
    end
    curr_3dpoint = points3d(iTrack,:);
else
    centerMask = (digLabelMask{iTrack,1} == (3-iTrack));
    if epi_error(1) < epi_error(2)
        mirrorMask = (digLabelMask{iTrack,2} == (3-iTrack));
    else
        mirrorMask = (digLabelMask{iTrack,2} == iTrack);
    end
    curr_3dpoint = points3d((3-iTrack),:);
    curr_reproj_error = reprojErrors((3-iTrack),:);
end
meanReprojError = mean(sqrt(sum(reprojErrors.^2,2)));
d3d = norm(curr_3dpoint - prev_3dpoints(iTrack,:));

if d3d > trackCheck.maxDistPerFrame || ...
   meanReprojError > trackCheck.maxReprojError

end

newTrack.prevmask1 = newTrack.digitmask1;
newTrack.prevmask2 = newTrack.digitmask2;

newTracks(iTrack).digitmask1 = centerMask;
newTracks(iTrack).digitmask2 = mirrorMask;
newTracks(iTrack).markers3D(2,:) = curr_3dpoint;
newTracks(iTrack).isvisible = [true,true,false];
newTracks(iTrack).totalVisibleCount(1:2) = newTracks(iTrack).totalVisibleCount(1:2) + 1;
newTracks(iTrack).consecutiveInvisibleCount = [0 0];

            
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTracks = matchSingleToTwoBlobs(prevTracks, ...
                                           prelimMask, ...
                                           mask_bbox, ...
                                           trackingBoxParams, ...
                                           trackCheck, ...
                                           iTrack, ...
                                           nextPoints)
newTracks = prevTracks;
            
% figure out how many blobs in each view
numBlobs = zeros(2,2);
s = cell(2,2);

for iView = 1 : 2
    s{iTrack,iView} = regionprops(prelimMask{iTrack,iView},'area','centroid');
    numBlobs(iTrack,iView) = length(s{iTrack,iView});
%     digLabelMask{iTrack,iView} = bwlabel(prelimMask{iTrack,iView});
end
        
new_centroids = zeros(2,2,2);

for iView = 1 : 2
    for iBlob = 1 : numBlobs(iTrack,iView)
        new_centroids(iView,iBlob,:) = s{iTrack,iView}(iBlob).Centroid + mask_bbox(iView,1:2) - 1;
    end
end
            
% find intersections of lines connecting centroids of the blobs
% in the direct and mirror views
% for blobs that are correctly paired, they should interect at
% the epipole because of the planar mirror geometry

% figure out which line connecting the mirror and center (blob(s)) passes
% closest to the epipole
epi_error = zeros(1,2);
Q = zeros(2,2);
for iBlob = 1 : 2
    if numBlobs(iTrack,1) == 1    % one blob in the center view
        Q(1,:) = new_centroids(1,1,:);
        Q(2,:) = new_centroids(2,iBlob,:);
    else    % one blob in the mirror view
        Q(1,:) = new_centroids(2,1,:);
        Q(2,:) = new_centroids(1,iBlob,:);
    end
    
    [epi_error(iBlob),~] = findNearestPointToLine(Q, trackingBoxParams.epipole(1,:));
end

minErrorIdx = find(epi_error == min(epi_error));
% figure out which blob in the 2-blob image matches with the one blob in
% the other image
if numBlobs(iTrack,1) == 1
    direct_view_pts = squeeze(new_centroids(1,1,:))';
    mirror_view_pts = squeeze(new_centroids(2,minErrorIdx,:))';
    other_track_pts = squeeze(new_centroids(2,3-minErrorIdx,:))';
else
    direct_view_pts = squeeze(new_centroids(1,minErrorIdx,:))';
    mirror_view_pts = squeeze(new_centroids(2,1,:))';
    other_track_pts = squeeze(new_centroids(1,3-minErrorIdx,:))';
end
            
direct_view_pts_norm = normalize_points(direct_view_pts, trackingBoxParams.K);
mirror_view_pts_norm = normalize_points(mirror_view_pts, trackingBoxParams.K);
[points3d,~,reprojErrors] = triangulate_DL(direct_view_pts_norm, ...
                                           mirror_view_pts_norm, ...
                                           trackingBoxParams.P1, ...
                                           trackingBoxParams.P2);
points3d = points3d * trackingBoxParams.scale;

meanReprojError = mean(sqrt(sum(reprojErrors.^2,2)));
d3d = norm(points3d - squeeze(nextPoints(iTrack,2,:))');

% now need to assign this point to either the current digit or the other
% digit of the same color.
% To do this, find the distance between both 3d points and each
% of the previous digit 3d locations. Then pick the assignments
% that minimize the maximum distance between the current points
% and the previous points.
% does direct view centroid 1 correspond to previous 3d
% centroid from first or second track?
poss_3d_diffs = zeros(2,3);
for iDigit = 1 : 2
    poss_3d_diffs(iDigit,:) = squeeze(nextPoints(iDigit,2,:))' - points3d;
end
poss_distances = sqrt(sum(poss_3d_diffs.^2,2));
min_dist_idx = find(poss_distances == min(poss_distances));
% poss_distances is a 2 x 1 vector. Is the triangulated point closer to the
% current digit or the other digit of the same color?

centerMarker = false(size(prelimMask{iTrack,1}));
mirrorMarker = false(size(prelimMask{iTrack,2}));
if min_dist_idx == iTrack
    % the matched points correspond to the current track
    mirrorTruePt = round(mirror_view_pts) - mask_bbox(2,1:2) + 1;
    centerTruePt = round(direct_view_pts) - mask_bbox(1,1:2) + 1;
    centerMarker(centerTruePt(2),centerTruePt(1)) = true;
    mirrorMarker(mirrorTruePt(2),mirrorTruePt(1)) = true;
    
    centerMask = imreconstruct(centerMarker, prelimMask{iTrack,1});
    mirrorMask = imreconstruct(mirrorMarker, prelimMask{iTrack,2});
    
    newTracks(iTrack).markers3D(2,:) = points3d;    % centroid 3d point
    newTracks(iTrack).isvisible = [true,true,false];
    newTracks(iTrack).totalVisibleCount(1:2) = newTracks(iTrack).totalVisibleCount(1:2) + 1;
    newTracks(iTrack).consecutiveInvisibleCount = [0 0];
    
    if d3d > trackCheck.maxDistPerFrame || ...
       meanReprojError > trackCheck.maxReprojError
    end
else
    % the matched points correspond to the "other" track
    if numBlobs(iTrack,1) == 1
        centerMask = centerMarker;
        mirrorTruePt = round(other_track_pts) - mask_bbox(2,1:2) + 1;
        mirrorMarker(mirrorTruePt(2),mirrorTruePt(1)) = true;
        mirrorMask = imreconstruct(mirrorMarker, prelimMask{iTrack,2});
        newTracks(iTrack).isvisible = [false,true,false];
        newTracks(iTrack).totalVisibleCount(2) = newTracks(iTrack).totalVisibleCount(2) + 1;
        newTracks(iTrack).consecutiveInvisibleCount(1) = ...
            newTracks(iTrack).consecutiveInvisibleCount(1) + 1;
        newTracks(iTrack).consecutiveInvisibleCount(2) = 0;
    else
        mirrorMask = mirrorMarker;
        centerTruePt = round(other_track_pts) - mask_bbox(1,1:2) + 1;
        centerMarker(centerTruePt(2),centerTruePt(1)) = true;
        centerMask = imreconstruct(centerMarker, prelimMask{iTrack,1});
        newTracks(iTrack).isvisible = [true,false,false];
        newTracks(iTrack).totalVisibleCount(1) = newTracks(iTrack).totalVisibleCount(1) + 1;
        newTracks(iTrack).consecutiveInvisibleCount(2) = ...
            newTracks(iTrack).consecutiveInvisibleCount(2) + 1;
        newTracks(iTrack).consecutiveInvisibleCount(1) = 0;
    end
    newTracks(iTrack).markers3D(2,:) = zeros(1,3);    % centroid 3d point
end

newTracks(iTrack).prevmask1 = newTracks(iTrack).digitmask1;
newTracks(iTrack).prevmask2 = newTracks(iTrack).digitmask2;

newTracks(iTrack).digitmask1 = centerMask;
newTracks(iTrack).digitmask2 = mirrorMask;

end    % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTracks = matchSingleBlobs(prevTracks, ...
                                      prelimMask, ...
                                      mask_bbox, ...
                                      prev_bbox, ...
                                      trackingBoxParams, ...
                                      trackCheck, ...
                                      iTrack)
newTracks = prevTracks;
            
% figure out how many blobs in each view
numBlobs = zeros(2,2);
s = cell(1,2);
numPossTracks = length(prevTracks);

for iView = 1 : 2
    s{iTrack,iView} = regionprops(prelimMask{iTrack,iView},'area','centroid');
    numBlobs(iTrack,iView) = length(s{iTrack,iView});
%     digLabelMask{iTrack,iView} = bwlabel(prelimMask{iTrack,iView});
end
        
new_centroids = zeros(2,2);
prev_centroids = zeros(numPossTracks,2,2);

for iView = 1 : 2
    new_centroids(iView,:) = s{iTrack,iView}.Centroid + mask_bbox(iView,1:2) - 1;
    for iDigit = 1 : numPossTracks
        prev_centroids(iDigit,iView,:) = prevTracks(iDigit).previousDigitMarkers(:,2,iView)' + ...
                                         prev_bbox(iView,1:2) - 1;
    end
end

% need to figure out if the two blobs correspond to each other
% this will be true if the epipolar line passes very close to both points

% calculate distance between the centroid in the mirror view and the
% epipolar line of the centroid in the direct view
epiDist = distanceToLine(new_centroids(1,:),trackingBoxParams.epipole(1,:),new_centroids(2,:));
if epiDist < trackCheck.maxEpiLineDist
    % the epipolar line matches between the two points
    % now, need to check if these points are likely to correspond to the
    % current track or the "other" track
    distFromTracks = zeros(1,numPossTracks);
    for iDigit = 1 : numPossTracks
        for iView = 1 : 2
            trackDiff = new_centroids(iView,:) - squeeze(prev_centroids(iDigit,iView,:))';
            distFromTracks(iDigit) = sqrt(sum(trackDiff.^2));
        end
    end
    
    if iTrack == find(distFromTracks == min(distFromTracks))
        % the blobs correspond to the current track
        newTracks(iTrack).digitmask1 = prelimMask{iTrack,1};
        newTracks(iTrack).digitmask2 = prelimMask{iTrack,2};
        
        newTracks(iTrack).isvisible = [true,true,false];
        newTracks(iTrack).totalVisibleCount(1:2) = newTracks(iTrack).totalVisibleCount(1:2) + 1;
        newTracks(iTrack).consecutiveInvisibleCount(1:2) = zeros(1,2);
        
        direct_view_pts = squeeze(new_centroids(1,:));
        mirror_view_pts = squeeze(new_centroids(2,:));

        direct_view_pts_norm = normalize_points(direct_view_pts, trackingBoxParams.K);
        mirror_view_pts_norm = normalize_points(mirror_view_pts, trackingBoxParams.K);
        [points3d,~,~] = triangulate_DL(direct_view_pts_norm, ...
                                        mirror_view_pts_norm, ...
                                        trackingBoxParams.P1, ...
                                        trackingBoxParams.P2);
        points3d = points3d * trackingBoxParams.scale;
        
        newTracks(iTrack).markers3D(2,:) = points3d;    % centroid 3d point
    else
        % the blobs do not correspond to the current track
        newTracks(iTrack).digitmask1 = false(size(prelimMask{iTrack,1}));
        newTracks(iTrack).digitmask2 = false(size(prelimMask{iTrack,2}));
        
        newTracks(iTrack).isvisible = [false,false,false];
        newTracks(iTrack).consecutiveInvisibleCount(1:2) = ...
            newTracks(iTrack).consecutiveInvisibleCount(1:2) + 1;
        
        newTracks(iTrack).markers3D(2,:) = zeros(1,3);
    end
else
    % the two blobs probably don't correspond to each other; which one (if
    % any) corresponds to the current track?
    
    % calculate distance from previous tracks to the current centroids in
    % each view
    distFromTracks = zeros(1,2);
    for iView = 1 : 2
        for iDigit = 1 : numPossTracks
            trackDiff = new_centroids(iView,:) - squeeze(prev_centroids(iDigit,iView,:))';
            distFromTracks(iDigit) = sqrt(sum(trackDiff.^2));
        end
        digMaskString = sprintf('digitmask%d',iView);
        prevMaskString = sprintf('prevmask%d',iView);
        newTracks(iTrack).(prevMaskString) = newTracks(iTrack).(digMaskString);
        if find(distFromTracks == min(distFromTracks)) == iTrack && ...
                min(distFromTracks) < trackCheck.maxPixelsPerFrame
            newTracks(iTrack).(digMaskString) = prelimMask{iTrack,iView};
            newTracks(iTrack).isvisible(iView) = true;
            newTracks(iTrack).consecutiveInvisibleCount(iView) = 0;
            newTracks(iTrack).totalVisibleCount(iView) = ...
                newTracks(iTrack).totalVisibleCount(iView) + 1;
        else
            newTracks(iTrack).(digMaskString) = false(size(prelimMask{iTrack,iView}));
            newTracks(iTrack).isvisible(iView) = false;
            newTracks(iTrack).consecutiveInvisibleCount(iView) = ...
                newTracks(iTrack).consecutiveInvisibleCount(iView) + 1;
        end
    end

end

end    % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                   
function newTracks = assignSingleBlob(prevTracks, ...       % WORKING HERE...
                                      prelimMask, ...
                                      mask_bbox, ...
                                      trackingBoxParams, ...
                                      trackCheck, ...
                                      iTrack, ...
                                      nextPoints)
newTracks = prevTracks;
numPossTracks = length(prevTracks);

for iView = 1 : 2
    s = regionprops(prelimMask{iTrack,iView},'area','centroid');

    if ~isempty(s)    % the blob is present in this view for this track

        viewMaskString = sprintf('digitmask%d',iView);
        notViewMaskString = sprintf('digitmask%d',3-iView);

        % project nextPoints into the current view
        cameraMatrixString = sprintf('P%d',iView);
        nextPoints_hom = [squeeze(nextPoints(:,2,:)), ones(numPossTracks,1)];
        projected_pts_norm = nextPoints_hom * trackingBoxParams.(cameraMatrixString);
        projected_pts_hom  = (trackingBoxParams.K' * projected_pts_norm')';
        projected_pts      = bsxfun(@rdivide,projected_pts_hom(:,1:2),projected_pts_hom(:,3));
        projected_pts      = bsxfun(@minus,projected_pts,mask_bbox(iView,1:2));

        blob_to_projected = bsxfun(@minus,projected_pts, s.Centroid);
        dist_to_blobs = sqrt(sum(blob_to_projected.^2,2));

        nearTrackIdx = find(dist_to_blobs == min(dist_to_blobs));
        newTracks(iTrack).prevmask1 = newTracks(iTrack).digitmask1;
        newTracks(iTrack).prevmask2 = newTracks(iTrack).digitmask2;
        
        if nearTrackIdx == iTrack && dist_to_blobs(nearTrackIdx) < trackCheck.maxPixelsPerFrame
            newTracks(iTrack).(viewMaskString) = prelimMask{iTrack,iView};
            newTracks(iTrack).(notViewMaskString) = false(size(prelimMask{iTrack,3-iView}));
            newTracks(iTrack).isvisible = false(1,3);
            newTracks(iTrack).isvisible(iView) = true;
            newTracks(iTrack).totalVisibleCount(iView) = ...
                newTracks(iTrack).totalVisibleCount(iView) + 1;
            newTracks(iTrack).consecutiveInvisibleCount(iView) = 0;
            newTracks(iTrack).consecutiveInvisibleCount(3-iView) = ...
                newTracks(iTrack).consecutiveInvisibleCount(3-iView) + 1;
        else
            newTracks(iTrack).digitmask1 = false(size(prelimMask{iTrack,1}));
            newTracks(iTrack).digitmask2 = false(size(prelimMask{iTrack,2}));
            newTracks(iTrack).isvisible = false(1,3);
            newTracks(iTrack).consecutiveInvisibleCount(1:2) = ...
                newTracks(iTrack).consecutiveInvisibleCount(1:2) + 1;
        end
    end
end

end    % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

function testPoint = selectDorsumTestPoint(pawPref, iView, currentMask)

% function to find a test point to determine where the dorsum of the paw
% should be with respect to the digits

    if iView == 1    % direct view
        if strcmpi(pawPref,'right')
            testPoint = [1,1];
        else
            testPoint = [1,size(currentMask{iView},2)];
        end
    else    % mirror view
        if strcmpi(pawPref,'right')
            testPoint = round([size(curentMask{iView},1)/2, size(currentMask{iView},2)]);
        else
            testPoint = round([size(curentMask{iView},1)/2, 1]);
        end
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tracks = findDorsumRegion(tracks, ...
                                   paw_img, ...
                                   HSVthresh_parameters, ...
                                   BG_mask, ...
                                   decorrStretchMean, ...
                                   dorsum_decorrStretchSigma, ...
                                   pdBlob, ...
                                   trackingBoxParams, ...
                                   nextPoint, ...
                                   mask_bbox, ...
                                   prev_bbox, ...
                                   pts_transformed, ...
                                   digitsHull, ...
                                   d_frontPanel_x, ...
                                   d_frontPanel_y, ...
                                   dorsumAngle, ...
                                   dorsum_past_frontPanel, ...
                                   raw_threshold)
%
% INPUTS:
%   tracks - the full set of digit tracks, after the digits have been
%       identified for the current frame
%   pawPref - string containing 'left' or 'right'
%   paw_img - 1 x 2 cell array containing the undistorted masked paw image
%       in the direct and mirror views, respectively
%   BG_mask - 
%   trackingBoxParams - 
%
% OUTPUTS:
%   tracks - 
%   currentDigitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)
%   dorsumRegionMask - cell array containing masks for where the paw dorsum
%       can be with respect to the digits (index 1 id direct view, index 2
%       is mirror view)

imSize = trackingBoxParams.imSize;

frontPanelMask = poly2mask(d_frontPanel_x, d_frontPanel_y, imSize(1), imSize(2));
frontMask = frontPanelMask(mask_bbox(2,2):mask_bbox(2,2) + mask_bbox(2,4), ...
                           mask_bbox(2,1):mask_bbox(2,1) + mask_bbox(2,3));

meanHSV = tracks(1).meanHSV;
stdHSV  = tracks(1).stdHSV;

min_thresh = HSVthresh_parameters.dorsum_min_thresh;
max_thresh = HSVthresh_parameters.dorsum_max_thresh;
num_stds   = HSVthresh_parameters.dorsum_num_stds;

HSVlimits = zeros(2,6);

dorsumRegionMask = cell(1,2);
candidateRegion = cell(1,2);

validImageBorderPts = zeros(2,2);

SE = strel('disk',2);
currentDigitMarkers = zeros(5,2,3,2);
for iTrack = 1 : 5
    currentDigitMarkers(iTrack,:,:,:) = tracks(iTrack + 1).currentDigitMarkers;
end

% first, predict where the new dorsum masks should be based on where the
% previous ones were
nextPoint = nextPoint / trackingBoxParams.scale;
nextPoint_hom = [nextPoint, ones(size(nextPoint,1),1)];
projected_nextPoint = zeros(2,2);
prevMask = cell(1,2);
for iView = 1 : 2
    % figure out how much we predict the previous blob to have shifted
    cameraMatrixString = sprintf('P%d',iView);
    projected_point_norm = nextPoint_hom * trackingBoxParams.(cameraMatrixString);
    projected_point_hom = (trackingBoxParams.K' * projected_point_norm')';

    projected_nextPoint(iView,:) = bsxfun(@rdivide,...
                                          projected_point_hom(:,1:2),...
                                          projected_point_hom(:,3));
                                      
	fullPrevMask = false(imSize);
    prevMaskStr = sprintf('digitmask%d',iView);
    
    fullPrevMask(prev_bbox(iView,2):prev_bbox(iView,2) + prev_bbox(iView,4), ...
                 prev_bbox(iView,1):prev_bbox(iView,1) + prev_bbox(iView,3)) = tracks(1).(prevMaskStr);
    
             % THINK ABOUT SETTING UP 4 POINTS IN 3-D SPACE THAT WHEN
             % PROJECTED ONTO EACH VIEW WILL GIVE THE CORNERS OF THE PAW
             % DORSUM. COULD USE THE PROXIMAL POINTS OF THE 1ST AND 4TH
             % DIGITS AS TWO OF THE POINTS, AND FIX THE OTHER TWO POINTS A
             % FIXED DISTANCE BACK?
             
    s_prev = regionprops(fullPrevMask,'centroid');
	projected_shift = round(projected_nextPoint(iView,:) - s_prev.Centroid);
    shifted_bbox_corner = mask_bbox(iView,1:2) - projected_shift;
    
    prevMask{iView} = fullPrevMask(shifted_bbox_corner(2):shifted_bbox_corner(2) + mask_bbox(iView,4), ...
                                   shifted_bbox_corner(1):shifted_bbox_corner(1) + mask_bbox(iView,3));
    projected_nextPoint(iView,:) = projected_nextPoint(iView,:) - mask_bbox(iView,1:2);
end
    
angledRegion = cell(1,2);
for iView = 2 : -1 : 1
    prevMaskStr = sprintf('prevmask%d',iView);
    digMaskStr = sprintf('digitmask%d',iView);
    
    tracks(1).isvisible(iView) = true;   % change to false later if can't find the paw dorsum
    
    firstValidIdx = 1;
    lastValidIdx = 4;

    validImageBorderPts(1,:) = squeeze(currentDigitMarkers(firstValidIdx,:,1,iView));
    validImageBorderPts(2,:) = squeeze(currentDigitMarkers(lastValidIdx,:,1,iView));
    testPt = mean(validImageBorderPts,1);
    lineCoeff = lineCoeffFromPoints(validImageBorderPts);
    
    if iView == 2
        rotationAngle = -dorsumAngle;
    else
        rotationAngle = dorsumAngle;
    end
    angledLine1 = angledLine(lineCoeff, validImageBorderPts(1,:), rotationAngle);
    angledLine2 = angledLine(lineCoeff, validImageBorderPts(2,:), -rotationAngle);
    
    angledPts1 = lineToBorderPoints(angledLine1, mask_bbox(iView,4:-1:3)+1);
    angledPts2 = lineToBorderPoints(angledLine2, mask_bbox(iView,4:-1:3)+1);
    
    angledPts1 = reshape(angledPts1,[2 2])';
    angledPts2 = reshape(angledPts2,[2 2])';
    
    angledRegion1 = segregateImage(angledPts1, testPt, mask_bbox(iView,4:-1:3)+1);
    angledRegion2 = segregateImage(angledPts2, testPt, mask_bbox(iView,4:-1:3)+1);
    
    angledRegion{iView} = angledRegion1 & angledRegion2;
    
%     perpLine1 = perpendicularLine(lineCoeff, validImageBorderPts(1,:));
%     perpLine2 = perpendicularLine(lineCoeff, validImageBorderPts(2,:));
%     
%     perpPts1 = lineToBorderPoints(perpLine1, mask_bbox(iView,4:-1:3)+1);
%     perpPts2 = lineToBorderPoints(perpLine2, mask_bbox(iView,4:-1:3)+1);
%     
%     perpPts1 = reshape(perpPts1,[2 2])';
%     perpPts2 = reshape(perpPts2,[2 2])';
%     
%     perpRegion1 = segregateImage(perpPts1, testPt, mask_bbox(iView,4:-1:3)+1);
%     perpRegion2 = segregateImage(perpPts2, testPt, mask_bbox(iView,4:-1:3)+1);
%     
%     perpRegion = perpRegion1 & perpRegion2;
    




% NEED TO REDO THIS PART - USE PTS_TRANSFORMED AGAIN, MAKE SURE THE POINT
% IS WELL-DEFINED

    dorsumRegionMask{iView} = segregateImage(validImageBorderPts, ...
                                             pts_transformed(3,:,iView), mask_bbox(iView,4:-1:3)+1);
%     dorsumRegionMask{iView} = segregateImage(validImageBorderPts, ...
%                                              projected_nextPoint(iView,:), mask_bbox(iView,4:-1:3)+1);
                                         
                                         
                                         
                                         
                                         
                                         
                                         
                                         
    if isempty(digitsHull{iView})
        digitsHull{iView} = false(size(dorsumRegionMask{iView}));
    end
        
	candidateRegion{iView} = dorsumRegionMask{iView} & ...
                             ~digitsHull{iView} & ...
                             angledRegion{iView};
                         

% 	grayMask = false(mask_bbox(iView,4:-1:3)+1);
%     for iColor = 1 : 3
%         grayMask = grayMask | paw_
    dorsumRegionMask{iView} = candidateRegion{iView} & ...
                              BG_mask{iView};
%     if iView == 1
%         if exist('projMask','var')
%             dorsumRegionMask{iView} = dorsumRegionMask{iView} & projMask;
%         end
%     end

    if ~any(dorsumRegionMask{iView}(:))
        tracks(1).isvisible(iView) = false;
        
        tracks(1).(prevMaskStr) = tracks(1).(digMaskStr);
        tracks(1).(digMaskStr) = prevMask{iView} & ~digitsHull{iView};
    else

        HSVlimits(iView,1) = meanHSV(iView,1);            % hue mean
        HSVlimits(iView,2) = max(min_thresh(1), stdHSV(iView,1) * num_stds(1));  % hue range
        HSVlimits(iView,2) = min(max_thresh(1), HSVlimits(iView,2));  % hue range

        s_range = max(min_thresh(2), stdHSV(iView,2) * num_stds(2));
        s_range = min(max_thresh(2), s_range);
        HSVlimits(iView,3) = max(0.001, meanHSV(iView,2) - s_range);    % saturation lower bound
        HSVlimits(iView,4) = min(1.000, meanHSV(iView,2) + s_range);    % saturation upper bound

        v_range = max(min_thresh(3), stdHSV(iView,3) * num_stds(3));
        v_range = min(max_thresh(3), v_range);
        HSVlimits(iView,5) = max(0.001, meanHSV(iView,3) - v_range);    % value lower bound
        HSVlimits(iView,6) = min(1.000, meanHSV(iView,3) + v_range);    % value upper bound  

%     if any(dorsumRegionMask{iView}(:))
        % if nothing shows up in dorsumRegionMask, skip the thresholding
        % based on color
        switch iView
            case 1,
                testMask = dorsumRegionMask{iView};
            case 2,
                testMask = dorsumRegionMask{iView} & ~frontMask;
        end
        dorsum_enh = enhanceColorImage(paw_img{iView}, ...
                                       decorrStretchMean{iView}, ...
                                       dorsum_decorrStretchSigma{iView}, ...
                                       'mask', testMask);

        dorsum_hsv = rgb2hsv(dorsum_enh);
        dorsum_mask = HSVthreshold(dorsum_hsv, ...
                                   HSVlimits(iView,:));
                               
        if ~dorsum_past_frontPanel && iView == 2
            % check on the other side of the front panel to see if the paw
            % dorsum has appeared yet
            grayMask = false(mask_bbox(iView,4:-1:3)+1);
            for iColor = 1 : 3
                grayMask = grayMask | (paw_img{iView}(:,:,iColor) > raw_threshold);
            end
            candidate_enh_region = candidateRegion{iView} & ~frontMask & grayMask;
            candidate_enh = enhanceColorImage(paw_img{iView}, ...
                                              decorrStretchMean{iView}, ...
                                              dorsum_decorrStretchSigma{iView}, ...
                                              'mask', candidate_enh_region);
            candidate_hsv = rgb2hsv(candidate_enh);
            candidate_mask = HSVthreshold(candidate_hsv, ...
                                          HSVlimits(iView,:));
                                      
            % mask out only the part behind the front panel mask
            % find the horizontal middle of the front panel mask
            frontPanelPoints = zeros(2,2);
            frontPanelPoints(1,1) = round(mean(d_frontPanel_x(1:2)));
            frontPanelPoints(2,1) = round(mean(d_frontPanel_x(3:4)));
            frontPanelPoints(1,2) = d_frontPanel_y(1);
            frontPanelPoints(2,2) = d_frontPanel_y(3);
            frontPanelPoints(:,1) = frontPanelPoints(:,1) - mask_bbox(iView,1);
            frontPanelPoints(:,2) = frontPanelPoints(:,2) - mask_bbox(iView,2);
            
            % figure out which side the test point should be on
            testPoint = zeros(1,2);
            testPoint(2) = frontPanelPoints(1,2);
            if d_frontPanel_x(1) < imSize(2)/2
                % left side
                testPoint(1) = max(d_frontPanel_x) - mask_bbox(iView,1);
            else
                testPoint(1) = min(d_frontPanel_x) - mask_bbox(iView,1);

            end
            behindFrontPanelMask = segregateImage(frontPanelPoints, testPoint, mask_bbox(iView,4:-1:3)+1); 
            if any(candidate_mask & behindFrontPanelMask)

            end
        end
                               

%         if iView == 2
%             dorsum_mask = dorsum_mask & ~frontMask;
%         end
        
    %     dorsum_gray = mean(dorsum_enh,3);            
    % 	dorsum_mask = (dorsum_gray > 0.00001) & (dorsum_gray < dorsum_gray_thresh);
        dorsum_mask = bwdist(dorsum_mask) < 2;
        dorsum_mask = imopen(dorsum_mask, SE);
        dorsum_mask = imclose(dorsum_mask,SE);
        dorsum_mask = imfill(dorsum_mask,'holes');
        tempMask = dorsum_mask & prevMask{iView};
        dorsum_mask = imreconstruct(tempMask, dorsum_mask);
        
%         [~,~,~,~,labMat] = step(pdBlob{iView}, dorsum_mask);
%         dorsum_mask = (labMat > 0);

        dorsum_mask = multiRegionConvexHullMask(dorsum_mask);

        % NEED TO CONTINUE TO WORK HERE IF WE REALLY WANT TO GET THE PAW DORSUM
        % STUFF WORKING - WILL NEED TO FIGURE OUT HOW TO DEAL WITH PAW DORSUM
        % WHEN IT DISAPPEARS IN ONE VIEW...
        dorsumRegionMask{iView} = dorsum_mask;
    end
    if ~any(dorsumRegionMask{iView}(:))
        tracks(1).isvisible(iView) = false;
        
        tracks(1).(prevMaskStr) = tracks(1).(digMaskStr);
        tracks(1).(digMaskStr) = prevMask{iView} & ~digitsHull{iView};
    end

    % if any of the predicted paw dorsum location overlaps with the front
    % panel mask, incorporate that here
    if iView == 2
        tracks(1).prevmask2  = tracks(1).digitmask2;
        frontOverlap = prevMask{iView} & frontMask & angledRegion{iView};
        tracks(1).digitmask2 = dorsumRegionMask{iView} | frontOverlap;
        tracks(1).digitmask2 = multiRegionConvexHullMask(tracks(1).digitmask2);
        tracks(1).digitmask2 = tracks(1).digitmask2 & candidateRegion{iView};

        % calculate projection into center view
        if any(dorsumRegionMask{iView}(:))
            projMask = calcProjMask(tracks(1).digitmask2, ...
                                    trackingBoxParams.F(:,:,1)', ...
                                    mask_bbox(iView,:), ...
                                    imSize);
            projMask = projMask(mask_bbox(1,2) : mask_bbox(1,2) + mask_bbox(1,4), ...
                                mask_bbox(1,1) : mask_bbox(1,1) + mask_bbox(1,3));
        else
            projMask = true(mask_bbox(1,4:-1:3)+1);
        end
    end
    
    if ~any(dorsumRegionMask{iView}(:))
        tracks(1).isvisible(iView) = false;
        
        tracks(1).(prevMaskStr) = tracks(1).(digMaskStr);
        tracks(1).(digMaskStr) = prevMask{iView} & ~digitsHull{iView};
    end
end

    
for iView = 1 : 2
%     prevMaskStr = sprintf('prevmask%d',iView);
    digitMaskStr = sprintf('digitmask%d',iView);
    
    if tracks(1).isvisible(iView)
        tracks(1).totalVisibleCount(iView) = tracks(1).totalVisibleCount(iView) + 1;
        tracks(1).(digitMaskStr) = dorsumRegionMask{iView};
    else
        tracks(1).consecutiveInvisibleCount(iView) = ...
                tracks(1).consecutiveInvisibleCount(iView) + 1;
    end
    
    s_dorsum = regionprops(tracks(1).(digitMaskStr),'Centroid','boundingbox');
    if isempty(s_dorsum)
        tracks(1).currentDigitMarkers(:,2,iView) = projected_nextPoint(iView,:);
    else
        tracks(1).currentDigitMarkers(:,2,iView) = s_dorsum.Centroid;
        tracks(1).bbox(iView,:) = s_dorsum.BoundingBox;
    end
    
end

tracks(1) = digit3Dpoints(trackingBoxParams, tracks(1), mask_bbox);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [currentDigitMarkers, pts_transformed, digitsHull] = ...
    findDigitMarkers(tracks, pawPref, mask_bbox, prev_mask_bbox)
%
% INPUTS:
%   tracks - the full set of digit tracks, after the digits have been
%       identified for the current frame (includes paw dorsum track as
%       index 1)
%   pawPref - string containing 'left' or 'right'
%   paw_img - 1 x 2 cell array containing the undistorted masked paw image
%       in the direct and mirror views, respectively
%
% OUTPUTS:
%   currentDigitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)
%   pts_transformed - 
%   digitsHull - 

expandedImSize = [1000, 1000];    % to make sure that pts_transformed are positive further down

fixed_pts = getFixedPoints(pawPref);
digitsHull = cell(1,2);

currentDigitMarkers = zeros(length(tracks)-2, 2, 3, 2);    % number of digits by (x,y) by base/centroid/tip by view number

firstVisibleDigitFound = false(1,2);
lastVisibleDigitFound = false(1,2);
digCentroids = zeros(2,2,2);
currentMask = cell(1,2);
digitMasks = cell(1,2);
digitMasks{1} = false(size(tracks(2).digitmask1));
digitMasks{2} = false(size(tracks(2).digitmask2));
firstMask = cell(1,2);
lastMask = cell(1,2);
for ii = 2 : length(tracks)-2
    currentMask{1} = tracks(ii).digitmask1;
    currentMask{2} = tracks(ii).digitmask2;
    digitMasks{1} = digitMasks{1} | currentMask{1};
    digitMasks{2} = digitMasks{2} | currentMask{2};

    for iView = 1 : 2
        if tracks(ii).isvisible(iView)
            s = regionprops(currentMask{iView},'centroid');
            if ~firstVisibleDigitFound(iView)
                firstVisibleDigitFound(iView) = true;
                digCentroids(1,:,iView) = s.Centroid;
                currentDigitMarkers(ii-1,:,2,iView) = s.Centroid;
                firstMask{iView} = currentMask{iView};
            else
                lastVisibleDigitFound(iView) = true;
                digCentroids(2,:,iView) = s.Centroid;
                lastMask{iView} = currentMask{iView};
                currentDigitMarkers(ii-1,:,2,iView) = s.Centroid;
            end
        end
    end
end

H = zeros(3,3,2);
linepts = zeros(2,2);

pts_transformed = zeros(3,2,2);
bbox = zeros(1,4);
for iView = 1 : 2
    if ~firstVisibleDigitFound(iView); continue; end     % if no digits can be found (for example,
                                                         % if all are
                                                         % behind the front
                                                         % panel, skip
                                                         % this)

	digitMaskStr = sprintf('digitmask%d',iView);
    
    regionSize = size(digitMasks{iView});
    bbox(1) = round(expandedImSize(2)/2 - regionSize(2)/2);
    bbox(2) = round(expandedImSize(1)/2 - regionSize(1)/2);
    bbox(3:4) = regionSize(2:-1:1) - 1;
	if ~lastVisibleDigitFound(iView)    % didn't find at least two visible digits, so need to do something else to figure out where to put the "nearest neighbor" point
        % let's try using the centroid of the last dorsum mask
        s = regionprops(tracks(1).(digitMaskStr),'centroid');
        dorsum_est = s.Centroid + (mask_bbox(iView,1:2) - prev_mask_bbox(iView,1:2)) + bbox(1:2);
    else
        movingPoints = squeeze(digCentroids(:,:,iView));
        movingPoints = bsxfun(@plus,movingPoints, bbox(1:2));

        tform = fitgeotrans(squeeze(fixed_pts(1:2,:,iView)), movingPoints, 'nonreflectivesimilarity');
        H(:,:,iView) = tform.T';
        fixed_pts_hom = [squeeze(fixed_pts(:,:,iView)), ones(3,1)];
        pts_transformed_hom = (H(:,:,iView) * fixed_pts_hom')';
        pts_transformed(:,:,iView) = bsxfun(@rdivide,...
                                     squeeze(pts_transformed_hom(:,1:2)), ...
                                     squeeze(pts_transformed_hom(:,3)));

        [A,B,C] = constructParallelLine(pts_transformed(1,:,iView), ...
                                        pts_transformed(2,:,iView), ...
                                        pts_transformed(3,:,iView));
        borderPts = lineToBorderPoints([A,B,C], expandedImSize);

        linepts(1,:) = borderPts(1:2);
        linepts(2,:) = borderPts(3:4);

        % find midpoint between movingPoints
        digit_middle = mean(movingPoints,1);
        dorsum_est = findNearestPointOnLine(linepts(1,:),linepts(2,:),digit_middle);
    end
    for ii = 2 : length(tracks) - 2

        if ~tracks(ii).isvisible(iView); continue; end    % if digit not visible in one of the views, skip finding markers

        currentMask{iView} = tracks(ii).(digitMaskStr);

        tempMask = false(expandedImSize);
        tempMask(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3)) = currentMask{iView};
        edge_I = bwmorph(tempMask,'remove');
        
        [y,x] = find(edge_I);
%         [~,nnidx] = findNearestPointToLine(linepts, [x,y]);
        [~, nnidx] = findNearestNeighbor(dorsum_est, [x,y]);
        currentDigitMarkers(ii-1,:,1,iView) = [x(nnidx),y(nnidx)] - bbox(1:2);
        
%         [~,nnidx] = findFarthestPointFromLine(linepts, [x,y]);
        [~, fpidx] = findFarthestPoint(dorsum_est, [x,y]);
        currentDigitMarkers(ii-1,:,3,iView) = [x(fpidx),y(fpidx)] - bbox(1:2);
    end

    [digitsHull{iView},~] = multiRegionConvexHullMask(digitMasks{iView});
    
    pts_transformed(:,:,iView) = bsxfun(@minus,pts_transformed(:,:,iView),bbox(1:2));
    
end
        

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tracks = truncateDigits(tracks, currentDigitMarkers)
%
% INPUTS:
%   currentDigitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)

borderPts = zeros(2,2);
for iView = 1 : 2
    dMaskString = sprintf('digitmask%d',iView);
    imSize = size(tracks(2).(dMaskString));
    firstVisibleIdx = 0;
    lastVisibleIdx = 0;
    for iTrack = 2 : length(tracks) - 1    % only digit tracks
        % find the first and last visible digits
        if tracks(iTrack).isvisible(iView) && firstVisibleIdx == 0
            firstVisibleIdx = iTrack;
            lastVisibleIdx = iTrack;
        elseif tracks(iTrack).isvisible(iView) && ~(firstVisibleIdx == 0)
            lastVisibleIdx = iTrack;
        end
    end
    if firstVisibleIdx == lastVisibleIdx; continue; end
    borderPts(1,:) = squeeze(currentDigitMarkers(firstVisibleIdx-1, :, 1, iView));
    borderPts(2,:) = squeeze(currentDigitMarkers(lastVisibleIdx-1, :, 1, iView));
    ptInRegion = squeeze(currentDigitMarkers(lastVisibleIdx-1, :, 3, iView));
    
    [mask,~] = segregateImage(borderPts, ptInRegion, imSize);
    
    for iTrack = 2 : length(tracks) - 1    % only digit tracks
        tracks(iTrack).(dMaskString) = tracks(iTrack).(dMaskString) & mask;
    end

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fixed_pts = getFixedPoints(pawPref)
%
% INPUTS:

fixed_pts = zeros(3,2,2);    % 3 points by (x,y) coords by 2 views (1 - direct, 2 - mirror)
switch lower(pawPref)
    case 'right',
        fixed_pts(:,:,1) = [ 2.0   0.0    % most radial digit
                             0.0   0.0    % most ulnar digit
                             1.0  -2.0];  % palm region
        fixed_pts(:,:,2) = [0.0  0.0
                            0.0  2.0
                            2.0  1.0];
    case 'left',
        fixed_pts(:,:,1) = [0.0  0.0    % most radial digit
                            2.0  0.0    % most ulnar digit
                            1.0  -2.0];  % palm region
        fixed_pts(:,:,2) = [2.0  0.0
                            2.0  2.0
                            0.0  1.0];
end

end