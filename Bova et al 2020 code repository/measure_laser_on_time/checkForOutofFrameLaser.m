function trueLaserOnFrames = checkForOutofFrameLaser(trueLaserOnFrames,curVideo,colVal)

% function that does another check of errors where rat went out of frame in laser 
% on durations - includes all bouts even if they're not very short

for i_bout = 1:length(trueLaserOnFrames)-1

    for checkFrame = 1:2    % get fiber locations from last frame current bout and first frame of next

        if checkFrame == 1  
            curFrame = trueLaserOnFrames(i_bout,2);
        else
            curFrame = trueLaserOnFrames(i_bout+1,1);
        end

        if isnan(curFrame) && checkFrame == 1 % current i_bout was combined with previous; check to make sure 3 bouts didn't get chopped up b/c rat went out of frame
            lastNonNaN = find(~isnan(trueLaserOnFrames(1:i_bout-1,2)),1,'last');
            curFrame = trueLaserOnFrames(lastNonNaN,2);
        end

        imagedata = read(curVideo,curFrame);  % read in data for current frame
        %imagedata = imagedata./1.3; 

        % extract the Blue color from grayscale image
        diff_im = imsubtract(imagedata(:,:,colVal),rgb2gray(imagedata));
        % Filtering the noise
        diff_im = medfilt2(diff_im,[3,3]);
        % Converting grayscale image into binary image
        diff_im = im2bw(diff_im,0.18);
        % remove all pixels less than 300 pixel
%         diff_im=bwareaopen(diff_im,10);
        % Draw rectangular boxes around the red object detected & label image
        bw=bwlabel(diff_im,8);

        stats=regionprops(bw,'BoundingBox','Centroid'); % get fiber location of current frame
        if isempty(stats)
            fiberLoc2(checkFrame,1) = NaN;
        else
            fiberLoc2(checkFrame,1) = stats(1).Centroid(1);
        end 

    end 
    
    if any(isnan(fiberLoc2))    
        continue;
    end 

    distFromRightEdge = curVideo.Width - fiberLoc2; % find distance from edge of box

    if (distFromRightEdge(1) < 30 && distFromRightEdge(2) < 30) ||...   % rat moved out of frame with laser on
            (distFromRightEdge(1) > 1890 && distFromRightEdge(2) > 1890)

        if isnan(trueLaserOnFrames(i_bout,2))   % combine bouts
            trueLaserOnFrames(lastNonNaN,2) = trueLaserOnFrames(i_bout+1,2);
            trueLaserOnFrames(i_bout+1,:) = NaN;
        else
            trueLaserOnFrames(i_bout,2) = trueLaserOnFrames(i_bout+1,2);
            trueLaserOnFrames(i_bout+1,:) = NaN;
        end
        % combine current bout with next

    end            

end 

trueLaserOnFrames(any(isnan(trueLaserOnFrames),2),:) = [];