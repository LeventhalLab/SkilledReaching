% script_exemplarKinematicsFig_b

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
rootAnalysisFolder = '/Volumes/LL EXHD #2/SR opto analysis';
vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';

frameTextPos = [50,10];
cropRegion = [900,400,1200,800;...   % direct view
              1,400,450,800;...     % left view
              1700,400,2040,800];   % right view
          
          

exemplar_vidName = 'R0216_20180202_10-07-29_015';
full_exemplar_vidName = [exemplar_vidName '.avi'];

exemplar_ratID = exemplar_vidName(1:5);
exemplar_ratIDnum = str2double(exemplar_ratID(2:end));

sessionDateString = exemplar_vidName(7:14);
sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
vidNumString = exemplar_vidName(25:27);
vidNum = str2double(vidNumString);

ratVidFolder = fullfile(vidRootPath,exemplar_ratID);
cd(ratVidFolder);
sessionVidRoot = [exemplar_ratID '_' sessionDateString '*'];
sessionVidFolder = dir(sessionVidRoot);

if isempty(sessionVidFolder)
    fprintf('no sessions for %s on %s\n',exemplar_ratID,sessionDateString);
    return
end

if length(sessionVidFolder) > 1
    fprintf('more than one session for %s on %s\n',exemplar_ratID,sessionDateString);
    return
end

exemplarVidFolder = fullfile(vidRootPath,exemplar_ratID,sessionVidFolder.name);
exemplarKinematicsFolder = fullfile(labeledBodypartsFolder,exemplar_ratID,sessionVidFolder.name);

cd(exemplarKinematicsFolder);
processed_data_root = '*_processed_reaches.mat';
processed_data_file = dir(processed_data_root);
if isempty(processed_data_file)
    fprintf('no session summary found for %s on %s\n',exemplar_ratID,sessionDateString);
    return
end

interp_data_root = '*_interp_trajectories.mat';
interp_data_file = dir(interp_data_root);
if isempty(interp_data_file)
    fprintf('no interpolated trajectories file found for %s on %s\n',exemplar_ratID,sessionDateString);
    return
end

load(processed_data_file.name);
load(interp_data_file.name);
% find the reach data for this part
pawPref = thisRatInfo.pawPref;

[reachDataIdx,trajectory_name] = identifyCorrectVidIdx(exemplar_vidName,exemplarKinematicsFolder);
load(trajectory_name);

current_reachData = reachData(reachDataIdx);
frames_of_interest = [270,300,current_reachData.reachEnds(1)];

cd(exemplarVidFolder);

vidObj = VideoReader(full_exemplar_vidName);

initPellet3D = all_initPellet3D(reachDataIdx,:);
interp_traj_wrt_pellet = squeeze(all_interp_traj_wrt_pellet(:,:,:,reachDataIdx));
for i_frame = 1 : length(frames_of_interest)
    
    curFrameIdx = frames_of_interest(i_frame);
    vidObj.CurrentTime = curFrameIdx / vidObj.FrameRate;
    
    curFrame = readFrame(vidObj);
    curFrame_ud = undistortImage(curFrame, activeBoxCal.cameraParams);
    
    interp_points3D = squeeze(interp_traj_wrt_pellet(curFrameIdx,:,:))';
    points3D_wrt_camera = bsxfun(@plus,interp_points3D,initPellet3D);
    direct_pt = squeeze(final_direct_pts(:,curFrameIdx,:));
    mirror_pt = squeeze(final_mirror_pts(:,curFrameIdx,:));
    frame_direct_p = squeeze(direct_p(:,curFrameIdx));
    frame_mirror_p = squeeze(mirror_p(:,curFrameIdx));
%     isPointValid{1} = ~direct_invalid_points(:,i_frame);
%     isPointValid{2} = ~mirror_invalid_points(:,i_frame);
    frameEstimate = squeeze(isEstimate(:,curFrameIdx,:));
    
    curFrame_out2 = overlayDLC_for_fig(curFrame_ud, points3D_wrt_camera, ...
        direct_pt, mirror_pt, frame_direct_p, frame_mirror_p, ...
        direct_bp, mirror_bp, bodyparts, frameEstimate, ...
        activeBoxCal, pawPref);
    
    
    switch pawPref
        % crop the images
        case 'left'
            if i_frame == 1
                mirror_img = curFrame_out2(cropRegion(3,2):cropRegion(3,4),cropRegion(3,1):cropRegion(3,3),:);
            else
                temp = curFrame_out2(cropRegion(3,2):cropRegion(3,4),cropRegion(3,1):cropRegion(3,3),:);
                mirror_img = [mirror_img;temp];
            end
        case 'right'
            if i_frame == 1
                mirror_img = curFrame_out2(cropRegion(2,2):cropRegion(2,4),cropRegion(2,1):cropRegion(2,3),:);
            else
                temp = curFrame_out2(cropRegion(2,2):cropRegion(2,4),cropRegion(2,1):cropRegion(2,3),:);
                mirror_img = [mirror_img;temp];
            end
            
    end
    if i_frame == 1
        direct_img = curFrame_out2(cropRegion(1,2):cropRegion(1,4),cropRegion(1,1):cropRegion(1,3),:);
    else
        temp = curFrame_out2(cropRegion(1,2):cropRegion(1,4),cropRegion(1,1):cropRegion(1,3),:);
        direct_img = [direct_img;temp];
    end

end

switch pawPref
    % crop the images
    case 'left'
        full_img = [direct_img,mirror_img];
    case 'right'
        full_img = [mirror_img,direct_img];
end
clear vidObj

h_fig = figure;
imshow(full_img);

% for annotating the images at the end
frameHeight = cropRegion(1,4)-cropRegion(1,2) + 1;
for i_frame = 1 : length(frames_of_interest)
    textPos = [frameTextPos(1),(i_frame-1)*frameHeight + frameTextPos(2)];
    textString = sprintf('frame %03d',frames_of_interest(i_frame));
    text(textPos(1),textPos(2),textString,'color','w')
end
