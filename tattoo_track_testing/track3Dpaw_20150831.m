function pawTrajectory = track3Dpaw_20150831(video, ...
                                         BGimg_ud, ...
                                         refImageTime, ...
                                         initDigitMasks, ...
                                         init_mask_bbox, ...
                                         digitMarkers, ...
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
%   digitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
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
decorrStretchMean{1}  = [127.5 127.5 127.5     % to isolate dorsum of paw
                         127.5 127.5 100.0     % to isolate blue digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 100.0 127.5     % to isolate green digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 127.5 127.5];

decorrStretchSigma{1} = [075 075 075       % to isolate dorsum of paw
                         075 075 075       % to isolate blue digits
                         075 075 075       % to isolate red digits
                         075 075 075       % to isolate green digits
                         075 075 075       % to isolate red digits
                         075 075 075];
                     
decorrStretchMean{2}  = [127.5 127.5 127.5     % to isolate dorsum of paw
                         127.5 127.5 100.0     % to isolate blue digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 100.0 127.5     % to isolate green digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 127.5 127.5];
                     
decorrStretchSigma{2} = [075 075 075       % to isolate dorsum of paw
                         075 075 075       % to isolate blue digits
                         075 075 075       % to isolate red digits
                         075 075 075       % to isolate green digits
                         075 075 075       % to isolate red digits
                         075 075 075];
                     
decorrStretchMean{3}  = [127.5 127.5 127.5     % to isolate dorsum of paw
                         127.5 127.5 100.0     % to isolate blue digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 100.0 127.5     % to isolate green digits
                         100.0 127.5 127.5     % to isolate red digits
                         127.5 127.5 127.5];
                     
decorrStretchSigma{3} = [075 075 075       % to isolate dorsum of paw
                         075 075 075       % to isolate blue digits
                         075 075 075       % to isolate red digits
                         075 075 075       % to isolate green digits
                         075 075 075       % to isolate red digits
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
HSVthresh_parameters.num_stds(1) = 1;         % number of standard deviations hue can deviate from mean (unless less than min_thresh or greater than max_thresh)
HSVthresh_parameters.num_stds(2) = 1;         % number of standard deviations saturation can deviate from mean (unless less than min_thresh or greater than max_thresh)
HSVthresh_parameters.num_stds(3) = 1;         % number of standard deviations value can deviate from mean (unless less than min_thresh or greater than max_thresh)

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
satLimits = [0.80000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00
             0.90000    1.00];
valLimits = [0.00001    0.70
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00
             0.95000    1.00];
hueLimits = [0.00, 0.16;    % red
             0.33, 0.16;    % green
             0.66, 0.05;    % blue
             0.33, 0.16];   % dark green
         
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

trackCheck.maxDistPerFrame = 5;    % in mm
trackCheck.maxReprojError = 0.1;   % not sure what this needs to be, will need some trial and error
trackCheck.maxPixelsPerFrame = 20;  % not sure what this needs to be, will need some trial and error
% =======
% >>>>>>> origin/master
for iarg = 1 : 2 : nargin - 10
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
    case 'right',
        dMirrorIdx = 1;   % index of mirror with dorsal view of paw
        pMirrorIdx = 3;   % index of mirror with palmar view of paw
        fundMat(:,:,1) = F.left;
        fundMat(:,:,2) = F.right;
        P2 = P.left;
        scale = boxCalibration.scale(1);
        sideRegion{1} = leftRegion;
        sideRegion{2} = rightRegion;
end



trackingBoxParams.K = K;
trackingBoxParams.F = fundMat;
trackingBoxParams.P1 = eye(4,3);
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

pawTrajectory = zeros(numFrames, 5, 3, 3);    % numFrames by numPawParts by 3 pointsPerDigit by (x,y,z)
currentFrame = video.FrameRate * refImageTime;
% initialize one track each for the dorsum of the paw and each digit in the
% mirror and center views

tracks = initializeTracks();

s = struct('Centroid', {}, ...
           'BoundingBox', {});
num_elements_to_track = size(digitMasks{2}, 3);
meanHSV = zeros(3,num_elements_to_track,3);
stdHSV = zeros(3,num_elements_to_track,3);
isVisible = false(num_elements_to_track, 3);
totalVisCount = zeros(num_elements_to_track, 3);
consecInvisibleCount = zeros(num_elements_to_track, 3);
for ii = 1 : num_elements_to_track

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
            meanHSV(iView,ii,1) = hueLimits(colorIdx,1);
            stdHSV(iView,ii,1) = hueLimits(colorIdx,2) / HSVthresh_parameters.num_stds(1);
            meanHSV(iView,ii,2) = mean(satLimits(ii,:),2);
            stdHSV(iView,ii,2) = range(satLimits(ii,:)) / HSVthresh_parameters.num_stds(2);
            meanHSV(iView,ii,3) = mean(valLimits(ii,:),2);
            stdHSV(iView,ii,3) = range(valLimits(ii,:)) / HSVthresh_parameters.num_stds(3);
            s(iView,ii).BoundingBox = zeros(1,4);
        end
    end
    
end

tracks = initializeTracks();
markers3D = zeros(6,3,3);
markers3D(2:5,:,:) = digitMarkersTo3D(digitMarkers, trackingBoxParams, mask_bbox);
fullDigMarkers = zeros(6,2,3,2);
fullDigMarkers(2:5,:,:,:) = digitMarkers;
for ii = 1 : num_elements_to_track
    
    bbox = [s(:,ii).BoundingBox];
    bbox = reshape(bbox,[4,3])';
%   digitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)

    newTrack = struct(...
        'id', ii, ...
        'bbox', bbox, ...
        'digitmask1', squeeze(digitMasks{1}(:,:,ii)), ...
        'digitmask2', squeeze(digitMasks{2}(:,:,ii)), ...
        'digitmask3', squeeze(digitMasks{3}(:,:,ii)), ...
        'meanHSV', squeeze(meanHSV(:,ii,:)), ...
        'stdHSV', squeeze(stdHSV(:,ii,:)), ...
        'markers3D', squeeze(markers3D(ii,:,:)), ...
        'digitMarkers', squeeze(fullDigMarkers(ii,:,:,:)), ...
        'age', 1, ...
        'isvisible', isVisible(ii,:), ...
        'totalVisibleCount', totalVisCount(ii,:), ...
        'consecutiveInvisibleCount', consecInvisibleCount(ii,:));
    tracks(ii) = newTrack;
        
end

% now that tracks are initialized, do the actual tracking
paw_hsv = cell(1,2);
paw_img = cell(1,2);
HSVlimits = zeros(num_elements_to_track-1, 6, 2);
numFrames = 0;
current_BG_mask = cell(1,3);
current_paw_mask = cell(1,3);

dorsum_decorrStretchMean = cell(1,2);
dorsum_decorrStretchSigma = cell(1,2);
for iView = 1 : 2
    dorsum_decorrStretchMean{iView} = decorrStretchMean{iView}(1,:);
    dorsum_decorrStretchSigma{iView} = decorrStretchSigma{iView}(1,:);
end

while video.CurrentTime < video.Duration
    numFrames = numFrames + 1
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
    BG_mask = imfill(BG_mask,'holes');
    BG_mask = BG_mask & ~frontPanelMask;
    
    prev_mask_bbox = mask_bbox;
    prev_paw_mask = false(h,w);
    
    for iView = 1 : 3
        pawMask = eval(sprintf('tracks(num_elements_to_track).digitmask%d', iView));
        prev_paw_mask(prev_mask_bbox(iView,2) : prev_mask_bbox(iView,2) + prev_mask_bbox(iView,4),...
                      prev_mask_bbox(iView,1) : prev_mask_bbox(iView,1) + prev_mask_bbox(iView,3)) = pawMask;
    end

    % exclude anything too dark to be the paw (e.g., nose, etc.)
    grayMask = false(h,w);
    for iColor = 1 : 3
        grayMask = grayMask | (image_ud(:,:,iColor) > raw_threshold);
    end
    BG_mask = BG_mask & grayMask;
	% find overlap between previous mask and current mask, and keep those
    % parts of the background mask that overlapped with the previous mask
    overlapMask = prev_paw_mask & BG_mask;
    BG_mask = imreconstruct(overlapMask, BG_mask);
%     BG_mask = imdilate(BG_mask,strel('disk',10));

    % will eventually need code here to deal with partial occlusions of the
    % full paw mask
    SE = strel('disk',5);    % only need this because of partial occlusion behind checkerboard
    % can probably eliminate the line above when we start analyzing boxes
    % without the checkerboards
    
    current_BG_mask{1} = center_region_mask & BG_mask;
    current_BG_mask{2} = sideRegion{1} & BG_mask;
    current_BG_mask{3} = sideRegion{2} & BG_mask;
    for iView = 1 : 3
        current_paw_mask{iView} = imdilate(current_BG_mask{iView}, SE);
    end
    projMask1 = pawProjectionMask(current_paw_mask{2}, fundMat(:,:,1)', [h,w]);
    projMask2 = pawProjectionMask(current_paw_mask{3}, fundMat(:,:,2)', [h,w]);
    current_paw_mask{1} = current_paw_mask{1} & projMask1 & projMask2;
    
    projMask1 = pawProjectionMask(current_BG_mask{2}, fundMat(:,:,1)', [h,w]);
    projMask2 = pawProjectionMask(current_BG_mask{3}, fundMat(:,:,2)', [h,w]);
    current_BG_mask{1} = current_BG_mask{1} & projMask1 & projMask2;
    
    for iView = 1 : 3
        current_paw_mask{iView} = multiRegionConvexHullMask(current_paw_mask{iView});
        % above line is in case there are multiple parts of the mask (for
        % example, if there is partial occlusion of the paw behind the box
        % front
        s = regionprops(current_paw_mask{iView},'BoundingBox');
        mask_bbox(iView,:) = floor(s.BoundingBox) - 10;
        mask_bbox(iView,3:4) = mask_bbox(iView,3:4) + 30;
        
        tempMask = current_paw_mask{iView};
        current_paw_mask{iView} = tempMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                           mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
                                       
        tempMask = current_BG_mask{iView};
        current_BG_mask{iView} = tempMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                          mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
        current_BG_mask{iView} = imfill(current_BG_mask{iView},'holes');
        paw_hsv{iView} = zeros(mask_bbox(iView,4)+1,mask_bbox(iView,3)+1,3,num_elements_to_track);
    end
    % now, get rid of all the bits that are too small, the wrong shape, 
    % etc. This is where we need to start thinking about what to do when
    % the paw passes behind the edge of the box and there will be two paw 
    % parts. A model of the paw might solve this problem, but would like to 
    % get away with doing this without one...
    
    tracks(num_elements_to_track).digitmask1 = current_paw_mask{1};
    tracks(num_elements_to_track).digitmask2 = current_paw_mask{2};
    tracks(num_elements_to_track).digitmask3 = current_paw_mask{3};
    
    for ii = 1 : num_elements_to_track
        
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
    prelim_digitMask = cell(1,num_elements_to_track-1);
    for ii = 2 : num_elements_to_track - 1    % do the digits first
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
        tempMask = thresholdDigits(tracks(ii).meanHSV, ...
                                   tracks(ii).stdHSV, ...
                                   HSVthresh_parameters, ...
                                   hsv, ...
                                   numSameColorObjects, ...
                                   digitBlob, ...
                                   beadMask);
        for iView = 1 : 2
%             if strcmpi(colorList{ii},'blue')
%                 bbox_blueBeadMask = blueBeadMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
%                                                  mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
%                 % eliminate any identified blue regions that overlap with blue
%                 % beads
%                 tempMask{iView} = tempMask{iView} & ~bbox_blueBeadMask;% squeeze(boxMarkers.beadMasks(:,:,3));
%             end
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
            
        newTracks = assign_prelim_blobs_to_tracks(colorTracks, ...
                                                  prelimMask, ...
                                                  mask_bbox, ...
                                                  prev_mask_bbox, ...
                                                  trackingBoxParams, ...
                                                  trackCheck);
            
        for iDigit = 1 : numSameColorObjects
            tracks(sameColIdx(iDigit)) = newTracks(iDigit);
%             fullDigitMasks{1} = fullDigitMasks{1} | ...
%                                 tracks(sameColIdx(iDigit)).digitmask1;
%             fullDigitMasks{2} = fullDigitMasks{2} | ...
%                                 tracks(sameColIdx(iDigit)).digitmask2;
        end
    end    % end for iColor...
    % now should have the digits - need to identify the dorsal aspect of
    % the paw...
    % first step is to make sure none of the digit masks bleed into the paw
    % dorsum region. Make sure that if we connect the base of the first and
    % last digits, no other digit masks cross that line (for example,
    % misidentifying part of the green paw dorsum as part of a green digit)
%     [digitMarkers, ~, ~] = findDigitMarkers(tracks, pawPref);
%     tracks = truncateDigits(tracks, digitMarkers);

    % find the 3d points of all digits visible in both views, and the
    % general region in which the dorsum of the paw must appear
    
    [tracks, pdMask] = findDorsumRegion(tracks, ...
                                        pawPref, ...
                                        paw_img, ...
                                        current_BG_mask, ...
                                        dorsum_decorrStretchMean, ...
                                        dorsum_decorrStretchSigma, ...
                                        dorsum_gray_thresh, ...
                                        pdBlob, ...
                                        trackingBoxParams, ...
                                        mask_bbox, ...
                                        [h,w]);

                                          
    % now have to deal with partially hidden objects
    tracks = reconstructPartiallyHiddenObjects(tracks, mask_bbox, fundMat, [h,w], current_BG_mask);

    % triangulate all available digit markers
    tracks(2:5) = digit3Dpoints(trackingBoxParams, tracks(2:5), mask_bbox);
% 	tracks(2:5) = digit3Dpoints(digitMarkers, trackingBoxParams, tracks(2:5), mask_bbox);
    
    % now have to deal with completely hidden digits
    tracks = reconstructCompletelyHiddenObjects(tracks, mask_bbox, [h,w], current_BG_mask);
    
%     hsv{iView} = squeeze(paw_hsv{iView}(:,:,:,1));
%     pdMask = thresholdDorsum(tracks(1).meanHSV, ...
%                              tracks(1).stdHSV, ..., ...
%                              HSVthresh_parameters, ...
%                              hsv, ...
%                              digitMarkers, ...
%                              dorsumRegionMask, ...
%                              pdBlob, ...
%                              trackingBoxParams, ...
%                              mask_bbox);

	tracks(1).digitmask1 = pdMask{1};
    tracks(1).digitmask2 = pdMask{2};
    for iView = 1 : 2
        if any(pdMask{iView}(:))
            s = regionprops(pdMask{iView},'boundingbox','centroid');
            tracks(1).isvisible(iView) = true;
            tracks(1).bbox(iView,:) = s.BoundingBox;
            tracks(1).digitMarkers(:,2,iView) = s.Centroid;
            tracks(1).totalVisibleCount(iView) = tracks(1).totalVisibleCount(iView) + 1;
        else
            tracks(1).isvisible(iView) = false;
            tracks(1).consecutiveInvisibleCount(iView) = ...
                tracks(1).consecutiveInvisibleCount(iView) + 1;
        end
    end
    if all(tracks(1).isvisible(1:2))
        digitMarkers = zeros(1,2,1,2);
        digitMarkers(1,:,1,1) = tracks(1).digitMarkers(:,2,1);
        digitMarkers(1,:,1,2) = tracks(1).digitMarkers(:,2,2);
        markers3D = digitMarkersTo3D(digitMarkers, trackingBoxParams, mask_bbox);
        tracks(1).markers3D(2,:) = squeeze(markers3D)';
    end
            %   digitMarkers - nx2xmx2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is the site along each digit
%       (that is, proximal, centroid, distal, etc.), 4th dimension is the
%       view (1 = direct, 2 = mirror)
    % now have to do something about objects that aren't visible in one of
    % the views...
    
    tracks = updateHSVparams(tracks, paw_hsv);


        
        
    
    
	% now establish all 3d points that are available from visible points in
	% both views
    % for now, only calculating the centroid of the dorsum of the paw
    for iTrack = 1 : 5
        pawTrajectory(currentFrame,iTrack,:,:) = tracks(iTrack).markers3D;
    end
    
%     plotTracks(tracks, image_ud, mask_bbox)
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tracks = initializeTracks()
    % create an empty array of tracks
    tracks = struct(...
        'id', {}, ...
        'bbox', {}, ...
        'digitmask1', {}, ...
        'digitmask2', {}, ...
        'digitmask3', {}, ...
        'meanHSV', {}, ...
        'stdHSV', {}, ...
        'markers3D', {}, ...
        'digitMarkers', {}, ...
        'age', {}, ...
        'isvisible', {}, ...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [normalized_points] = normalize_points(points2d, K)
% INPUTS
%   points2d - m x 2 array containing (x,y) pairs in each row
%   K - intrinsic matrix (lower triangular format)
homogeneous_points = [points2d,ones(size(points2d,1),1)];
normalized_points  = (K' \ homogeneous_points')';
normalized_points = bsxfun(@rdivide,normalized_points(:,1:2),normalized_points(:,3));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [meanHSV, stdHSV] = calcHSVstats(paw_hsv, digitMask)
%
% INPUTS:
%   paw_hsv - m x n x 3 array containing an hsv image
%   digitMask - binary mask of the digit (or other object)
%
% OUTPUTS:
%
%
    meanHSV = zeros(1,3);
    stdHSV  = zeros(1,3);
    idx = squeeze(digitMask);
    idx = idx(:);
    for jj = 1 : 3
        colPlane = squeeze(paw_hsv(:,:,jj));
        colPlane = colPlane(:);
        if jj == 1
            meanAngle = wrapTo2Pi(circ_mean(colPlane(idx)*2*pi));
            stdAngle = wrapTo2Pi(circ_std(colPlane(idx)*2*pi));
            meanHSV(jj) = meanAngle / (2*pi);
            stdHSV(jj) = stdAngle / (2*pi);
        else
            meanHSV(jj) = mean(colPlane(idx));
            stdHSV(jj) = std(colPlane(idx));
        end
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function blobID = selectBlobForTrack(blobMask, ...
                                     paw_hsv, ...
                                     currentTrack, ...
                                     otherTrack, ...
                                     iView, ...
                                     prev_mask_bbox, ...
                                     mask_bbox)
% INPUTS:
%   blobMask - mask of the currently detected blobs    
    % figure out where the previous mask for this digit is in the
    % current bounding box
    switch iView
        case 1,
            prev_digit_mask = currentTrack.digitmask1;
            other_digit_mask = otherTrack.digitmask1;
        case 2,
            prev_digit_mask = currentTrack.digitmask2;
            other_digit_mask = other_digit_mask.digitmask2;
    end
    temp = false(h,w);
    temp(prev_mask_bbox(2) : prev_mask_bbox(2) + prev_mask_bbox(4), ...
         prev_mask_bbox(1) : prev_mask_bbox(1) + prev_mask_bbox(3)) = ...
             prev_digit_mask;
    prev_digit_mask = temp(mask_bbox(2) : mask_bbox(2) + mask_bbox(4), ...
                           mask_bbox(1) : mask_bbox(1) + mask_bbox(3));
                       
    temp = false(h,w);
    temp(prev_mask_bbox(2) : prev_mask_bbox(2) + prev_mask_bbox(4), ...
         prev_mask_bbox(1) : prev_mask_bbox(1) + prev_mask_bbox(3)) = ...
             other_digit_mask;
    other_digit_mask = temp(mask_bbox(2) : mask_bbox(2) + mask_bbox(4), ...
                            mask_bbox(1) : mask_bbox(1) + mask_bbox(3));
                           
    % a few possibilities
    % first, both digits could have been visible in the previous frame. In
    % that case, we can compare the blobs in blobMask to each of the digit
    % blobs from the previous frame, and see which fits better to the
    % current digit. 
    s = regionprops(blobMask,'Centroid','Area');
    L = bwlabel(blobMask);
    % calculate mean hsv values in each blob
    meanHSV = zeros(length(s),3);
    for ii = 1 : length(s)
        [meanHSV(ii,:), stdHSV] = calcHSVstats(paw_hsv, (L == ii));   % not sure if stdHSV will be useful or not
    end
        
    if currentTrack.isvisible(iView) && otherTrack.isvisible(iView)

        % calculate Euclidean distances between the centroids of the blobs
        % in blobMask and the previous digit blobs
        
    end

%     prev_bbox = track.bbox(iView,:);
%     prev_bbox(1:2) = prev_bbox(1:2) - mask_bbox(iView,1:2) + 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mp1, mp2] = points3d_to_images(points3d, P1, P2, K)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function digitMask = thresholdDigits(meanHSV, ...
                                     stdHSV, ...
                                     HSVthresh_parameters, ...
                                     hsv, ...
                                     numSameColorObjects, ...
                                     digitBlob,...
                                     beadMask)
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
%   paw_img - 2-element cell array containing the original rgb image of the
%       paw within the bounding box for the direct view (index 1) and 
%       mirror view (index 2)
%   numSameColorObjects - scalar, number of digits that have the same color
%       tattoo as the current digit
%   digitBlob - cell array of blob objects containing blob parameters for
%       the direct view (index 1) and mirror view (index 2)
%   beadMask - 
%
% OUTPUTS:
%   digitMask - 1 x 2 cell array containing the mask for the direct
%       (center) and mirror views, respectively


% consider adjusting this algorithm to include knowledge from the previous
% frame

    min_thresh = HSVthresh_parameters.min_thresh;
    max_thresh = HSVthresh_parameters.max_thresh;
    num_stds   = HSVthresh_parameters.num_stds;
    
    HSVlimits = zeros(2,6);
    digitMask = cell(1,2);
    for iView = 1 : 2
        % construct HSV limits vector from track, HSVthresh_parameters
        HSVlimits(iView,1) = meanHSV(iView,1);            % hue mean
        HSVlimits(iView,2) = max(min_thresh(1), stdHSV(iView,1) * num_stds(1));  % hue range
        HSVlimits(iView,2) = min(max_thresh(1), HSVlimits(iView,2));  % hue range

        s_range = max(min_thresh(2), stdHSV(iView,2) * num_stds(2));
        s_range = min(max_thresh(2), s_range);
        HSVlimits(iView,3) = max(0.001, meanHSV(iView,2) - s_range);    % saturation lower bound
        HSVlimits(iView,4) = min(1.000, meanHSV(iView,2) + s_range);    % saturation upper bound

        v_range = max(min_thresh(3), stdHSV(iView,3) * num_stds(3));
        v_range = min(max_thresh(3), v_range);
        HSVlimits(iView,5) = max(0.001, meanHSV(iView,3) - v_range);    % saturation lower bound
        HSVlimits(iView,6) = min(1.000, meanHSV(iView,3) + v_range);    % saturation upper bound    
        
        % threshold the image
        tempMask = HSVthreshold(hsv{iView}, ...
                                HSVlimits(iView,:));

        tempMask = tempMask & ~beadMask{iView};

        if ~any(tempMask(:)); continue; end

        SE = strel('disk',2);
        tempMask = imopen(tempMask, SE);
        tempMask = imclose(tempMask, SE);
        tempMask = imfill(tempMask, 'holes');

        [A,~,~,~,labMat] = step(digitBlob{iView}, tempMask);
        % take at most the numSameColorObjects largest blobs
        [~,idx] = sort(A, 'descend');
        if ~isempty(A)
            tempMask = false(size(tempMask));
            for kk = 1 : min(numSameColorObjects, length(idx))
                tempMask = tempMask | (labMat == idx(kk));
            end
        end
        
        digitMask{iView} = tempMask;
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pdMask = thresholdDorsum(meanHSV, ...
                                  stdHSV, ...
                                  HSVthresh_parameters, ...
                                  hsv, ...
                                  digitMarkers, ...    % might use this to verify whether we have the full paw dorsum
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
%   digitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
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
                                                   trackCheck)
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
                               trackCheck);
end

end
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
        s_direct = regionprops(prelimMask{1},'Centroid');
        s_mirror = regionprops(prelimMask{2},'Centroid');

        new_centroids(1,:) = s_direct.Centroid + mask_bbox(1,1:2) - 1;
        new_centroids(2,:) = s_mirror.Centroid + mask_bbox(2,1:2) - 1;

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
            prev_centroids = zeros(2,2);
            for iView = 1 : 2
                prev_centroids(iView,:) = prevTrack.digitMarkers(2,:,iView)' +...
                                          prev_bbox(iView,1:2) - 1;
            end
            temp = prev_centroids - new_centroids;
            centroid_diffs_across_frames = zeros(1,2);
            for iView = 1 : 2
                centroid_diffs_across_frames(iView) = norm(temp(iView,:));
                if centroid_diffs_across_frames > trackCheck.maxPixelsPerFrame
                    prelimMask{1,iView} = false(size(prelimMask{1,iView}));
                    newTrack.isvisible(iView) = false;
                    newTrack.consecutiveInvisibleCount(iView) = newTrack.consecutiveInvisibleCount(iView) + 1;
                end
            end
            
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
    
    newTrack.digitmask1 = prelimMask{1};
    newTrack.digitmask2 = prelimMask{2};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newTracks = checkTwoTracks(prevTracks, ...
                                    prelimMask, ...
                                    mask_bbox, ...
                                    prev_bbox, ...
                                    trackingBoxParams, ...
                                    trackCheck)

% INPUTS:
%   prevTracks - track structures for the two tracks that are the same
%       color
%   prelimMask - m x 2 cell array, where m is the number of digits with the
%       same coloring (should be one or two), and the second index is the
%       direct view (index 1) or mirror view (index 2)\
%   mask_bbox - 
%	trackingBoxParams - 
	newTracks = prevTracks;
    prev_3dpoints = zeros(2,3);
    prev_3dpoints(1,:) = prevTracks(1).markers3D(2,:);
    prev_3dpoints(2,:) = prevTracks(2).markers3D(2,:);
    
    % several possibilities: two blobs visible in both views; one blob
    % visible in one view, two blobs in the other; none in one view, two in
    % the other, etc.
    
    % figure out how many blobs in each view
    numBlobs = zeros(2,2);
    s = cell(2,2);
    digLabelMask = cell(2,2);
    for iTrack = 1 : 2
        for iView = 1 : 2
            s{iTrack,iView} = regionprops(prelimMask{iTrack,iView},'area','centroid');
            numBlobs(iTrack,iView) = length(s{iTrack,iView});
            digLabelMask{iTrack,iView} = bwlabel(prelimMask{iTrack,iView});
        end
        if numBlobs(iTrack,1) == 2 && numBlobs(iTrack,2) == 2
            % two blobs visible in each view

            new_centroids = zeros(2,2,2);
%             points3d = zeros(2,3);   % first dimension indexes the 3d points,
%                                      % second dimension is [x,y,z], third
%                                      % dimension is different combinations
            % triangulate the centroids of the direct and mirror view blobs
            for iView = 1 : 2
                for iBlob = 1 : 2
                    new_centroids(iView,iBlob,:) = s{iTrack,iView}(iBlob).Centroid + mask_bbox(iView,1:2) - 1;
%                     new_centroids_norm(iView,iBlob,:) = ...
%                         normalize_points(squeeze(new_centroids(iView,iBlob,:))', trackingBoxParams.K);
                end
            end
            % find intersections of lines connecting centroids of the blobs
            % in the direct and mirror views
            % for blobs that are correctly paired, they should interect at
            % the epipole because of the planar mirror geometry
            test_epipoles = zeros(2,2);
            epi_error = zeros(1,2);
            m = zeros(2,2);
            b = zeros(2,2);
            for ii = 1 : 2    % ii is the index of the blob in the front view
                % calculate slopes and y-intercepts
                m(1,ii) = (new_centroids(1,ii,2) - new_centroids(2,ii,2)) / ...
                          (new_centroids(1,ii,1) - new_centroids(2,ii,1));
                m(2,ii) = (new_centroids(1,ii,2) - new_centroids(2,3-ii,2)) / ...
                          (new_centroids(1,ii,1) - new_centroids(2,3-ii,1));
                b(1,ii) = new_centroids(1,ii,2) - m(1,ii) * new_centroids(1,ii,1);
                b(2,ii) = new_centroids(1,ii,2) - m(2,ii) * new_centroids(1,ii,1);
            end
            for jj = 1 : 2    % jj is the index of the combination
                test_epipoles(jj,1) = (b(jj,2) - b(jj,1)) / (m(jj,1)-m(jj,2));
                test_epipoles(jj,2) = m(jj,1)*test_epipoles(jj,1) + b(jj,1);
                epi_error(jj) = norm(test_epipoles(jj,:) - trackingBoxParams.epipole(1,:));
            end
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
                curr_reproj_error = reprojErrors(iTrack,:);
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
            
            newTracks(iTrack).digitmask1 = centerMask;
            newTracks(iTrack).digitmask2 = mirrorMask;
            newTracks(iTrack).markers3D(2,:) = curr_3dpoint;
            newTracks(iTrack).isvisible = [true,true,false];
            newTracks(iTrack).totalVisibleCount(1:2) = newTracks(iTrack).totalVisibleCount(1:2) + 1;
            newTracks(iTrack).consecutiveInvisibleCount = [0 0];

        else    % what to do if all the blobs aren't there for this digit track?
            
        end

    end

end

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

function [tracks, dorsumRegionMask] = ...
    findDorsumRegion(tracks, ...
                     pawPref, ...
                     paw_img, ...
                     BG_mask, ...
                     decorrStretchMean, ...
                     dorsum_decorrStretchSigma, ...
                     dorsum_gray_thresh, ...
                     pdBlob, ...
                     trackingBoxParams, ...
                     mask_bbox, ...
                     imSize)
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
%   digitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)
%   dorsumRegionMask - cell array containing masks for where the paw dorsum
%       can be with respect to the digits (index 1 id direct view, index 2
%       is mirror view)

% whiteFurMask = cell(1,2);
dorsumRegionMask = cell(1,2);
% for iView = 1 : 2
%     % mask out any points that look like white fur
%     for iColor = 1 : 3
%         whiteFurMask{iView} = (paw_img{iView}(:,:,iColor) > whiteFurThresh);
%     end
% end


[digitMarkers, pts_transformed, digitsHull] = findDigitMarkers(tracks, pawPref);
for iTrack = 2 : 5
    tracks(iTrack).digitMarkers = squeeze(digitMarkers(iTrack-1,:,:,:));
end

validImageBorderPts = zeros(2,2);

SE = strel('disk',2);
for iView = 2 : -1 : 1
    dMaskString = sprintf('digitmask%d',iView);
    
    firstValidIdx = 0;
    for ii = 2 : length(tracks) - 1
        if ~tracks(ii).isvisible(iView)
            continue;
        end
        if firstValidIdx == 0; firstValidIdx = ii-1; end
        lastValidIdx = ii-1;
    end

    validImageBorderPts(1,:) = squeeze(digitMarkers(firstValidIdx,:,1,iView));
    validImageBorderPts(2,:) = squeeze(digitMarkers(lastValidIdx,:,1,iView));
    dorsumRegionMask{iView} = segregateImage(validImageBorderPts, ...
                                             pts_transformed(3,:,iView), size(tracks(ii).(dMaskString)));
%     dorsumRegionMask{iView} = segregateImage(pts_transformed(1:2,:,iView), ...
%                                              pts_transformed(3,:,iView), size(tracks(ii).(dMaskString)));

%     dorsumRegionMask{iView} = dorsumRegionMask{iView} & ~whiteFurMask{iView};
    dorsumRegionMask{iView} = dorsumRegionMask{iView} & ...
                              ~digitsHull{iView} & ...
                              BG_mask{iView};
%     dorsumRegionMask{iView} = dorsumRegionMask{iView} & BG_mask{iView};
    if iView == 1
        dorsumRegionMask{iView} = dorsumRegionMask{iView} & projMask;
    end
    % now enhance the color image of just the dorsum region
    dorsum_enh = enhanceColorImage(paw_img{iView}, ...
                                   decorrStretchMean{iView}, ...
                                   dorsum_decorrStretchSigma{iView}, ...
                                   'mask', dorsumRegionMask{iView});
                               
    dorsum_gray = mean(dorsum_enh,3);            
	dorsum_mask = (dorsum_gray > 0.00001) & (dorsum_gray < dorsum_gray_thresh);
    dorsum_mask = bwdist(dorsum_mask) < 2;
    dorsum_mask = imopen(dorsum_mask, SE);
    dorsum_mask = imclose(dorsum_mask,SE);
    dorsum_mask = imfill(dorsum_mask,'holes');
    [A,~,~,~,labMat] = step(pdBlob{iView}, dorsum_mask);
    dorsum_mask = (labMat > 0);
    
    % find the blob closest to the digits blob
    s_digits = regionprops(digitsHull{iView}, 'centroid');
    s_pd = regionprops(dorsum_mask, 'centroid');
    
    numCentroids = length(s_pd);
    pd_centroids = [s_pd.Centroid];
    pd_centroids = reshape(pd_centroids,[2,numCentroids])';
    
    [~, nnidx] = findNearestNeighbor(s_digits.Centroid, pd_centroids);
    dorsum_mask = (labMat == nnidx);
    dorsum_mask = multiRegionConvexHullMask(dorsum_mask);
    dorsum_mask = dorsum_mask & ~digitsHull{iView};
    dorsum_mask = dorsum_mask & dorsumRegionMask{iView};
	dorsumRegionMask{iView} = imerode(dorsum_mask, strel('disk',1));
    
    % take only the blob closest to the centroid of the digits hull
    
    if iView == 2
        % calculate projection into center view
        projMask = calcProjMask(dorsum_mask, ...
                                trackingBoxParams.F(:,:,1)', ...
                                mask_bbox(iView,:), ...
                                imSize);
        projMask = projMask(mask_bbox(1,2) : mask_bbox(1,2) + mask_bbox(1,4), ...
                            mask_bbox(1,1) : mask_bbox(1,1) + mask_bbox(1,3));
    end

end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tracks = digit3Dpoints(trackingBoxParams, tracks, mask_bbox)
% INPUTS:
%   digitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)
%   tracks - tracks structures containing only the 4 digits (index 1 is
%       index finger, index 4 is pinky)
%   mask_bbox - 2 x 4 array, where each row is a standard bounding box
%       vector [x,y,w,h]

digitMarkers = zeros(length(tracks),2,3,2);
numDigits = length(tracks);
for iDigit = 1 : numDigits
    digitMarkers(iDigit,:,:,:) = tracks(iDigit).digitMarkers;
end

markers3D = digitMarkersTo3D(digitMarkers, trackingBoxParams, mask_bbox);

for iDigit = 1 : numDigits
    tracks(iDigit).markers3D = squeeze(markers3D(iDigit,:,:));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function markers3D = digitMarkersTo3D(digitMarkers, trackingBoxParams, mask_bbox)
%
% INPUTS:
%   digitMarkers - nx2xmx2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is the site along each digit
%       (that is, proximal, centroid, distal, etc.), 4th dimension is the
%       view (1 = direct, 2 = mirror)
%   mask_bbox - 2 x 4 array, where each row is a standard bounding box
%       vector [x,y,w,h]
%
% OUTPUTS:
%   markers3D - n x 3 x 3 array; first index is the digit number (index to
%       pinky), second is the site on the digit (proximal to distal), third
%       is (x,y,z)
%
P1 = trackingBoxParams.P1;
P2 = trackingBoxParams.P2;
numDigits = size(digitMarkers,1);
matched_points = zeros(size(digitMarkers,3),2,2);

markers3D = zeros(numDigits,size(digitMarkers,3),3);    % 4 digits by 3 sites by (x,y,z) coordinates
for iDigit = 1 : numDigits
    skipDigit = false;
    for iView = 1 : 2
        if all(squeeze(digitMarkers(iDigit,:,:,iView)) == 0)
            skipDigit = true;
            break
        end

        for iSite = 1 : size(digitMarkers,3)
            matched_points(iSite,:,iView) = squeeze(digitMarkers(iDigit,:,iSite,iView));
        end
        matched_points(:,1,iView) = matched_points(:,1,iView) + mask_bbox(iView,1);
        matched_points(:,2,iView) = matched_points(:,2,iView) + mask_bbox(iView,2);
        matched_points(:,:,iView) = normalize_points(squeeze(matched_points(:,:,iView)), ...
                                                     trackingBoxParams.K);
    end
    if skipDigit; continue; end    % digit isn't visible in both views
    
    [points3d,~,~] = triangulate_DL(squeeze(matched_points(:,:,1)), ...
                                    squeeze(matched_points(:,:,2)), ...
                                    P1, P2);
    markers3D(iDigit,:,:) = points3d * trackingBoxParams.scale;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tracks = updateHSVparams(tracks, paw_hsv)
%
% INPUTS:
%   tracks - array of tracks structures
%   paw_hsv - 1 x 2 cell structure containing 4-dimensional arrays of hsv
%       images (4th dimension is digit ID)

for iTrack = 1 : length(tracks)
    for iView = 1 : 3
        if tracks(iTrack).isvisible(iView)
            current_hsv = squeeze(paw_hsv{iView}(:,:,:,iTrack));
            if iView == 1
                digitMask = tracks(iTrack).digitmask1;
            elseif iView == 2
                digitMask = tracks(iTrack).digitmask2;
            else
                digitMask = tracks(iTrack).digitmask3;
            end
            [meanHSV, stdHSV] = calcHSVstats(current_hsv, digitMask);
            tracks(iTrack).meanHSV(iView,:) = meanHSV;
            tracks(iTrack).stdHSV(iView,:) = stdHSV;
        end
    end
end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [digitMarkers, pts_transformed, digitsHull] = ...
    findDigitMarkers(tracks, pawPref)
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
%   digitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
%       dimension is (x,y), third dimension is proximal,centroid,tip of
%       each digit, 4th dimension is the view (1 = direct, 2 = mirror)
%   pts_transformed - 
%   digitsHull - 

fixed_pts = getFixedPoints(pawPref);
digitsHull = cell(1,2);

digitMarkers = zeros(length(tracks)-2, 2, 3, 2);    % number of digits by (x,y) by base/centroid/tip by view number

firstVisibleDigitFound = false(1,2);
digCentroids = zeros(2,2,2);
currentMask = cell(1,2);
digitMasks = cell(1,2);
digitMasks{1} = false(size(tracks(2).digitmask1));
digitMasks{2} = false(size(tracks(2).digitmask2));
firstMask = cell(1,2);
lastMask = cell(1,2);
for ii = 2 : length(tracks)-1
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
                digitMarkers(ii-1,:,2,iView) = s.Centroid;
                firstMask{iView} = currentMask{iView};
            else
                digCentroids(2,:,iView) = s.Centroid;
                lastMask{iView} = currentMask{iView};
                digitMarkers(ii-1,:,2,iView) = s.Centroid;
            end
        end
    end
end

H = zeros(3,3,2);
linepts = zeros(2,2);

pts_transformed = zeros(3,2,2);
for iView = 1 : 2
    movingPoints = squeeze(digCentroids(:,:,iView));
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
    borderPts = lineToBorderPoints([A,B,C], size(digitMasks{iView}));
    
    linepts(1,:) = borderPts(1:2);
    linepts(2,:) = borderPts(3:4);

%     firstValidIdx = 0;lastValidIdx = 0;
    for ii = 2 : length(tracks) - 1
%         if ~tracks(ii).isvisible(iView)
%             continue;
%         end
%         if firstValidIdx == 0; firstValidIdx = ii-1; end
%         lastValidIdx = ii-1;
        if any(~tracks(ii).isvisible(1:2)); continue; end    % if digit not visible in one of the views, skip finding markers
        
        if iView == 1
            currentMask{iView} = tracks(ii).digitmask1;
        else
            currentMask{iView} = tracks(ii).digitmask2;
        end
        
        edge_I = bwmorph(currentMask{iView},'remove');
        [y,x] = find(edge_I);
        [~,nnidx] = findNearestPointToLine(linepts, [x,y]);
%         [~,nnidx] = findNearestNeighbor(pts_transformed(3,:), [x,y]);
        digitMarkers(ii-1,:,1,iView) = [x(nnidx),y(nnidx)];
        [~,nnidx] = findFarthestPointFromLine(linepts, [x,y]);
%         [~,nnidx] = findFarthestPoint(pts_transformed(3,:), [x,y]);
        digitMarkers(ii-1,:,3,iView) = [x(nnidx),y(nnidx)];
    end
%     validImageBorderPts(1,:) = squeeze(digitMarkers(firstValidIdx,:,1,iView));
%     validImageBorderPts(2,:) = squeeze(digitMarkers(lastValidIdx,:,1,iView));
%     dorsumRegionMask{iView} = segregateImage(validImageBorderPts, ...
%                                              pts_transformed(3,:), size(digitMasks{iView}));
%     dorsumRegionMask{iView} = segregateImage(pts_transformed(1:2,:), ...
%                                              pts_transformed(3,:), size(digitMasks{iView}));
    
%     dorsumRegionMask{iView} = dorsumRegionMask{iView} & ~whiteFurMask{iView};
    [digitsHull{iView},~] = multiRegionConvexHullMask(digitMasks{iView});
%     dorsumRegionMask{iView} = dorsumRegionMask{iView} & ~digitsHull;
    
end
        
            

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tracks = truncateDigits(tracks, digitMarkers)
%
% INPUTS:
%   digitMarkers - 4x2x3x2 array. First dimension is the digit ID, second
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
    borderPts(1,:) = squeeze(digitMarkers(firstVisibleIdx-1, :, 1, iView));
    borderPts(2,:) = squeeze(digitMarkers(lastVisibleIdx-1, :, 1, iView));
    ptInRegion = squeeze(digitMarkers(lastVisibleIdx-1, :, 3, iView));
    
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
                             1.0  -1.0];  % palm region
        fixed_pts(:,:,2) = [0.0  0.0
                            0.0  2.0
                            1.0  1.0];
    case 'left',
        fixed_pts(:,:,1) = [0.0  0.0    % most radial digit
                            2.0  0.0    % most ulnar digit
                            1.0  -1.0];  % palm region
        fixed_pts(:,:,2) = [1.0  0.0
                            1.0  2.0
                            0.0  1.0];
end

end