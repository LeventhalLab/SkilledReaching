function [points2d,timeList,isPawVisible] = trackMirrorView_relRGB_20170208_c( video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo, boxRegions, boxCalibration, greenBGmask, varargin )
% function [points2d,timeList,isPawVisible] = trackMirrorView_relRGB_PCA( video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo, boxRegions, boxCalibration, PCAcoeff,PCAmean,PCAmean_nonPaw,PCAcovar, varargin )

% video.CurrentTime = triggerTime;
% cameraParams = boxCalibration.cameraParams;

maxDistPerFrame = 20;

for iarg = 1 : 2 : nargin - 8
    switch lower(varargin{iarg})
        
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

% greenBGmask = threshold_BGimg( BGimg_ud );

[fpoints2d, timeList_f,isPawVisible_f] = trackPaw_mirror_local( video, initPawMask, greenBGmask, boxRegions, pawPref,'forward',boxCalibration,BGimg_ud);
% [fpoints2d, timeList_f,isPawVisible_f] = trackPaw_mirror_local( video, initPawMask, greenBGmask, boxRegions, pawPref,PCAcoeff,PCAmean,PCAmean_nonPaw,PCAcovar,'forward',boxCalibration);
    
video.CurrentTime = triggerTime;

[rpoints2d, timeList_b,isPawVisible_b] = trackPaw_mirror_local( video, initPawMask, greenBGmask, boxRegions, pawPref,'reverse',boxCalibration,BGimg_ud);
% [rpoints2d, timeList_b,isPawVisible_b] = trackPaw_mirror_local( video, initPawMask, greenBGmask, boxRegions, pawPref,PCAcoeff,PCAmean,PCAmean_nonPaw,PCAcovar,'reverse',boxCalibration);
                                 
   
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
                                    greenBGmask, ...
                                    boxRegions, ...
                                    pawPref, ...
                                    timeDir, ...
                                    boxCalibration,...
                                    BGimg_ud,...
                                    varargin)                            
                                
zeroTol = 1e-10;
fps = video.FrameRate;
maxDistPerFrame = 20;

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
           
for iarg = 1 : 2 : nargin - 8
    switch lower(varargin{iarg})
        case 'maxdistperframe'
            maxDistPerFrame = varargin{iarg + 1};
    end
end

points2d = cell(2,totalFrames);

timeList(frameCount) = video.CurrentTime;
currentFrame = round((video.CurrentTime) * fps);
image = readFrame(video);   % just to advance one frame for forward direction
image_ud = undistortImage(image, cameraParams);
image_ud = double(image_ud) / 255;

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

%     prev_im_ud = image_ud;
    image_ud = undistortImage(image, cameraParams);
    image_ud = double(image_ud) / 255;

    [fullMask] = trackNextStep_mirror_relRGB_20170208_c(image_ud,BGimg_ud,fundMat,greenBGmask,prevMask,boxRegions,pawPref);
%     [fullMask] = trackNextStep_mirror_relRGB_PCA(image_ud,fundMat,greenBGmask,prevMask,boxRegions,pawPref,PCAcoeff,PCAmean,PCAmean_nonPaw,PCAcovar);
                         

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