%%
xl_directory = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';
xlName = 'rubiks_matched_points_DL.xlsx';

camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
load(camParamFile);
boxCalibration.cameraParams = cameraParams;
K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
                                    %       version - Hartley and Zisserman and the rest of the world seem to
                                    %       use the transpose of matlab K)

sr_ratInfo = get_sr_RatList();

i_testRat = 1;

ratID = sr_ratInfo(i_testRat).ID;
rawdata_dir = sr_ratInfo(i_testRat).directory.rawdata;
processed_dir = sr_ratInfo(i_testRat).directory.processed;
pawPref = sr_ratInfo(i_testRat).pawPref;
sessionList = sr_ratInfo(i_testRat).sessionList;

sessionName = '20140521a';
vidNum = '013';
sessionDate = sessionName(1:8);
pawTrackName = [ratID '_' sessionDate '_' vidNum '_RGB_rel_track.mat'];

matchedPoints = read_xl_matchedPoints_rubik( ratID, ...
                                             'xldir', xl_directory, ...
                                             'xlname', xlName);
fullSessionName = [ratID '_' sessionName];
if (strcmp(sessionName,'20140528a') && i_rat == 1) || ...
   (strcmp(sessionName,'20140427a') && i_rat == 2)
    session_mp = matchedPoints.([fullSessionName(1:end-1) 'a']);
elseif isfield(matchedPoints,fullSessionName(1:end-1))
    session_mp = matchedPoints.(fullSessionName(1:end-1));
end                                
session_srCal = sr_calibration_mp(session_mp,'intrinsicmatrix',K);
boxCalibration.srCal = session_srCal;
switch pawPref
    case 'right'
        F = squeeze(boxCalibration.srCal.F(:,:,1));
    case 'left'
        F = squeeze(boxCalibration.srCal.F(:,:,2));
end

sessionIdx = strcmp(sessionList, sessionName);

curProcFolder = fullfile(processed_dir, fullSessionName);
cd(curProcFolder);
full_trackName = fullfile(curProcFolder,pawTrackName);
load(full_trackName);

%%
possVidName = [fullSessionName(1:end-1) '_*_' vidNum '_relRGB.avi'];
vidFile = dir(possVidName);

video = VideoReader(vidFile.name);
video.CurrentTime = track_metadata.triggerTime;
h = video.Height;
w = video.Width;
frameNum = round(video.FrameRate * track_metadata.triggerTime) + 1;
vidFrame = readFrame(video);
figure(1);imshow(vidFrame)
%%
for iView = 1 : 2
    pawPts{iView} = points2d{iView,frameNum};
end

[~,epipole] = isEpipoleInImage(F,[h,w]);

%%

switch lower(pawPref)
    case 'right'
        F = squeeze(boxCalibration.srCal.F(:,:,1));
        sf = sf(1);
    case 'left'
        F = squeeze(boxCalibration.srCal.F(:,:,2));
        sf = sf(2);
                            % need to figure out how I organized the scale factor matrix and comment that into the estimate scale function
                                                                   % looks like the columns are the view: 1 = left, 2 = right. The rows are the independent estimates for pairs of rubiks spacings. So, should take the mean across rows to estimate the scale factor in each mirror view                   
end
    
[x1_left,x2_left,x1_right,x2_right,leftMirrorPoints,rightMirrorPoints] = ...
    sr_sessionMatchedPointVector(session_mp);
[tform1,tform2] = estimateUncalibratedRectification(F,x1_left,x2_left,[h,w]);

%%
[ points3d ] = frame2d_to_3d_boundary( pawPts, boxCalibration, pawPref, [h,w], epipole );