function reachData = findGraspEnd(reachData,interp_trajectory,bodyparts,pawPref,slot_z_wrt_pellet)

minGraspSeparation = 25;

% get degree of flexion of second digit
[digFlex,firstValidFrame] = determineDigitFlexion(interp_trajectory,bodyparts,pawPref);
digFlexDegree = (digFlex*180)/pi;
missFrames = NaN(firstValidFrame-1,1);
digFlexDegree = [missFrames;digFlexDegree];

% pull out digit 2 and dorsum trajectories
[~,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);

dig2_traj = squeeze(interp_trajectory(:,:,digIdx(2)));
pd_traj = squeeze(interp_trajectory(:,:,pawDorsumIdx));

num_reaches = size(reachData.reachStarts,1);
num_frames = length(digFlexDegree);
graspEndFrame = NaN(num_reaches,1);
flexTraj = {};

for i_reach = 1 : num_reaches
    
    if isnan(reachData.graspStarts(i_reach))
        graspEndFrame(i_reach) = NaN;
        continue;
    end

    % get frame limits for current reach (right now from reachStart to
    % before next reachStart)
    if num_reaches == 1 || i_reach == num_reaches % last reach in trial
        frame_lims(1) = reachData.graspStarts(i_reach);
        frame_lims(2) = reachData.reachEnds(i_reach)+40;
    else
        frame_lims(1) = reachData.graspStarts(i_reach);
        if reachData.reachStarts(i_reach+1) - reachData.graspStarts(i_reach) > 40 % arbitrary, may need to change
            frame_lims(2) = reachData.graspStarts(i_reach) + 40;
        else
            frame_lims(2) = reachData.graspStarts(i_reach+1)+15;
        end
    end 
    
    if frame_lims(2) > num_frames
        frame_lims(2) = num_frames;
    elseif isnan(frame_lims(2))
        frame_lims(2) = num_frames;
    end
    
    curDigFlex = digFlexDegree(frame_lims(1):frame_lims(2));
    
    areDigitsThroughSlot = (dig2_traj(frame_lims(1):frame_lims(2),3) < slot_z_wrt_pellet) & (pd_traj(frame_lims(1):frame_lims(2),3) < slot_z_wrt_pellet-1);

    for i_frame = 1:length(areDigitsThroughSlot)
        if areDigitsThroughSlot(i_frame) == 0 || curDigFlex(i_frame,:) < 0
            curDigFlex(i_frame,:) = NaN;
        end 
    end 
    
    % find when the angle is largest
    if sum(~isnan(curDigFlex)) < 20
        angle_max(:,1) = islocalmax(curDigFlex,1,...
            'minprominence',.8,...
            'prominencewindow',[0,1000],...
            'minseparation',minGraspSeparation);
    else
        angle_max(:,1) = islocalmax(curDigFlex,1,...
            'minprominence',1,...
            'prominencewindow',[0,1000],...
            'minseparation',15);
    end
        
    if all(angle_max == 0)
        biggestAngle = max(curDigFlex);
        maxAngleFrame = find(curDigFlex == biggestAngle);
        %digitCloseFrame(i_reach) = NaN;
    else
      maxAngleFrame = find(angle_max == 1);     
    end
    
    if size(maxAngleFrame,1) > 1    % sometimes finds two min angles
        % check if there is a DLC error - like a huge change in angle
        % within one frame
        for i = 1 : size(maxAngleFrame,1)
            if diff(curDigFlex(maxAngleFrame(i):maxAngleFrame(i)+1)) > 6 ||...
                    diff(curDigFlex(maxAngleFrame(i)-1:maxAngleFrame(i))) > 6
                maxAngleFrame(i) = NaN;
            end
        end
        
        goodFrame = find(~isnan(maxAngleFrame));
        maxAngleFrame = maxAngleFrame(goodFrame);
    end
    
    if size(maxAngleFrame,1) > 1 % still more than 1 min angle, find largeste
        for i = 1 : size(maxAngleFrame,1)
            vals(i,1) = curDigFlex(maxAngleFrame(i));
        end
        smallVal = max(vals);
        maxAngleFrame = find(curDigFlex == smallVal);
    end
    
    if isempty(maxAngleFrame)
        biggestAngle = max(curDigFlex);
        maxAngleFrame = find(curDigFlex == biggestAngle);
    end
        
    graspEndFrame(i_reach) = maxAngleFrame + (frame_lims(1) - 1);
    
    clear curDigFlex
    clear angle_max
    clear vals
    
end 

reachData.graspEnds = graspEndFrame;

% get flexion over grasp trajectory
for i_reach = 1 : num_reaches
  
    startFr = reachData.graspStarts(i_reach);
    endFr = reachData.graspEnds(i_reach);
    
    if isnan(startFr) 
        flexTraj{i_reach} = {};
        continue;
    end
    
    flexTraj{i_reach} = digFlexDegree(startFr:endFr);
    digitsThroughSlot = (dig2_traj(startFr:endFr,3) < slot_z_wrt_pellet) & ...
        (pd_traj(startFr:endFr,3) < slot_z_wrt_pellet-1);
    
    for i_frame = 1:length(digitsThroughSlot)
        if digitsThroughSlot(i_frame) == 0 
            flexTraj{i_reach}(i_frame,1) = NaN;
        end 
    end
end

reachData.flexion_grasp = flexTraj;