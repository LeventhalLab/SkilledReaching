% script_exemplarKinematicsFig

labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
rootAnalysisFolder = '/Volumes/LL EXHD #2/SR opto analysis';
vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR_Opto_Raw_Data';

cropRegion = [];

exemplar_vidName = 'R0223_20180519_12-15-29_009';
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
load(interp_data_file);
% find the reach data for this part
pawPref = thisRatInfo.pawPref;

[reachDataIdx,trajectory_name] = identifyCorrectVidIdx(exemplar_vidName,exemplarKinematicsFolder);
load(trajectory_name);

current_reachData = reachData(reachDataIdx);
frames_of_interest = [287,300,current_reachData.reachEnds(1)];

cd(exemplarVidFolder);

vidObj = VideoReader(full_exemplar_vidName);

for i_frame = 1 : length(frames_of_interest)
    
    vidObj.CurrentTime = frames_of_interest(i_frame) / vidObj.FrameRate;
    
    curFrame = readFrame(vidObj);
    curFrame_ud = undistortImage(curFrame, activeBoxCal.cameraParams);
    
    points3D = squeeze(pawTrajectory(i_frame,:,:))';
    direct_pt = squeeze(final_direct_pts(:,i_frame,:));
    mirror_pt = squeeze(final_mirror_pts(:,i_frame,:));
    frame_direct_p = squeeze(direct_p(:,i_frame));
    frame_mirror_p = squeeze(mirror_p(:,i_frame));
%     isPointValid{1} = ~direct_invalid_points(:,i_frame);
%     isPointValid{2} = ~mirror_invalid_points(:,i_frame);
    frameEstimate = squeeze(isEstimate(:,i_frame,:));
    
    curFrame_out2 = overlayDLC_for_fig(curFrame_ud, points3D, ...
        direct_pt, mirror_pt, frame_direct_p, frame_mirror_p, ...
        direct_bp, mirror_bp, bodyparts, frameEstimate, ...
        activeBoxCal, pawPref);
    imshow(curFrame_out2)
end

clear vidObj