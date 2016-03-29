function [points3d,points2d,timeList,isPawVisible] = trackDirectView( video, triggerTime, initPawMask, mirror_points2d, BGimg_ud, sr_ratInfo, boxRegions, boxCalibration,varargin )

video.CurrentTime = triggerTime;

targetMean = [0.5,0.2,0.5];
targetSigma = [0.2,0.2,0.2];

foregroundThresh = 25/255;

pawHSVrange = [0.33, 0.05, 0.95, 1.0, 0.95, 1.0   % pick out anything that's green and bright
               0.33, 0.05, 0.98, 1.0, 0.98, 1.0     % pick out anything that's green and bright immediately behind the front panel
               0.50, 0.50, 0.95, 1.0, 0.95, 1.0
               0.00, 0.16, 0.90, 1.0, 0.90, 1.0       % find red objects
               0.33, 0.10, 0.9, 1.0, 0.9, 1.0];  % liberal green mask

maxDistPerFrame = 20;
whiteThresh = 0.8;

% blob parameters for mirror view
pawBlob = vision.BlobAnalysis;
pawBlob.AreaOutputPort = true;
pawBlob.CentroidOutputPort = true;
pawBlob.BoundingBoxOutputPort = true;
pawBlob.LabelMatrixOutputPort = true;
pawBlob.MinimumBlobArea = 100;
pawBlob.MaximumBlobArea = 4000;

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
        case 'targetmean',
            targetMean = varargin{iarg + 1};
        case 'targetsigma',
            targetSigma = varargin{iarg + 1};
        case 'pawblob',
            pawBlob = varargin{iarg + 1};
        case 'whitethresh',
            whiteThresh = varargin{iarg + 1};
    end
end



if strcmpi(class(BGimg_ud),'uint8')
    BGimg_ud = double(BGimg_ud) / 255;
end

pawPref = lower(sr_ratInfo.pawPref);
if iscell(pawPref)
    pawPref = pawPref{1};
end

srCal = boxCalibration.srCal;

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = triggerTime;

orig_BGimg_ud = BGimg_ud;
BGimg_ud = color_adapthisteq(BGimg_ud);

greenBGmask = findGreenBG(BGimg_ud, boxRegions,targetMean(1,:),targetSigma(1,:),pawHSVrange(1,:));


% frontPanelWidth = panelWidthFromMask(boxRegions.frontPanelMask);
[fpoints2d, fpoints3d, timeList_f,isPawVisible_f] = trackPaw_direct_local( video, BGimg_ud, greenBGmask, initPawMask{1},mirror_points2d,pawBlob, boxRegions, pawPref, 'forward',boxCalibration,...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxdistperframe',maxDistPerFrame,...
                                     'targetmean',targetMean,...
                                     'targetsigma',targetSigma,...
                                     'whitethresh',whiteThresh);
                                 
video.CurrentTime = triggerTime;

[rpoints2d, rpoints3d, timeList_b,isPawVisible_b] = trackPaw_direct_local( video, BGimg_ud, greenBGmask, initPawMask{1},mirror_points2d,pawBlob, boxRegions, pawPref, 'reverse',boxCalibration,...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxdistperframe',maxDistPerFrame,...
                                     'targetmean',targetMean,...
                                     'targetsigma',targetSigma,...
                                     'whitethresh',whiteThresh);
                                 
   
points2d = rpoints2d;
points3d = rpoints3d;
trigFrame = round(triggerTime * video.FrameRate);
for iFrame = trigFrame : length(fpoints2d)
    points2d{iFrame} = fpoints2d{iFrame};
    points3d{iFrame} = fpoints3d{iFrame};
end

srCal = boxCalibration.srCal;
switch pawPref
    case 'left',
        fundMat = srCal.F(:,:,2);
        P2 = srCal.P(:,:,2);
    case 'right',
        fundMat = srCal.F(:,:,1);
        P2 = srCal.P(:,:,1);
end
cameraParams = boxCalibration.cameraParams;
K = cameraParams.IntrinsicMatrix;

matched_points = matchMirrorMaskPoints(initPawMask, fundMat);
points2d{trigFrame} = matched_points;
mp_norm = zeros(size(matched_points));
for iView = 1 : 2
    mp_norm(:,:,iView) = normalize_points(squeeze(matched_points(:,:,iView)), K);
end
[points3d{trigFrame},~,~] = triangulate_DL(mp_norm(:,:,1),mp_norm(:,:,2),eye(4,3),P2);
        
timeList = [timeList_b,timeList_f(2:end)];
isPawVisible = isPawVisible_b | isPawVisible_f;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [points2d,points3d,timeList,isPawVisible] = trackPaw_direct_local( video, ...
                                    BGimg_ud, ...
                                    greenBGmask, ...
                                    initPawMask, ...
                                    mirror_points2d, ...
                                    pawBlob, ...
                                    boxRegions, ...
                                    pawPref, ...
                                    timeDir, ...
                                    boxCalibration,...
                                    varargin)

zeroTol = 1e-10;
fps = video.FrameRate;

h = video.Height;
w = video.Width;
full_bbox = [1 1 w-1 h-1];
full_bbox(2,:) = full_bbox;

switch lower(pawPref),
    case 'right',
        fundMat = boxCalibration.srCal.F(:,:,1);
    case 'left',
        fundMat = boxCalibration.srCal.F(:,:,2);
end
cameraParams = boxCalibration.cameraParams;
K = cameraParams.IntrinsicMatrix;

if strcmpi(timeDir,'reverse')
    numFrames = round((video.CurrentTime) * fps);
    frameCount = numFrames;
else
    numFrames = round((video.Duration - video.CurrentTime) * fps);
    frameCount = 1;
end
totalFrames = round(video.Duration * fps);

fullMask = cell(1,2);
fullMask{1} = initPawMask;

targetMean = [0.5,0.2,0.5];
    
targetSigma = [0.2,0.2,0.2];

srCal = boxCalibration.srCal;
switch pawPref
    case 'left',
        fundMat = srCal.F(:,:,2);
        P2 = srCal.P(:,:,2);
    case 'right',
        fundMat = srCal.F(:,:,1);
        P2 = srCal.P(:,:,1);
end

for iarg = 1 : 2 : nargin - 10
    switch lower(varargin{iarg})
%         case 'pawgraylevels',
%             pawGrayLevels = varargin{iarg + 1};
%         case 'pixelcountthreshold',
%             pixCountThresh = varargin{iarg + 1};
        case 'foregroundthresh',
            foregroundThresh = varargin{iarg + 1};
        case 'pawhsvrange',
            pawHSVrange = varargin{iarg + 1};
%         case 'maxredgreendist',
%             maxRedGreenDist = varargin{iarg + 1};
%         case 'minrgdiff',
%             minRGDiff = varargin{iarg + 1};
        case 'maxdistperframe',
            maxDistPerFrame = varargin{iarg + 1};
        case 'targetmean',
            targetMean = varargin{iarg + 1};
        case 'targetsigma',
            targetSigma = varargin{iarg + 1};
        case 'whitethresh',
            whiteThresh = varargin{iarg + 1};
    end
end

points2d = cell(totalFrames,1);
points3d = cell(totalFrames,1);

timeList = zeros(1,numFrames);
timeList(frameCount) = video.CurrentTime;
currentFrame = round((video.CurrentTime) * fps);
image = readFrame(video);   % just to advance one frame for forward direction
image_ud = undistortImage(image, cameraParams);
image_ud = double(image_ud) / 255;
image_ud = color_adapthisteq(image_ud);

isPawVisible = false(totalFrames,2);
isPawVisible(currentFrame,:) = true(1,2);   % by definition (almost), paw is visible in both views in the initial frame

temp = bwmorph(bwconvhull(initPawMask),'remove');
[y,x] = find(temp);
points2d{currentFrame} = [x,y];

% framesChecked = 0;
while video.CurrentTime < video.Duration && video.CurrentTime >= 0

    prevFrame = frameCount;
%     framesChecked = framesChecked + 1;
    
    if strcmpi(timeDir,'reverse')
        frameCount = frameCount - 1;
        if frameCount == 0
            break;
        end
        video.CurrentTime = frameCount / fps;
    else
        frameCount = frameCount + 1;
    end
    currentFrame = round((video.CurrentTime) * fps);
    fprintf('frame number %d, current frame %d\n',frameCount, currentFrame);
    
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
    
    prevMask = fullMask{1};
    prevMasks{1} = prevMask;
    prevMasks{2} = fullMask{2};
    cur_points2d = mirror_points2d{currentFrame};
    [fullMask] = trackNextStep_direct(image_ud,prev_image_ud,BGimg_ud,prevMask,cur_points2d,boxRegions,pawPref,fundMat,greenBGmask,...
                             'foregroundthresh',foregroundThresh,...
                             'pawhsvrange',pawHSVrange,...
                             'maxdistperframe',maxDistPerFrame,...
                             'targetmean',targetMean,...
                             'targetsigma',targetSigma,...
                             'whitethresh',whiteThresh,...
                             'foregroundthresh',foregroundThresh);
                         
% 	maxDistPerFrame = orig_maxDistPerFrame;
	% if the mask isn't visible in either view, start with the 3d points
	% from the previous n frames, and predict where the paw should be.
	% Then, project it into the missing view
    if ~any(fullMask{1}(:)) || ~any(fullMask{2}(:))
        if ~any(fullMask{1}(:)) && any(fullMask{2}(:))
            isPawVisible(currentFrame,:) = [false,true];
            % object visible in side view but not direct view
            visibleView = 2;
            F = fundMat';
            hiddenView = 3 - visibleView;
            projMask = projMaskFromTangentLines(fullMask{visibleView},F, [1 1 w-1 h-1], [h,w]);
            fullMask{hiddenView} = projMask & prevMasks{hiddenView};
            if ~any(fullMask{hiddenView}(:))
                fullMask{hiddenView} = prevMasks{hiddenView};
            end
            fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);
            
            temp = bwconvhull(fullMask{visibleView});
            temp_ext = bwmorph(temp,'remove');
            [y,x] = find(temp_ext);
            points2d{currentFrame} = NaN(length(y),2,2);
            points2d{currentFrame}(:,1,visibleView) = x;
            points2d{currentFrame}(:,2,visibleView) = y;
            
            if isPawVisible(lastFrame,1)
                fullMask{1} = imdilate(prevMask,strel('disk',maxDistPerFrame));
            end
        elseif any(fullMask{1}(:)) && ~any(fullMask{2}(:))
            isPawVisible(currentFrame,:) = [true,false];
            % object visible in direct view but not mirror view
            visibleView = 1;
            F = fundMat';
            hiddenView = 3 - visibleView;
            projMask = projMaskFromTangentLines(fullMask{visibleView},F, [1 1 w-1 h-1], [h,w]);
            fullMask{hiddenView} = projMask & prevMasks{hiddenView};
            if ~any(fullMask{hiddenView}(:))
                fullMask{hiddenView} = prevMasks{hiddenView};
            end
            fullMask = estimateHiddenSilhouette(fullMask,full_bbox,fundMat,[h,w]);
            
            temp = bwconvhull(fullMask{visibleView});
            temp_ext = bwmorph(temp,'remove');
            [y,x] = find(temp_ext);
            points2d{currentFrame} = NaN(length(y),2,2);
            points2d{currentFrame}(:,1,visibleView) = x;
            points2d{currentFrame}(:,2,visibleView) = y;
        else   % not visible in either view, expand region to look in next frame
            isPawVisible(currentFrame,:) = [false,false];
            fullMask = prevMasks;
            if isPawVisible(lastFrame,1)
                fullMask{1} = imdilate(prevMask,strel('disk',maxDistPerFrame));
            end
        end
    else
        isPawVisible(currentFrame,:) = [true,true];
        % only calculate 3d points if visible in both views
        matched_points = matchMirrorMaskPoints(fullMask, fundMat);
        points2d{currentFrame} = matched_points;
        % convert matched points to normalized coordinates
        mp_norm = zeros(size(matched_points));
        for iView = 1 : 2
            mp_norm(:,:,iView) = normalize_points(squeeze(matched_points(:,:,iView)), K);
        end
        [points3d{currentFrame},~,~] = triangulate_DL(mp_norm(:,:,1),mp_norm(:,:,2),eye(4,3),P2);
%         center3d(currentFrame,:) = mean(points3d{currentFrame},1);
    end
        
	lastFrame = currentFrame;
%     showTracking(image_ud,fullMask)
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function greenBGmask = findGreenBG(BGimg_ud, boxRegions,targetMean,targetSigma,pawHSVrange)

slotMask = boxRegions.slotMask;
slotMask = imdilate(slotMask,strel('line',6,0)) | imdilate(slotMask,strel('line',6,180));
decorr_BG = decorrstretch(BGimg_ud,'targetmean',targetMean,'targetsigma',targetSigma);
BGhsv = rgb2hsv(decorr_BG);

greenBG = HSVthreshold(BGhsv, pawHSVrange);
greenBGmask = greenBG & slotMask;

end
