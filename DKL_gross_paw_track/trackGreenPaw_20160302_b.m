function [points3d,points2d,timeList,isPawVisible] = trackGreenPaw_20160302(video, BGimg_ud, sr_ratInfo, session_mp, triggerTime, initPawMask, boxCalibration, boxRegions, varargin)

h = video.Height;
w = video.Width;

maxFrontPanelSep = 20;
maxRedGreenDist = 20;
minRGDiff = 0.0;
maxDistPerFrame = 20;

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

for iarg = 1 : 2 : nargin - 8
    switch lower(varargin{iarg})
        case 'pawgraylevels',
            pawGrayLevels = varargin{iarg + 1};
        case 'pixelcountthreshold',
            pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'maxdistperframe',
            maxDistPerFrame = varargin{iarg + 1};
        case 'hsvlimits',
            pawHSVrange = varargin{iarg + 1};
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

[fpoints3d,fpoints2d,timeList_f,isPawVisible_f] = trackPaw( video, BGimg_ud, fundMat, cameraParams, initPawMask,pawBlob, boxFrontThick, boxRegions, pawPref, P2, 'forward',...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxredgreendist',maxRedGreenDist,...
                                     'minrgdiff',minRGDiff,...
                                     'maxdistperframe',maxDistPerFrame);

video.CurrentTime = triggerTime;
[rpoints3d,rpoints2d,timeList_b,isPawVisible_b] = trackPaw( video, BGimg_ud, fundMat, cameraParams, initPawMask,pawBlob, boxFrontThick, boxRegions, pawPref, P2, 'reverse', ...
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
timeList = [timeList_b,timeList_f(2:end)];
isPawVisible = [isPawVisible_b;isPawVisible_f(2:end,:)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [points3d,points2d,timeList,isPawVisible] = trackPaw( video, ...
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

zeroTol = 1e-10;
fps = video.FrameRate;

greenMask = fullMask;

K = cameraParams.IntrinsicMatrix;

if strcmpi(timeDir,'reverse')
    numFrames = round((video.CurrentTime) * fps);
    frameCount = numFrames;
else
    numFrames = round((video.Duration - video.CurrentTime) * fps);
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

timeList(frameCount) = video.CurrentTime;
image = readFrame(video);   % just to advance one frame for forward direction
image_ud = undistortImage(image, cameraParams);
image_ud = double(image_ud) / 255;
orig_BGimg_ud = BGimg_ud;
image_ud = color_adapthisteq(image_ud);

BGimg_ud = color_adapthisteq(BGimg_ud);

isPawVisible = false(frameCount,2);
isPawVisible(frameCount,:) = true(1,2);   % by definition (almost), paw is visible in both views in the initial frame
while video.CurrentTime < video.Duration && video.CurrentTime >= 0

    prevFrame = frameCount;
    
    if strcmpi(timeDir,'reverse')
        frameCount = frameCount - 1;
        if frameCount == 0
            break;
        end
        video.CurrentTime = frameCount / fps;
    else
        frameCount = frameCount + 1;
    end
    fprintf('frame number %d\n',frameCount);
    
    image = readFrame(video);
    if strcmpi(timeDir,'reverse')
        if abs(video.CurrentTime - timeList(prevFrame)) > zeroTol    % a frame was skipped
            % if going backwards, went one too many frames back, so just
            % read the next frame
            image = readFrame(video);
        end
    end
    if strcmpi(timeDir,'forward') && ...
       abs(video.CurrentTime - timeList(prevFrame) - 2/fps) > zeroTol && ...
       video.CurrentTime - timeList(prevFrame) - 2/fps < 0
            % if going forwards, this means the CurrentTime didn't advance
            % by 1/fps on the last read (not sure why this occasionally
            % happens - some sort of rounding error)
            timeList(frameCount) = video.CurrentTime;
    else           
        timeList(frameCount) = video.CurrentTime - 1/fps;
    end
    prev_image_ud = image_ud;
    image_ud = undistortImage(image, cameraParams);
    image_ud = double(image_ud) / 255;
    orig_image_ud = image_ud;
    image_ud = color_adapthisteq(image_ud);
    
    prevMask = fullMask;
    prev_greenMask = greenMask;
%     [fullMask,bbox] = trackNextStep_20160217(image_ud,BGimg_ud,fullMask,boxRegions,fundMat,pawPref,...
%                              'foregroundthresh',foregroundThresh,...
%                              'pawhsvrange',pawHSVrange,...
%                              'maxredgreendist',maxRedGreenDist,...
%                              'minrgdiff',minRGDiff,...
%                              'resblob',restrictiveBlob,...
%                              'stretchtol',stretchTol,...
%                              'boxfrontthick',boxFrontThick,...
%                              'maxdistperframe',maxDistPerFrame);
         
    [fullMask,greenMask,bbox] = trackNextStep_20160303(image_ud,prev_image_ud,BGimg_ud,fullMask,greenMask,boxRegions,fundMat,pawPref,...
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
            isPawVisible(frameCount,:) = [false,true];
            % object visible in side view but not direct view
            visibleView = 2;
            F = fundMat';
            hiddenView = 3 - visibleView;
            projMask = projMaskFromTangentLines(fullMask{visibleView},F, [1 1 w-1 h-1], [h,w]);
            fullMask{hiddenView} = projMask & prevMask{hiddenView};
            if ~any(fullMask{hiddenView}(:))
                fullMask{hiddenView} = prevMask{hiddenView};
            end
            fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);
            
            temp = bwconvhull(fullMask{visibleView});
            temp_ext = bwmorph(temp,'remove');
            [y,x] = find(temp_ext);
            points2d{frameCount} = NaN(length(y),2,2);
            points2d{frameCount}(:,1,visibleView) = x;
            points2d{frameCount}(:,2,visibleView) = y;
        elseif any(fullMask{1}(:)) && ~any(fullMask{2}(:))
            isPawVisible(frameCount,:) = [true,false];
            % object visible in direct view but not mirror view
            visibleView = 1;
            F = fundMat';
            hiddenView = 3 - visibleView;
            projMask = projMaskFromTangentLines(fullMask{visibleView},F, [1 1 w-1 h-1], [h,w]);
            fullMask{hiddenView} = projMask & prevMask{hiddenView};
            if ~any(fullMask{hiddenView}(:))
                fullMask{hiddenView} = prevMask{hiddenView};
            end
            fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);
            
            temp = bwconvhull(fullMask{visibleView});
            temp_ext = bwmorph(temp,'remove');
            [y,x] = find(temp_ext);
            points2d{frameCount} = NaN(length(y),2,2);
            points2d{frameCount}(:,1,visibleView) = x;
            points2d{frameCount}(:,2,visibleView) = y;
        else   % not visible in either view, expand region to look in next frame
            isPawVisible(frameCount,:) = [false,false];
            fullMask = prevMask;
            maxDistPerFrame = 2 * maxDistPerFrame;
        end
    else
        isPawVisible(frameCount,:) = [true,true];
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
  
    % ****** UNCOMMENT LINE BELOW TO MONITOR TRACKING AS ITS PERFORMED
%     showTracking(image_ud,fullMask,bbox);

end

end 