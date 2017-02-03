function [points2d,timeList,isPawVisible] = trackMirrorView_relRGB( video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo, boxRegions, boxCalibration, greenBGmask, varargin )

% video.CurrentTime = triggerTime;
cameraParams = boxCalibration.cameraParams;

targetMean = [0.5,0.1,0.5];
targetSigma = [0.2,0.2,0.2];

foregroundThresh = 25/255;

stretch_hist_limit_int = 0.5;
stretch_hist_limit_ext = 0.75;

pawHSVrange = [1/3, 0.002, 0.999, 1.0, 0.99, 1.0   % for restrictive external masking
               1/3, 0.005, 0.99, 1.0, 0.97, 1.0     % for more liberal external masking
               1/3, 0.002, 0.999, 1.0, 0.80, 1.0    % for restrictive internal masking
               1/3, 0.03, 0.95, 1.0, 0.60, 1.0    % for liberal internal masking
               1/3, 0.03, 0.99, 1.0, 0.90, 1.0    % for restrictive masking just behind the front panel
               1/3, 0.10, 0.95, 1.0, 0.70, 1.0    % for liberal masking just behind the front panel
               0.00, 0.02, 0.00, 0.001, 0.999, 1.0];  % for white masking

maxDistPerFrame = 20;

whiteThresh_ext = 0.95;
whiteThresh_int = 0.85;

% blob parameters for mirror view
pawBlob = vision.BlobAnalysis;
pawBlob.AreaOutputPort = true;
pawBlob.CentroidOutputPort = true;
pawBlob.BoundingBoxOutputPort = true;
pawBlob.LabelMatrixOutputPort = true;
pawBlob.MinimumBlobArea = 100;
pawBlob.MaximumBlobArea = 4000;

for iarg = 1 : 2 : nargin - 9
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
        case 'whitethresh_ext',
            whiteThresh_ext = varargin{iarg + 1};
        case 'whitethresh_int',
            whiteThresh_int = varargin{iarg + 1};
        case 'stretch_hist_limit_int',
            stretch_hist_limit_int = varargin{iarg + 1};
        case 'stretch_hist_limit_ext',
            stretch_hist_limit_ext = varargin{iarg + 1};
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

% initialize the CAMshift tracker
% im = readFrame(video);
% im_ud = undistortImage(im, cameraParams);
% rel_im = relativeRGB(im_ud);
% rel_im_hsv = rgb2hsv(rel_im);
% rel_im_h = rel_im_hsv(:,:,1);
% BBox = zeros(2,4);
% for ii = 1 : 2
%     temp = regionprops(initPawMask{ii},'BoundingBox');
%     BBox(ii,:) = round(temp.BoundingBox);
% end
% directPawTracker = vision.HistogramBasedTracker;
% mirrorPawTracker = vision.HistogramBasedTracker;
% 
% initializeObject(directPawTracker, rel_im_h, BBox(1,:));
% initializeObject(mirrorPawTracker, rel_im_h, BBox(2,:));

% frontPanelWidth = panelWidthFromMask(boxRegions.frontPanelMask);
[fpoints2d, timeList_f,isPawVisible_f] = trackPaw_mirror_local( video, initPawMask, BGimg_ud, boxRegions, pawPref,'forward',boxCalibration,...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxdistperframe',maxDistPerFrame,...
                                     'targetmean',targetMean,...
                                     'targetsigma',targetSigma,...
                                     'whitethresh_ext',whiteThresh_ext,...
                                     'whitethresh_int',whiteThresh_int,...
                                     'stretch_hist_limit_int',stretch_hist_limit_int,...
                                     'stretch_hist_limit_ext',stretch_hist_limit_ext);
    
video.CurrentTime = triggerTime;

[rpoints2d, timeList_b,isPawVisible_b] = trackPaw_mirror_local( video, initPawMask, BGimg_ud, boxRegions, pawPref, 'reverse',boxCalibration,...
                                     'foregroundthresh',foregroundThresh,...
                                     'pawhsvrange',pawHSVrange,...
                                     'maxdistperframe',maxDistPerFrame,...
                                     'targetmean',targetMean,...
                                     'targetsigma',targetSigma,...
                                     'whitethresh_ext',whiteThresh_ext,...
                                     'whitethresh_int',whiteThresh_int,...
                                     'stretch_hist_limit_int',stretch_hist_limit_int,...
                                     'stretch_hist_limit_ext',stretch_hist_limit_ext);

                                 
   
points2d = rpoints2d;
trigFrame = round(triggerTime * video.FrameRate);
for iFrame = trigFrame : length(fpoints2d)
    for iView = 1 : 2
        points2d{iView,iFrame} = fpoints2d{iView,iFrame};
    end
end
timeList = [timeList_b,timeList_f(2:end)];
isPawVisible = isPawVisible_b | isPawVisible_f;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [points2d,timeList,isPawVisible] = trackPaw_mirror_local( video, ...
                                    initPawMask, ...
                                    BGimg_ud, ...
                                    boxRegions, ...
                                    pawPref, ...
                                    timeDir, ...
                                    boxCalibration,...
                                    varargin)

zeroTol = 1e-10;
fps = video.FrameRate;

h = video.Height;
w = video.Width;

stretch_hist_limit_int = 0.5;
stretch_hist_limit_ext = 0.75;

switch lower(pawPref)
    case 'right'
        fundMat = boxCalibration.srCal.F(:,:,1);
    case 'left'
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

% targetMean = [0.5,0.2,0.5];
%     
% targetSigma = [0.2,0.2,0.2];
           
for iarg = 1 : 2 : nargin - 7
    switch lower(varargin{iarg})
        case 'foregroundthresh'
            foregroundThresh = varargin{iarg + 1};
        case 'pawhsvrange'
            pawHSVrange = varargin{iarg + 1};
        case 'maxdistperframe'
            maxDistPerFrame = varargin{iarg + 1};
        case 'targetmean'
            targetMean = varargin{iarg + 1};
        case 'targetsigma'
            targetSigma = varargin{iarg + 1};
        case 'whitethresh_ext'
            whiteThresh_ext = varargin{iarg + 1};
        case 'whitethresh_int'
            whiteThresh_int = varargin{iarg + 1};
        case 'stretch_hist_limit_int'
            stretch_hist_limit_int = varargin{iarg + 1};
        case 'stretch_hist_limit_ext'
            stretch_hist_limit_ext = varargin{iarg + 1};
    end
end

points2d = cell(2,totalFrames);

timeList(frameCount) = video.CurrentTime;
currentFrame = round((video.CurrentTime) * fps);
image = readFrame(video);   % just to advance one frame for forward direction
image_ud = undistortImage(image, cameraParams);
image_ud = double(image_ud) / 255;
% orig_BGimg_ud = BGimg_ud;
% image_ud = color_adapthisteq(image_ud);


isPawVisible = false(2,totalFrames);
isPawVisible(:,currentFrame) = [true;true];

relRGB_im = relativeRGB(image_ud);
meanRelColor = zeros(2,3);
for ii = 1 : 2
%     temp = bwmorph(bwconvhull(initPawMask{ii}),'remove');
    temp = bwmorph(initPawMask{ii},'remove');
    [y,x] = find(temp);
    points2d{ii,currentFrame} = [x,y];
    
    pawPixels = zeros(sum(initPawMask{ii}(:)),3);
    for iRGB = 1 : 3
        im_temp = squeeze(relRGB_im(:,:,iRGB));
        pawPixels(:,iRGB) = im_temp(initPawMask{ii});
    end
    meanRelColor(ii,:) = mean(pawPixels);
end

while video.CurrentTime < video.Duration && video.CurrentTime >= 0

    prevFrame = frameCount;
    isPrevPawVisible = isPawVisible(:,currentFrame);
    
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

    prev_im_ud = image_ud;
    image_ud = undistortImage(image, cameraParams);
    image_ud = double(image_ud) / 255;
                         
%     rel_im = relativeRGB(image_ud);
%     rel_im_hsv = rgb2hsv(rel_im);
%     rel_im_h = rel_im_hsv(:,:,1);
%     
%     new_bbox_direct = step(directPawTracker, rel_im_h);
%     new_bbox_mirror = step(mirrorPawTracker, rel_im_h);
%     
%     figure(1);
%     imshow(image_ud)
%     hold on
%     rectangle('position',new_bbox_direct,'edgecolor','y');
%     rectangle('position',new_bbox_mirror,'edgecolor','y');
%     
%     figure(2);
%     imshow(rel_im)
%     hold on
%     rectangle('position',new_bbox_direct,'edgecolor','y');
%     rectangle('position',new_bbox_mirror,'edgecolor','y');
%     
%     figure(3);
%     imshow(rel_im_h)
%     hold on
%     rectangle('position',new_bbox_direct,'edgecolor','y');
%     rectangle('position',new_bbox_mirror,'edgecolor','y');

    [fullMask] = trackNextStep_mirror_relRGB_b(image_ud,prev_im_ud,fundMat,BGimg_ud,prevMask,isPrevPawVisible,meanRelColor,boxRegions,pawPref,...
                             'foregroundthresh',foregroundThresh,...
                             'pawhsvrange',pawHSVrange,...
                             'maxdistperframe',maxDistPerFrame,...
                             'targetmean',targetMean,...
                             'targetsigma',targetSigma,...
                             'whitethresh_ext',whiteThresh_ext,...
                             'whitethresh_int',whiteThresh_int,...
                             'stretch_hist_limit_int',stretch_hist_limit_int,...
                             'stretch_hist_limit_ext',stretch_hist_limit_ext);
                         

	for ii = 1 : 2
        if any(fullMask{ii}(:))
            temp = bwmorph(fullMask{ii},'remove');
            [y,x] = find(temp);
            points2d{ii,currentFrame} = [x,y];
            isPawVisible(ii,currentFrame) = true;
            prevMask{ii} = fullMask{ii};
        else
            points2d{ii,currentFrame} = [];
            isPawVisible(ii,currentFrame) = false;
            if isPawVisible(ii,lastFrame)
                prevMask{ii} = imdilate(prevMask{ii}, strel('disk',maxDistPerFrame));
            end
        end
    end
    
	lastFrame = currentFrame;
        
%     showSingleViewTracking(image_ud,fullMask)
end

end