function [points2d,timeList,isPawVisible] = trackMirrorView( video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo, boxRegions, boxCalibration, varargin )

video.CurrentTime = triggerTime;

targetMean = [0.5,0.1,0.5];
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
%         case 'pawgraylevels',
%             pawGrayLevels = varargin{iarg + 1};
%         case 'pixelcountthreshold',
%             pixCountThresh = varargin{iarg + 1};
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

vidName = fullfile(video.Path, video.Name);
video = VideoReader(vidName);
video.CurrentTime = triggerTime;

% frontPanelWidth = panelWidthFromMask(boxRegions.frontPanelMask);
[fpoints2d, timeList_f,isPawVisible_f] = trackPaw_mirror_local( video, BGimg_ud, initPawMask{2},pawBlob, boxRegions, pawPref, 'forward',boxCalibration,...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxdistperframe',maxDistPerFrame,...
                                     'targetmean',targetMean,...
                                     'targetsigma',targetSigma,...
                                     'whitethresh',whiteThresh);
                                 
video.CurrentTime = triggerTime;

[rpoints2d, timeList_b,isPawVisible_b] = trackPaw_mirror_local( video, BGimg_ud, initPawMask{2},pawBlob, boxRegions, pawPref, 'reverse',boxCalibration,...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxdistperframe',maxDistPerFrame,...
                                     'targetmean',targetMean,...
                                     'targetsigma',targetSigma,...
                                     'whitethresh',whiteThresh);
                                 
   
points2d = rpoints2d;
trigFrame = round(triggerTime * video.FrameRate);
for iFrame = trigFrame : length(fpoints2d)
    points2d{iFrame} = fpoints2d{iFrame};
end
timeList = [timeList_b,timeList_f(2:end)];
isPawVisible = isPawVisible_b | isPawVisible_f;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [points2d,timeList,isPawVisible] = trackPaw_mirror_local( video, ...
                                    BGimg_ud, ...
                                    initPawMask, ...
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

switch lower(pawPref),
    case 'right',
        fundMat = boxCalibration.srCal.F(:,:,1);
    case 'left',
        fundMat = boxCalibration.srCal.F(:,:,2);
end
cameraParams = boxCalibration.cameraParams;

if strcmpi(timeDir,'reverse')
    numFrames = round((video.CurrentTime) * fps);
    frameCount = numFrames;
else
    numFrames = round((video.Duration - video.CurrentTime) * fps);
    frameCount = 1;
end
totalFrames = round(video.Duration * fps);

prevMask = initPawMask;

targetMean = [0.5,0.2,0.5];
    
targetSigma = [0.2,0.2,0.2];
           
for iarg = 1 : 2 : nargin - 8
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

points2d = cell(1,totalFrames);

timeList(frameCount) = video.CurrentTime;
currentFrame = round((video.CurrentTime) * fps);
image = readFrame(video);   % just to advance one frame for forward direction
image_ud = undistortImage(image, cameraParams);
image_ud = double(image_ud) / 255;
orig_BGimg_ud = BGimg_ud;
image_ud = color_adapthisteq(image_ud);


isPawVisible = false(totalFrames,1);
isPawVisible(currentFrame) = true;

temp = bwmorph(bwconvhull(initPawMask),'remove');
[y,x] = find(temp);
points2d{currentFrame} = [x,y];
% framesChecked = 0;
% isPawVisible(frameCount,:) = true(1,2);   % by definition (almost), paw is visible in both views in the initial frame
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
%     orig_image_ud = image_ud;
    image_ud = color_adapthisteq(image_ud);
    
    [fullMask,~] = trackNextStep_mirror(image_ud,fundMat,BGimg_ud,prevMask,boxRegions,pawPref,...
                             'foregroundthresh',foregroundThresh,...
                             'pawhsvrange',pawHSVrange,...
                             'maxdistperframe',maxDistPerFrame,...
                             'targetmean',targetMean,...
                             'targetsigma',targetSigma,...
                             'whitethresh',whiteThresh);

	if any(fullMask(:))
        temp = bwmorph(fullMask,'remove');
        [y,x] = find(temp);
        points2d{currentFrame} = [x,y];
        isPawVisible(currentFrame) = true;
        prevMask = fullMask;
    else
        points2d{currentFrame} = [];
        isPawVisible(currentFrame) = false;
        if isPawVisible(lastFrame)
            prevMask = imdilate(prevMask, strel('disk',maxDistPerFrame));
        end
    end
    
	lastFrame = currentFrame;
        
%     showSingleViewTracking(image_ud,fullMask)
end

end