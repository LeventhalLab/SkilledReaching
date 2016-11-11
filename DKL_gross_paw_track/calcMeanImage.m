function mean_img = calcMeanImage(video, cameraParams, varargin)

% function to calculate the average frame across an entire video

timeLims = [0,video.Duration];
for iarg = 1 : 2 : nargin - 2
    switch lower(varargin)
        case 'timelims',
            timeLims = varargin{iarg + 1};
    end
end

video.CurrentTime = timeLims(1);

numFrames = 0;
mean_img = zeros(video.Height, video.Width, 3);
while video.CurrentTime < timeLims(2)
    image = readFrame(video);
    if strcmpi(class(image),'uint8')
        image = double(image) / 255;
    end

    numFrames = numFrames + 1;
%     fprintf('frame number: %d\n', frameNum)
    
    % undistort image
    orig_image_ud = undistortImage(image, cameraParams);
    mean_img = mean_img + orig_image_ud;
end

mean_img = mean_img / numFrames;