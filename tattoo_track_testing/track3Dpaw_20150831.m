function centroids = track3Dpaw_20150831(video, ...
                                         BGimg_ud, ...
                                         refImageTime, ...
                                         initDigitMasks, ...
                                         init_mask_bbox, ...
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

min_h_range = 0.05;
min_s_range = 0.20;
min_v_range = 0.10;
num_h_stds = 3;
num_s_stds = 3;
num_v_stds = 3;

diff_threshold = 45;
maxDistPerFrame = 20;
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

blueBeadMask = boxMarkers.beadMasks(:,:,3);

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
             0.45  0.16];   % dark green
         
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
digitBlob{2}.MinimumBlobArea = 50;
digitBlob{2}.MaximumBlobArea = 30000;


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
    end
end

if diff_threshold > 1
    diff_threshold = diff_threshold / 255;
end

[~, center_region_mask] = reach_region_mask(boxMarkers, [h,w]);

switch pawPref
    case 'left',
        dMirrorIdx = 3;   % index of mirror with dorsal view of paw
        pMirrorIdx = 1;   % index of mirror with palmar view of paw
        F_side = F.right;
        P2 = P.right;
        scale = boxCalibration.scale(2);
    case 'right',
        dMirrorIdx = 1;   % index of mirror with dorsal view of paw
        pMirrorIdx = 3;   % index of mirror with palmar view of paw
        F_side = F.left;
        P2 = P.left;
        scale = boxCalibration.scale(1);
end
% make the first view the direct view, the second view is the mirror view
P1 = eye(4,3);
digitMasks = cell(2,1);
digitMasks{1} = initDigitMasks{2};
digitMasks{2} = initDigitMasks{dMirrorIdx};
mask_bbox = zeros(2,4);
mask_bbox(1,:) = init_mask_bbox(2,:);
mask_bbox(2,:) = init_mask_bbox(dMirrorIdx,:);

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = refImageTime;
image = readFrame(video);
image_ud = undistortImage(image, boxCalibration.cameraParams);
image_ud = double(image_ud) / 255;

% initialize one track each for the dorsum of the paw and each digit in the
% mirror and center views

tracks = initializeTracks();
numTracks = 0;

s = struct('Centroid', {}, ...
           'BoundingBox', {});
num_elements_to_track = size(digitMasks{2}, 3);
meanHSV = zeros(2,num_elements_to_track,3);
stdHSV = zeros(2,num_elements_to_track,3);
isVisible = false(num_elements_to_track, 2);
totalVisCount = zeros(num_elements_to_track, 2);
consecInvisibleCount = zeros(num_elements_to_track, 2);
for ii = 1 : num_elements_to_track

    for iView = 1 : 2

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
                calcHSVstats(paw_hsv, digitMask);
            
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
            stdHSV(iView,ii,1) = hueLimits(colorIdx,2) / num_h_stds;
            meanHSV(iView,ii,2) = mean(satLimits(ii,:),2);
            stdHSV(iView,ii,2) = range(satLimits(ii,:)) / num_s_stds;
            meanHSV(iView,ii,3) = mean(valLimits(ii,:),2);
            stdHSV(iView,ii,3) = range(valLimits(ii,:)) / num_v_stds;
            
        end
    end
    
end

mp1 = [s(1,:).Centroid]; mp2 = [s(2,:).Centroid];
mp1 = reshape(mp1,[2 num_elements_to_track])';
mp2 = reshape(mp2,[2 num_elements_to_track])';
mp1_norm = normalize_points(mp1, K);
mp2_norm = normalize_points(mp2, K);

% what will points3d be if one of the digits is missing from one of the
% views?
[points3d,~,~] = triangulate_DL(mp1_norm, mp2_norm, P1, P2);    % multiply by scale factor to get real 3d coordinates w.r.t. the direct camera view

tracks = initializeTracks();
for ii = 1 : num_elements_to_track
    
    bbox = [s(:,ii).BoundingBox];
    bbox = reshape(bbox,[4,2])';
    newTrack = struct(...
        'id', ii, ...
        'bbox', bbox, ...
        'digitmask1', squeeze(digitMasks{1}(:,:,ii)), ...
        'digitmask2', squeeze(digitMasks{2}(:,:,ii)), ...
        'meanHSV', squeeze(meanHSV(:,ii,:)), ...
        'stdHSV', squeeze(stdHSV(:,ii,:)), ...
        'centroid3D', points3d(ii,:), ...
        'age', 1, ...
        'isvisible', isVisible(ii,:), ...
        'totalVisibleCount', totalVisCount(ii,:), ...
        'consecutiveInvisibleCount', consecInvisibleCount(ii,:));
    tracks(ii) = newTrack;
        
end

% now that tracks are initialized, do the actual tracking
paw_hsv = cell(1,2);
HSVlimits = zeros(num_elements_to_track-1, 6, 2);
while video.CurrentTime < video.Duration
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
    prev_mask_bbox = mask_bbox;
    prev_paw_mask = false(h,w);
    
    prev_paw_mask(prev_mask_bbox(1,2) : prev_mask_bbox(1,2) + prev_mask_bbox(1,4),...
                  prev_mask_bbox(1,1) : prev_mask_bbox(1,1) + prev_mask_bbox(1,3)) = tracks(num_elements_to_track).digitmask1;
    prev_paw_mask(prev_mask_bbox(2,2) : prev_mask_bbox(2,2) + prev_mask_bbox(2,4),...
                  prev_mask_bbox(2,1) : prev_mask_bbox(2,1) + prev_mask_bbox(2,3)) = tracks(num_elements_to_track).digitmask2;

	% find overlap between previous mask and current mask, and keep those
    % parts of the background mask that overlapped with the previous mask
    overlapMask = prev_paw_mask & BG_mask;
    BG_mask = imreconstruct(overlapMask, BG_mask);
%     BG_mask = imdilate(BG_mask,strel('disk',10));

    % will eventually need code here to deal with partial occlusions of the
    % full paw mask
    current_paw_mask{1} = center_region_mask & BG_mask;
    current_paw_mask{2} = ~center_region_mask & BG_mask;
    projMask = pawProjectionMask(current_paw_mask{2}, F_side', [h,w]);
    projMask = imdilate(projMask,strel('disk',10));
    current_paw_mask{1} = current_paw_mask{1} & projMask;
    
    for iView = 1 : 2
        s = regionprops(current_paw_mask{iView},'BoundingBox');
        mask_bbox(iView,:) = floor(s.BoundingBox) - 10;
        mask_bbox(iView,3:4) = mask_bbox(iView,3:4) + 30;
        
        tempMask = current_paw_mask{iView};
        current_paw_mask{iView} = tempMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                           mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
        paw_hsv{iView} = zeros(mask_bbox(iView,4)+1,mask_bbox(iView,3)+1,3,num_elements_to_track);
    end
    % now, get rid of all the bits that are too small, the wrong shape, 
    % etc. This is where we need to start thinking about what to do when
    % the paw passes behind the edge of the box and there will be two paw 
    % parts. A model of the paw might solve this problem, but would like to 
    % get away with doing this without one...
    
    for ii = 1 : num_elements_to_track
        
        for iView = 1 : 2
            paw_img = image_ud(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                               mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3),:);
            paw_enh = enhanceColorImage(paw_img, ...
                                        decorrStretchMean{iView}(ii,:), ...
                                        decorrStretchSigma{iView}(ii,:), ...
                                        'mask',current_paw_mask{iView});
            hsvMask = double(repmat(current_paw_mask{iView},1,1,3));
            paw_hsv{iView}(:,:,:,ii) = rgb2hsv(hsvMask .* paw_enh);
            
            if ii < num_elements_to_track
                % set hsv thresholds based on previous hsv means and standard
                % deviations
                HSVlimits(ii,1,iView) = tracks(ii).meanHSV(iView,1);            % hue mean
                HSVlimits(ii,2,iView) = max(min_h_range, tracks(ii).stdHSV(iView,1) * num_h_stds);  % hue range

                s_range = max(min_s_range/2, tracks(ii).stdHSV(iView,2) * num_s_stds);
                HSVlimits(ii,3,iView) = max(0.001, tracks(ii).meanHSV(iView,2) - s_range);    % saturation lower bound
                HSVlimits(ii,4,iView) = min(1.000, tracks(ii).meanHSV(iView,2) + s_range);    % saturation upper bound

                v_range = max(min_v_range/2, tracks(ii).stdHSV(iView,3) * num_v_stds);
                HSVlimits(ii,5,iView) = max(0.001, tracks(ii).meanHSV(iView,3) - v_range);    % saturation lower bound
                HSVlimits(ii,6,iView) = min(1.000, tracks(ii).meanHSV(iView,3) + v_range);    % saturation upper bound            
            end
        end
    end
    
    % now do the thresholding
    isDigitVisible = true(num_elements_to_track,2);
    for ii = 2 : num_elements_to_track - 1    % do the digits first
        
        sameColIdx = find(strcmp(colorList{ii},colorList));
        numSameColorObjects = length(sameColIdx);
        
        for iView = 1 : 2
            tempMask = HSVthreshold(squeeze(paw_hsv{iView}(:,:,:,ii)), ...
                                    HSVlimits(ii,:,iView));
                                
            if ~any(tempMask(:))
                isDigitVisible(ii, iView) = false;
                tracks(ii).isvisible(iView) = false;
                tracks(ii).consecutiveInvisibleCount(iView) = 1;
                break;
            end
                 
            if strcmpi(colorList{ii},'blue')
                bbox_blueBeadMask = blueBeadMask(mask_bbox(iView,2) : mask_bbox(iView,2) + mask_bbox(iView,4), ...
                                                 mask_bbox(iView,1) : mask_bbox(iView,1) + mask_bbox(iView,3));
                % eliminate any identified blue regions that overlap with blue
                % beads
                tempMask = tempMask & ~bbox_blueBeadMask;% squeeze(boxMarkers.beadMasks(:,:,3));
            end
            
            SE = strel('disk',2);
            tempMask = imopen(tempMask, SE);
            tempMask = imclose(tempMask, SE);
            tempMask = imfill(tempMask, 'holes');
            
            [A,~,~,~,labMat] = step(digitBlob{iView}, tempMask);
            if isempty(A)
                isDigitVisible(ii, iView) = false;
                tracks(ii).isvisible(iView) = false;
                tracks(ii).consecutiveInvisibleCount(iView) = ...
                    tracks(ii).consecutiveInvisibleCount(iView) + 1;
                break;
            end
            % take at most the numSameColorObjects largest blobs
            [~,idx] = sort(A, 'descend');
            tempMask = false(size(tempMask));
            for kk = 1 : min(numSameColorObjects, length(idx))
                tempMask = tempMask | (labMat == idx(kk));
            end
            
            if length(A) == 1 && numSameColorObjects == 1
                % verify that this blob is consistent with the previously found blob for this digit
                % for now, assume it's correct
                s = regionprops(tempMask,'BoundingBox');
                if iView == 1
                    tracks(ii).digitmask1 = tempMask;
                else
                    tracks(ii).digitmask2 = tempMask;
                end
                [meanHSV, stdHSV] = calcHSVstats(paw_hsv, digitMask);
                tracks(ii).meanHSV(iView,:) = meanHSV;
                tracks(ii).stdHSV(iView,:) = stdHSV;
                tracks(ii).age = tracks(ii).age + 1;
                tracks(ii).isvisible(iView) = true;
                tracks(ii).totalVisibleCount(iView) = ...
                    tracks(ii).totalVisibleCount(iView) + 1;
                tracks(ii).consecutiveInvisibleCount(iView) = 0;
                
                continue;
            end
            otherTrackIdx = sameColIdx(sameColIdx ~= ii);
            if length(A) == 2    % need to figure out which blob to assign to the current track

                blobID = selectBlobForTrack(tempMask, ...
                                            paw_hsv, ...
                                            tracks(ii), ...
                                            tracks(otherTrackIdx), ...
                                            iView, ...
                                            prev_mask_bbox(iView,:), ...
                                            mask_bbox(iView,:));

            else     % length(A) = 1, need to figure out whether the blob belongs to the current
                     % digit, or the other one that's the same color
                
                trackID = selectTrackForBlob(tempMask, paw_hsv, tracks(ii), tracks(otherTrackIdx));
                
            end

        end
    end
       
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
             0.45  0.16];   % dark green
                        tempMask = HSVthreshold(squeeze(masked_hsv_enh{iView}(:,:,:,ii)), ...
                                        [hueLimits(colorIdx,:), satLimits(ii,:), valLimits(ii,:)]);
        masked_mirror_hsv = rgb2hsv(masked_mirror_img_enh);

        masked_center_img_enh = enhanceColorImage(masked_center_img, ...
                                                  decorrStretchMean_center(ii,:), ...
                                                  decorrStretchSigma_center(ii,:), ...
                                                  'mask',prev_paw_mask_center);
        masked_center_hsv = rgb2hsv(masked_center_img_enh);
        
        mirror_bbox = step(tracks(ii).CAMshiftTracker, masked_mirror_hsv(:,:,1));
        center_bbox = step(tracks(ii+num_elements_to_track).CAMshiftTracker, masked_center_hsv(:,:,1));
        
        figure(1)
        rectangle('position',mirror_bbox,'edgecolor','r');
        rectangle('position',center_bbox,'edgecolor','r');
        
        figure(2)
        if ii == 1
            imshow(masked_mirror_img_enh)
        end
        rectangle('position',mirror_bbox,'edgecolor','r');
        
        figure(3)
        if ii == 1
            imshow(masked_center_img_enh)
        end
        rectangle('position',center_bbox,'edgecolor','r');
    
% <<<<<<< HEAD
    masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...
                                              decorrStretchMean_mirror(2,:), ...
                                              decorrStretchSigma_mirror(2,:), ...
                                              'mask',prev_paw_mask_center);
    [~,mirror_P] = imseggeodesic(masked_mirror_img_enh, mirror_zmask(:,:,2), mirror_zmask(:,:,3), mirror_zmask(:,:,4));
    [~,mirror_P2] = imseggeodesic(masked_mirror_img_enh, mirror_zmask(:,:,3), mirror_zmask(:,:,4), mirror_zmask(:,:,5));
    
    masked_center_img_enh = enhanceColorImage(masked_center_img, ...
                                              decorrStretchMean_center(2,:), ...
                                              decorrStretchSigma_center(2,:), ...
                                              'mask',prev_paw_mask_center);
    [~,center_P] = imseggeodesic(masked_center_img_enh, center_zmask(:,:,2), center_zmask(:,:,3), center_zmask(:,:,4));
    [~,center_P2] = imseggeodesic(masked_center_img_enh, center_zmask(:,:,3), center_zmask(:,:,4), center_zmask(:,:,5));
        
    mirrorMask = false(h,w,num_elements_to_track);
    centerMask = false(h,w,num_elements_to_track);
    SE = strel('disk',2);
    for ii = 2 : num_elements_to_track
        switch ii,
            case 2,   % index finger
                mirrorMask(:,:,ii) = (mirror_P(:,:,1) > pthresh);
                centerMask(:,:,ii) = (center_P(:,:,1) > pthresh);
            case 3,   % middle finger
                mirrorMask(:,:,ii) = (mirror_P(:,:,2) > pthresh);
                centerMask(:,:,ii) = (center_P(:,:,2) > pthresh);
            case 4,   % ring finger
                mirrorMask(:,:,ii) = (mirror_P2(:,:,2) > pthresh);
                centerMask(:,:,ii) = (center_P2(:,:,2) > pthresh);
            case 5,   % pinky finger
                mirrorMask(:,:,ii) = (mirror_P2(:,:,3) > pthresh);
                centerMask(:,:,ii) = (center_P2(:,:,3) > pthresh);
        end
    
        mirrorMask(:,:,ii) = imopen(mirrorMask(:,:,ii), SE);
        mirrorMask(:,:,ii) = imclose(mirrorMask(:,:,ii), SE);
        mirrorMask(:,:,ii) = imfill(mirrorMask(:,:,ii), 'holes');
        
        centerMask(:,:,ii) = imopen(centerMask(:,:,ii), SE);
        centerMask(:,:,ii) = imclose(centerMask(:,:,ii), SE);
        centerMask(:,:,ii) = imfill(centerMask(:,:,ii), 'holes');
        
    end
    

    
    masked_mirror_img_enh = enhanceColorImage(masked_mirror_img, ...    % for paw dorsum
                                              decorrStretchMean_center(1,:), ...
                                              decorrStretchSigma_center(1,:), ...
                                              'mask',prev_paw_mask_center);
        
        
%         mirror_idx = find(mirror_bboxMask);
%         center_idx = find(center_bboxMask);
%         
%         RGBdist = zeros(h,w);
%         for jj = 1 : 3
%             masked_mirror_img_enh(mirror_bbox(2):mirror_bbox(2)+mirror_bbox(4)-1,...
%                         mirror_bbox(1):mirror_bbox(1)+mirror_bbox(3)-1)
%             colPlane = squeeze(masked_mirror_img_enh(:,:,jj));
%             mirror_RGBdist(jj) = colPlane(mirror_idx) - tracks(ii).meanRGBenh(jj);
%             
%             colPlane = squeeze(masked_center_img_enh(:,:,jj));
%             center_RGBdist(jj) = colPlane(center_idx) - tracks(ii+num_elements_to_track).meanRGBenh(jj);
%         end
% %         mirror_RGBdist = 
%         figure(1)
%         rectangle('position',mirror_bbox,'edgecolor','r');
%         rectangle('position',center_bbox,'edgecolor','r');
%         
%         figure(2)
%         if ii == 1
%             imshow(masked_mirror_img_enh)
%         end
%         rectangle('position',mirror_bbox,'edgecolor','r');
%         
%         figure(3)
%         if ii == 1
%             imshow(masked_center_img_enh)
%         end
%         rectangle('position',center_bbox,'edgecolor','r');
    
% =======
% >>>>>>> origin/master
        
%     paw_mask = maskPaw_moving(image, BGimg, prev_paw_mask, register_ROI, F, rat_metadata, boxMarkers);
%     diff_image  = imabsdiff(image, BGimg);
%     thresh_mask = (rgb2gray(diff_image) > diff_threshold);
%     
%     curr_mask = thresh_mask & prev_paw_mask;
%     
%     hsv_image = rgb2hsv(image.*uint8(repmat(curr_mask,1,1,3)));
%     figure(1)
%     imshow(image)
%     hold on

%     for ii = 1 : numTracks
%         bbox = step(tracks(ii).CAMshiftTracker, hsv_image(:,:,1));
%         rectangle('position',bbox,'edgecolor','r');
%     end
%     paw_mask = maskPaw_moving(image, BGimg, digitMirrorMask_dorsum, digitCenterMask, register_ROI, F, rat_metadata, boxMarkers);
    
    
%     figure(2)
%     imshow(image);
end
% detector = vision.ForegroundDetector(...
%    'NumTrainingFrames', 50, ... % 5 because of short video
%    'InitialVariance', 30*30); % initial standard deviation of 30
blob = vision.BlobAnalysis(...
   'CentroidOutputPort', false, 'AreaOutputPort', false, ...
   'BoundingBoxOutputPort', true, ...
   'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 200);

sTime = (peakFrameNum / video.FrameRate);
figure(1)
frameNum = 0;
while video.CurrentTime < video.Duration
    image = readFrame(video);
    fgMask = step(detector, image);
    imshow(fgMask);
    frameNum = frameNum + 1;
end
mirrorTracks_dorsum = initializeTracks();
centerTracks        = initializeTracks();

% rewind 
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
        'meanHSV', {}, ...
        'stdHSV', {}, ...
        'centroid3D', {}, ...
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

homogeneous_points = [points2d,ones(size(points2d,1),1)];
normalized_points  = (K' \ homogeneous_points')';
normalized_points = bsxfun(@rdivide,normalized_points(:,1:2),normalized_points(:,3));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [meanHSV, stdHSV] = calcHSVstats(paw_hsv, digitMask)

    idx = squeeze(digitMask);
    idx = idx(:);
    for jj = 1 : 3
        colPlane = squeeze(paw_hsv(:,:,jj));
        colPlane = colPlane(:);
        if jj == 1
            meanAngle = wrapTo2Pi(circ_mean(colPlane(idx)*2*pi));
            stdAngle = wrapTo2Pi(circ_std(colPlane(idx)*2*pi));
            meanHSV(iView,ii,jj) = meanAngle / (2*pi);
            stdHSV(iView,ii,jj) = stdAngle / (2*pi);
        else
            meanHSV(iView,ii,jj) = mean(colPlane(idx));
            stdHSV(iView,ii,jj) = std(colPlane(idx));
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
        
        

%     prev_bbox = track.bbox(iView,:);
%     prev_bbox(1:2) = prev_bbox(1:2) - mask_bbox(iView,1:2) + 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mp1, mp2] = points3d_to_images(points3d, P1, P2, K)

end