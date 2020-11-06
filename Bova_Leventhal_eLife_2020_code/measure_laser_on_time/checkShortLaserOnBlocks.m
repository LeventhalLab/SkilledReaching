function trueLaserOnFrames = checkShortLaserOnBlocks(actualLaserOnFrames,curVideo,numTrials,frameRate,colVal)

% Looks for abnormally short "laser on" blocks and determines if these are
% real or because rat went out of frame, other error

trueLaserOnFrames = actualLaserOnFrames; 

if length(trueLaserOnFrames) > numTrials % are there more "laser on" bouts than trials?
    
    durLaserBouts = (actualLaserOnFrames(:,2) - actualLaserOnFrames(:,1))/frameRate;    % calculate bout durations
    
    shortBouts = find(durLaserBouts < 4);   % safe to assume that if bout was under 4 seconds long, it was either a mis-identified blue area or the rat went out of frame
    
    for i_bout = 1:length(shortBouts)
        
        boutNum = shortBouts(i_bout);

        if boutNum == 1 || boutNum == length(actualLaserOnFrames)   % first and last bout numbers often are shorter so leave them be - can check in post-processing
            continue;
        end 
            
        for i_frame = 1:4   % identify locations of fiber in frames around short bout
            
            if i_frame == 1
                curFrame = actualLaserOnFrames(boutNum-1,2); % last frame of last bout
            elseif i_frame == 2
                curFrame = actualLaserOnFrames(boutNum,1);  % first frame of short bout
            elseif i_frame == 3
                curFrame = actualLaserOnFrames(boutNum,2);  % last frame of short bout
            elseif i_frame == 4
                curFrame = actualLaserOnFrames(boutNum+1,1);    % first frame of next bout
            end 
        
            imagedata = read(curVideo,curFrame);  % read in data for current frame

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

            stats=regionprops(bw,'BoundingBox','Centroid');
            if isempty(stats)
                fiberLoc(1,i_frame) = NaN;
            else
                fiberLoc(1,i_frame) = stats(1).Centroid(1);
            end 
            
        end 
        
        if any(isnan(fiberLoc)) % if no blue identified in either previous bout last frame or next bout first frame then likely not a case where rat went out of frame
            continue;
        end
        
        lowestVals = find(fiberLoc < 20);   % find frames where fiber was located at the edge of the box
        
        if isempty(lowestVals) || lowestVals(1) == 4 || lowestVals(1) == 2  % mis-identified laser light
            trueLaserOnFrames(boutNum,1:2) = NaN;
        elseif lowestVals(1) == 1   % rat went out of frame between last and current bout - combine
            trueLaserOnFrames(boutNum - 1,2) = trueLaserOnFrames(boutNum,2);
            trueLaserOnFrames(boutNum,1:2) = NaN;
            % make boutNum combine with previous bout duration
        elseif lowestVals(1) == 3   % rat went out of frame between current and next bout - combine
            trueLaserOnFrames(boutNum,2) = trueLaserOnFrames(boutNum+1,2);
            trueLaserOnFrames(boutNum+1,:) = NaN;
            % make boutNum combine with next bout duration
        end 
        
    
    end 
    
end 

trueLaserOnFrames(any(isnan(trueLaserOnFrames),2),:) = [];  % remove NaNs


        
        
        
        
        
        
        