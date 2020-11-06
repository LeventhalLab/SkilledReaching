function actualLaserOnFrames = findLaserOnBlocks(framesWithLight)

% function to identify start and end frames of consecutive "laser on"
% frames

lightOnFrames = find(framesWithLight == 1); % identify all "laser on" frames
contFrames = diff(lightOnFrames) < 31;  % because laser is on at 20 Hz, laser will blink on and off in laser on bout - don't remove bouts where the laser may be off for a few frames in a bout
groupsOnes = strfind(contFrames, [0 1]);    % find transitions from "laser on" to "laser on"
groupsOnes2 = strfind(contFrames,[0 0]);    

if contFrames(1) == 1   % if laser starts on make sure this is kept 
    groupsOnes = [1 groupsOnes groupsOnes2];
else
    groupsOnes = [groupsOnes groupsOnes2];
end 
groupsOnes = sort(groupsOnes);

for i_group = 1:size(groupsOnes,2)
    
    curGrpOne = groupsOnes(i_group);
    if contFrames(1,curGrpOne) == 0 && contFrames(1,curGrpOne + 1) == 0
        laserOnFrames(i_group,1:2) = NaN;
        continue
    end
    
    % find start of current laser on bout
    if i_group == 1
        laserOnFrames(i_group,1) = groupsOnes(i_group);
    else
        laserOnFrames(i_group,1) = groupsOnes(i_group) + 1;
    end 
    
    % find last frame of current laser on bout
    if i_group == size(groupsOnes,2)    % if the last frame of video find last laser on frame
        laserOnFrames(i_group,2) = find(contFrames(:,:) == 1,1, 'last');
    else
        laserOnFrames(i_group,2) = groupsOnes(i_group + 1);
    end 
    
end 

laserOnFrames(any(isnan(laserOnFrames),2),:) = [];  % remove NaN's from matrix

for i_block = 1:size(laserOnFrames,1)   % get the real video frame numbers
    
    curFrames = laserOnFrames(i_block,:);
    
    actualLaserOnFrames(i_block,1) = lightOnFrames(curFrames(1,1));
    actualLaserOnFrames(i_block,2) = lightOnFrames(curFrames(1,2));

end 

