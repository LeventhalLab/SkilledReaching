function reachData = findDigitClose2(reachData,interp_trajectory,bodyparts,pawPref,slot_z_wrt_pellet)

minGraspSeparation = 25;

% get degree of flexion of second digit
[digFlex,firstValidFrame] = determineDigitFlexion(interp_trajectory,bodyparts,pawPref);
if isempty(digFlex)
    reachData.graspStarts = NaN;
    reachData.flexion = NaN;
    return;
end
digFlexDegree = (digFlex*180)/pi;
missFrames = NaN(firstValidFrame-1,1);
digFlexDegree = [missFrames;digFlexDegree];

% pull out digit 2 and dorsum trajectories
[~,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

dig2_traj = squeeze(interp_trajectory(:,:,digIdx(2)));
pd_traj = squeeze(interp_trajectory(:,:,pawDorsumIdx));

num_frames = length(digFlexDegree);
num_reaches = size(reachData.reachStarts,1);
digitCloseFrame = NaN(num_reaches,1);

flexTraj = {};

for i_reach = 1 : num_reaches
    
    %
    startFr = reachData.reachStarts(i_reach);
    endFr = reachData.reachEnds(i_reach);
    % get flexion over reach trajectory
    flexTraj{i_reach} = digFlexDegree(reachData.reachStarts(i_reach):reachData.reachEnds(i_reach));
    digitsThroughSlot = (dig2_traj(startFr:endFr,3) < slot_z_wrt_pellet) & ...
        (pd_traj(startFr:endFr,3) < slot_z_wrt_pellet-1);
    
    for i_frame = 1:length(digitsThroughSlot)
        if digitsThroughSlot(i_frame) == 0 
            flexTraj{i_reach}(i_frame,1) = NaN;
        end 
    end 
    
    % get frame limits for current reach (right now from reachStart to
    % before next reachStart)
    if num_reaches == 1 || i_reach == num_reaches % last reach in trial
        frame_lims(1) = reachData.reachStarts(i_reach);
        frame_lims(2) = reachData.reachEnds(i_reach)+25;
    else
        frame_lims(1) = reachData.reachStarts(i_reach);
        frame_lims(2) = reachData.reachEnds(i_reach)+25;
        %frame_lims(2) = reachData.reachStarts(i_reach+1);
    end 
    
    if frame_lims(2) > num_frames
        frame_lims(2) = num_frames;
    end
    
    curDigFlex = digFlexDegree(frame_lims(1):frame_lims(2));
    
    areDigitsThroughSlot = (dig2_traj(frame_lims(1):frame_lims(2),3) < slot_z_wrt_pellet) & (pd_traj(frame_lims(1):frame_lims(2),3) < slot_z_wrt_pellet-1);

    for i_frame = 1:length(areDigitsThroughSlot)
        if areDigitsThroughSlot(i_frame) == 0 || curDigFlex(i_frame,:) < 0
            curDigFlex(i_frame,:) = NaN;
        end 
    end 
    
    % find when the angle is smallest
    if sum(~isnan(curDigFlex)) < 30
        angle_min(:,1) = islocalmin(curDigFlex,1,...
            'minprominence',.8,...
            'prominencewindow',[0,1000],...
            'minseparation',minGraspSeparation);
    else
        angle_min(:,1) = islocalmin(curDigFlex,1,...
            'minprominence',1,...
            'prominencewindow',[0,1000],...
            'minseparation',minGraspSeparation);
    end
        
    if all(angle_min == 0)
        digitCloseFrame(i_reach) = NaN;
        clear angle_min
        clear curDigFlex
        continue;
    end

    minAngleFrame = find(angle_min == 1);   
    
    if size(minAngleFrame,1) > 1    % sometimes finds two min angles
        % check if there is a DLC error - like a huge change in angle
        % within one frame
        for i = 1 : size(minAngleFrame,1)
            if abs(diff(curDigFlex(minAngleFrame(i):minAngleFrame(i)+1))) > 10 ||...
                    abs(diff(curDigFlex(minAngleFrame(i)-1:minAngleFrame(i)))) > 10
                minAngleFrame(i) = NaN;
            end
        end
        
        goodFrame = find(~isnan(minAngleFrame));
        minAngleFrame = minAngleFrame(goodFrame);
    end
    
    if size(minAngleFrame,1) > 1 % still more than 1 min angle, find smallest 
        for i = 1 : size(minAngleFrame,1)
            vals(i,1) = curDigFlex(minAngleFrame(i));
        end
        smallVal = min(vals);
        minAngleFrame = find(curDigFlex == smallVal);
    end
           
    tempDigFlexFrame = find(curDigFlex(minAngleFrame+1:end) > curDigFlex(minAngleFrame)+1,1,'first')...
        + minAngleFrame;
    
    if isempty(tempDigFlexFrame)
        biggestAfter = max(curDigFlex(minAngleFrame+1:end));
        tempDigFlexFrame = find(curDigFlex(minAngleFrame+1:end) == biggestAfter) + minAngleFrame;
    end
    
    if isempty(tempDigFlexFrame)
        digitCloseFrame(i_reach) = NaN;
        clear curDigFlex
        clear angle_min
        clear vals
        continue;
    end
    
    digitCloseFrame(i_reach) = tempDigFlexFrame + (frame_lims(1) - 1);
    
    clear curDigFlex
    clear angle_min
    clear vals
    
end 

reachData.graspStarts = digitCloseFrame;
reachData.flexion = flexTraj;