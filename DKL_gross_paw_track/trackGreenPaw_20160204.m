function [points3d,points2d] = trackGreenPaw_20160204(video, BGimg_ud, sr_ratInfo, session_mp, triggerTime, initPawMask, boxCalibration, varargin)

h = video.Height;
w = video.Width;

maxFrontPanelSep = 20;
maxRedGreenDist = 20;
minRGDiff = 0.0;
maxDistPerFrame = 20;

% decorrStretchMean = [0.5 0.5 0.5];
% decorrStretchStd  = [0.25 0.25 0.25];

pawHSVrange = [0.33, 0.16, 0.8, 1.0, 0.8, 1.0   % pick out anything that's green and bright
               0.00, 0.16, 0.8, 1.0, 0.8, 1.0     % pick out only red and bright
               0.33, 0.16, 0.6, 1.0, 0.6, 1.0]; % pick out anything green (only to be used just behind the front panel in the mirror view

foregroundThresh = 25/255;

% blob parameters for direct view
pawBlob{1} = vision.BlobAnalysis;
pawBlob{1}.AreaOutputPort = true;
pawBlob{1}.CentroidOutputPort = true;
pawBlob{1}.BoundingBoxOutputPort = true;
pawBlob{1}.LabelMatrixOutputPort = true;
pawBlob{1}.MinimumBlobArea = 100;
pawBlob{1}.MaximumBlobArea = 5000;

% blob parameters for mirror view
pawBlob{2} = vision.BlobAnalysis;
pawBlob{2}.AreaOutputPort = true;
pawBlob{2}.CentroidOutputPort = true;
pawBlob{2}.BoundingBoxOutputPort = true;
pawBlob{2}.LabelMatrixOutputPort = true;
pawBlob{2}.MinimumBlobArea = 100;
pawBlob{2}.MaximumBlobArea = 5000;

% blob parameters for tight thresholding
restrictiveBlob = vision.BlobAnalysis;
restrictiveBlob.AreaOutputPort = true;
restrictiveBlob.CentroidOutputPort = true;
restrictiveBlob.BoundingBoxOutputPort = true;
restrictiveBlob.LabelMatrixOutputPort = true;
restrictiveBlob.MinimumBlobArea = 5;
restrictiveBlob.MaximumBlobArea = 5000;

for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'maxdistperframe',
            maxDistPerFrame = varargin{iarg + 1};
    end
end

if strcmpi(class(BGimg_ud),'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = triggerTime;

srCal = boxCalibration.srCal;

switch pawPref
    case 'left',
        fundMat = srCal.F(:,:,2);
        P2 = srCal.P(:,:,2);
        boxFrontThick = -20;
    case 'right',
        fundMat = srCal.F(:,:,1);
        P2 = srCal.P(:,:,1);
        boxFrontThick = 20;
end
cameraParams = boxCalibration.cameraParams;

boxRegions = boxRegionsfromMatchedPoints(session_mp, [h,w]);

[rpoints3d,rpoints2d,timeList_f] = trackPaw( video, BGimg_ud, fundMat, cameraParams, initPawMask,pawBlob, boxFrontThick, boxRegions, pawPref, P2, 'forward',...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxredgreendist',maxRedGreenDist,...
                                     'minrgdiff',minRGDiff,...
                                     'maxdistperframe',maxDistPerFrame);

video.CurrentTime = triggerTime;
[fpoints3d,fpoints2d,timeList_b] = trackPaw( video, BGimg_ud, fundMat, cameraParams, initPawMask,pawBlob, boxFrontThick, boxRegions, pawPref, P2, 'reverse', ...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxredgreendist',maxRedGreenDist,...
                                     'minrgdiff',minRGDiff,...
                                     'maxdistperframe',maxDistPerFrame);
points3d = rpoints3d;
points2d = rpoints2d;
trigFrame = length(rpoints3d);
for iFrame = 2 : length(fpoints3d);
    points3d{trigFrame + iFrame - 1} = fpoints3d{iFrame};
    points2d{trigFrame + iFrame - 1} = fpoints2d{iFrame};
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [points3d,points2d,timeList] = trackPaw( video, ...
                                             BGimg_ud, ...
                                             fundMat, ...
                                             cameraParams, ...
                                             fullMask, ...
                                             pawBlob, ...
                                             boxFrontThick, ...
                                             boxRegions, ...
                                             pawPref, ...
                                             P2,...
                                             timeDir,...
                                             varargin)

K = cameraParams.IntrinsicMatrix;

frontPanelMask = boxRegions.frontPanelMask;
intMask = boxRegions.intMask;
extMask = boxRegions.extMask;
shelfMask = boxRegions.shelfMask;
belowShelfMask = boxRegions.belowShelfMask;

if strcmpi(timeDir,'reverse')
    numFrames = floor((video.CurrentTime) * video.FrameRate);
    frameCount = numFrames;
else
    numFrames = floor((video.Duration - video.CurrentTime) * video.FrameRate);
    frameCount = 1;
end

h = video.Height;
w = video.Width;
full_bbox = [1 1 w-1 h-1];
full_bbox(2,:) = full_bbox;

maxFrontPanelSep = 20;

maxDistPerFrame = 30;
stretchTol = [0.0 1.0];
foregroundThresh = 45/255;

% blob parameters for tight thresholding
restrictiveBlob = vision.BlobAnalysis;
restrictiveBlob.AreaOutputPort = true;
restrictiveBlob.CentroidOutputPort = true;
restrictiveBlob.BoundingBoxOutputPort = true;
restrictiveBlob.LabelMatrixOutputPort = true;
restrictiveBlob.MinimumBlobArea = 5;
restrictiveBlob.MaximumBlobArea = 10000;

for iarg = 1 : 2 : nargin - 11
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'pawhsvrange',
            pawHSVrange = varargin{iarg + 1};
        case 'maxredgreendist',
            maxRedGreenDist = varargin{iarg + 1};
        case 'minrgdiff',
            minRGDiff = varargin{iarg + 1};
        case 'maxdistperframe',
            maxDistPerFrame = varargin{iarg + 1};
    end
end

orig_maxDistPerFrame = maxDistPerFrame;

points3d = cell(1,numFrames);
points2d = cell(1,numFrames);
matched_points = matchMirrorMaskPoints(fullMask, fundMat);
points2d{frameCount} = matched_points;
% convert matched points to normalized coordinates
mp_norm = zeros(size(matched_points));
for iView = 1 : 2
    mp_norm(:,:,iView) = normalize_points(squeeze(matched_points(:,:,iView)), K);
end
[points3d{frameCount},~,~] = triangulate_DL(mp_norm(:,:,1),mp_norm(:,:,2),eye(4,3),P2);
center3d = zeros(numFrames,3);
center3d(frameCount,:) = mean(points3d{frameCount},1);

prev_image = readFrame(video);
prev_image_ud = undistortImage(prev_image, cameraParams);
prev_image_ud = double(prev_image_ud) / 255;

if strcmpi(timeDir,'reverse')
    video.CurrentTime = video.CurrentTime - 2/video.FrameRate;
else
    video.CurrentTime = video.CurrentTime + 1/video.FrameRate;
end
timeList = [];
while video.CurrentTime < video.Duration
%     video.CurrentTime
    timeList = [timeList,video.CurrentTime];
    if strcmpi(timeDir,'reverse')
        frameCount = frameCount - 1;
    else
        frameCount = frameCount + 1;
    end
    fprintf('frame number %d\n',frameCount);
    
    image = readFrame(video);
    image_ud = undistortImage(image, cameraParams);
    image_ud = double(image_ud) / 255;
    
    prevMask = fullMask;
    [fullMask,bbox] = trackNextStep(image_ud,BGimg_ud,fullMask,boxRegions,fundMat,pawPref,...
                             'foregroundthresh',foregroundThresh,...
                             'pawhsvrange',pawHSVrange,...
                             'maxredgreendist',maxRedGreenDist,...
                             'minrgdiff',minRGDiff,...
                             'resblob',restrictiveBlob,...
                             'stretchtol',stretchTol,...
                             'boxfrontthick',boxFrontThick,...
                             'maxdistperframe',maxDistPerFrame);
                       
	maxDistPerFrame = orig_maxDistPerFrame;
	% if the mask isn't visible in either view, start with the 3d points
	% from the previous n frames, and predict where the paw should be.
	% Then, project it into the missing view
    if ~any(fullMask{1}(:)) || ~any(fullMask{2}(:))
        if ~any(fullMask{1}(:)) && any(fullMask{2}(:))
            % object visible in side view but not direct view
            visibleView = 2;
            F = fundMat';
            hiddenView = 3 - visibleView;
            projMask = projMaskFromTangentLines(fullMask{visibleView},F, [1 1 w-1 h-1], [h,w]);
            fullMask{hiddenView} = projMask & prevMask{hiddenView};
            fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);
            
            temp = bwconvhull(fullMask{visibleView});
            temp_ext = bwmorph(temp,'remove');
            [y,x] = find(temp_ext);
            points2d{frameCount} = NaN(length(y),2,2);
            points2d{frameCount}(:,1,visibleView) = x;
            points2d{frameCount}(:,2,visibleView) = y;
        elseif any(fullMask{1}(:)) && ~any(fullMask{2}(:))
            % object visible in direct view but not mirror view
            visibleView = 1;
            F = fundMat';
            hiddenView = 3 - visibleView;
            projMask = projMaskFromTangentLines(fullMask{visibleView},F, [1 1 w-1 h-1], [h,w]);
            fullMask{hiddenView} = projMask & prevMask{hiddenView};
            fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);
            
            temp = bwconvhull(fullMask{visibleView});
            temp_ext = bwmorph(temp,'remove');
            [y,x] = find(temp_ext);
            points2d{frameCount} = NaN(length(y),2,2);
            points2d{frameCount}(:,1,visibleView) = x;
            points2d{frameCount}(:,2,visibleView) = y;
        else   % not visible in either view, expand region to look in next frame
            fullMask = prevMask;
            maxDistPerFrame = 2 * maxDistPerFrame;
        end
    else
        % only calculate 3d points if visible in both views
        matched_points = matchMirrorMaskPoints(fullMask, fundMat);
        points2d{frameCount} = matched_points;
        % convert matched points to normalized coordinates
        mp_norm = zeros(size(matched_points));
        for iView = 1 : 2
            mp_norm(:,:,iView) = normalize_points(squeeze(matched_points(:,:,iView)), K);
        end
        [points3d{frameCount},~,~] = triangulate_DL(mp_norm(:,:,1),mp_norm(:,:,2),eye(4,3),P2);
        center3d(frameCount,:) = mean(points3d{frameCount},1);
        
    end
  
    showTracking(image_ud,fullMask,bbox);


%     for iView = 1 : 2
%         mask_outline = bwmorph(fullMask{iView},'remove');
%         [y,x] = find(mask_outline);
%         edge_pts{frameCount,iView} = [x,y];
%     end
%     
%     figure(1);
%     imshow(image_ud);
%     hold on
%     rectangle('position',bbox(1,:));
%     rectangle('position',bbox(2,:));
%     plot(edge_pts{frameCount,1}(:,1),edge_pts{frameCount,1}(:,2),'marker','.','linestyle','none')
%     plot(edge_pts{frameCount,2}(:,1),edge_pts{frameCount,2}(:,2),'marker','.','linestyle','none')
%     
    if strcmpi(timeDir,'reverse')
        video.CurrentTime = video.CurrentTime - 2/video.FrameRate;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function tracks = initGreenPawTracks()
%     % create an empty array of tracks
%     tracks = struct(...
%         'id', {}, ...
%         'bbox', {}, ...
%         'color', {}, ...
%         'digitmask1', {}, ...
%         'digitmask2', {}, ...
%         'digitmask3', {}, ...
%         'prevmask1', {}, ...
%         'prevmask2', {}, ...
%         'prevmask3', {}, ...
%         'meanHSV', {}, ...
%         'stdHSV', {}, ...
%         'markers3D', {}, ...
%         'prev_markers3D', {}, ...
%         'currentDigitMarkers', {}, ...
%         'previousDigitMarkers', {}, ...
%         'age', {}, ...
%         'isvisible', {}, ...
%         'markersCalculated', {}, ...
%         'totalVisibleCount', {}, ...
%         'consecutiveInvisibleCount', {});
% end