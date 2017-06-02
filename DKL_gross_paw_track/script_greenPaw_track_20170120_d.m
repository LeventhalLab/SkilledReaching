% script_greenPaw_track_20151223
% testing identification of tattooed paw and digits

% algorithm outline:
% first issue: correctly identify colored paw regions

% 1) calibrate based on rubiks image to get fundamental matrix
%       - mark matching points either manually or automatically. manually
%       is probably going to be more accurate until we put clearer markers
%       in.
%       - create matrices of matching points coordinates and calculate F
%       for left to center and right to center
% 2) 


% criteria we can use to identify the paw:
%   1 - the paw is moving
%   2 - dorsum of the paw is (mostly) green
%   3 - palmar aspect is (mostly) pink
%   4 - it's different from the background image  

% REACHING SCORES:
% 0 - no pellet presented or other mechanical failure
% 1 - first trial success (obtained pellet on initial limb advance)
% 2 - success (obtained pellet, but not on first attempt)
% 3 - forelimb advanced, pellet was grasped then dropped in the box
% 4 - forelimb advanced, but the pellet was knocked off the shelf
% 5 - pellet was obtained with its tongue
% 6 - the rat approached the slot but retreated without advancing its forelimb
% 7 - the rat reached, but the pellet remained on the shelf
% 8 - the rat used its contralateral paw.

validScores = [1,2,3,4,7];    % scores for which there was a reach
%%
numBGframes = 20;
gray_paw_limits = [60 125] / 255;
foregroundThresh = 15/255;

targetMean = [0.5,0.1,0.5];
targetSigma = [0.2,0.2,0.2];

whiteThresh_ext = 0.90;
whiteThresh_int = 0.85;

stretch_hist_limit_int = 0.5;
stretch_hist_limit_ext = 0.75;

% pawHSVrange = [0.33, 0.05, 0.95, 1.0, 0.95, 1.0   % pick out anything that's green and bright
%                0.33, 0.03, 0.98, 1.0, 0.98, 1.0     % pick out anything that's green and bright immediately behind the front panel
%                0.50, 0.50, 0.95, 1.0, 0.95, 1.0
%                0.00, 0.16, 0.90, 1.0, 0.90, 1.0       % find red objects
%                0.33, 0.10, 0.85, 1.0, 0.85, 1.0          % liberal green mask
%                0.33, 0.005, 0.999, 1.0, 0.999, 1.0
%                0.33, 0.05, 0.95, 1.0, 0.95, 1.0];  % slighly more liberal for the external mask
           
% pawHSVrange = [1/3, 0.01, 0.999, 1.0, 0.99, 1.0   % for restrictive external masking
%                1/3, 0.03, 0.99, 1.0, 0.97, 1.0     % for more liberal external masking
%                1/3, 0.01, 0.999, 1.0, 0.99, 1.0    % for restrictive internal masking
%                1/3, 0.03, 0.99, 1.0, 0.95, 1.0    % for liberal internal masking
%                1/3, 0.01, 0.999, 1.0, 0.99, 1.0    % for restrictive masking just behind the front panel
%                1/3, 0.03, 0.99, 1.0, 0.95, 1.0    % for liberal masking just behind the front panel
%                0.00, 0.02, 0.00, 0.001, 0.999, 1.0];  % for white masking
           
pawHSVrange = [1/3, 0.01, 0.999, 1.0, 0.99, 1.0   % for restrictive external masking
               1/3, 0.02, 0.99, 1.0, 0.97, 1.0     % for more liberal external masking
               1/3, 0.001, 0.999, 1.0, 0.90, 1.0    % for restrictive internal masking
               1/3, 0.002, 0.990, 1.0, 0.70, 1.0    % for liberal internal masking
               0.35, 0.02, 0.999, 1.0, 0.6, 1.0    % for restrictive masking just behind the front panel
               0.35, 0.03, 0.99, 1.0, 0.5, 1.0    % for liberal masking just behind the front panel
               1/3, 0.015, 0.99, 1.0, 0.50, 1.0];  % for masking out green in the background image
foregroundThresh = 25/255;

xl_directory = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';
xlName = 'rubiks_matched_points_DL.xlsx';
cb_path = '/Users/dan/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
% num_rad_coeff = 2;
% est_tan_distortion = false;
% estimateSkew = false;

camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
load(camParamFile);
boxCalibration.cameraParams = cameraParams;
K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
                                    %       version - Hartley and Zisserman and the rest of the world seem to
                                    %       use the transpose of matlab K)
% [cameraParams, ~, ~] = cb_calibration(...
%                        'cb_path', cb_path, ...
%                        'num_rad_coeff', num_rad_coeff, ...
%                        'est_tan_distortion', est_tan_distortion, ...
%                        'estimateskew', estimateSkew);
                   
sr_ratInfo = get_sr_RatList();     
for i_rat = 2 : 2%length(sr_ratInfo)
    
    ratID = sr_ratInfo(i_rat).ID;
    rawdata_dir = sr_ratInfo(i_rat).directory.rawdata;
    processed_dir = sr_ratInfo(i_rat).directory.processed;
    
    sessionList = sr_ratInfo(i_rat).sessionList;
%     startDateNum = datenum(sr_ratInfo(i_rat).date.start, 'yyyymmdd');
%     endDateNum = datenum(sr_ratInfo(i_rat).date.end, 'yyyymmdd');
    matchedPoints = read_xl_matchedPoints_rubik( ratID, ...
                                                 'xldir', xl_directory, ...
                                                 'xlname', xlName);

    for iSession = 13:13%14:length(sessionList)
        
        sessionName = sessionList{iSession};
        fullSessionName = [ratID '_' sessionName];
        curDateStr = sessionName(1:8);
        
        
        % IF R0027 5/28, NEED TO USE TWO DIFFERENT SETS OF
        % MATCHED POINTS AND FUNDAMENTAL MATRICES BECAUSE THE LEFT MIRROR
        % MOVED DURING TRIAL 004
        
        % SIMILARLY, IF R0028, 4/27, NEED TO USE TWO DIFFERENT SETS OF
        % MATCHED POINTS AND FUNDAMENTAL MATRICES BECAUSE THE CAMERA MOVED
        % BETWEEN TRIALS 11 AND 12
        
        if (strcmp(sessionName,'20140528a') && i_rat == 1) || ...
           (strcmp(sessionName,'20140427a') && i_rat == 2)
            session_mp = matchedPoints.([fullSessionName(1:end-1) 'a']);
        elseif isfield(matchedPoints,fullSessionName(1:end-1))
            session_mp = matchedPoints.(fullSessionName(1:end-1));
        else
            continue;
        end
        session_srCal = sr_calibration_mp(session_mp,'intrinsicmatrix',K);
        boxCalibration.srCal = session_srCal;
        
        vidFolderNames = appendLetters2String([ratID '_' curDateStr]);
        
        for iFolder = 1 : size(vidFolderNames, 1)
            curRawFolder = fullfile(rawdata_dir, vidFolderNames(iFolder,:));
            if ~exist(curRawFolder,'dir'); continue; end
            curProcFolder = fullfile(processed_dir, vidFolderNames(iFolder,:));
            cd(curProcFolder);
            csvInfo = dir('*.csv');
            
            if length(csvInfo) > 1
                for ii = 1 : length(csvInfo)
                    if strcmpi(csvInfo(ii).name(1:2),'._'); continue; end
                    csvInfo = csvInfo(ii);
                    break;
                end
            end
            
            if length(csvInfo) == 1
                fid = fopen(csvInfo.name);
                readInfo = textscan(fid,'%f %f %f %f %f %f','delimiter',',','HeaderLines',0);
                fclose(fid);

                csv_trialNums = readInfo{1};
                csv_scores = readInfo{2};
            end

            cd(curRawFolder)
            
            vidList = dir('*.avi');
            
            BGcalculated = false;
            
            for iVid = 1 : length(vidList)
                if vidList(iVid).bytes < 10000; continue; end
                if strcmp(vidList(iVid).name(1:2),'._'); continue; end
                
                currentVidName = vidList(iVid).name
                currentVidNumber = currentVidName(end-6:end-4);
                
                scoreIdx = find(csv_trialNums == str2double(currentVidNumber));
                
                if ~any(validScores == csv_scores(scoreIdx)); continue; end
                                
                disp(currentVidName)

                video = VideoReader(currentVidName);
                h = video.Height;
                w = video.Width;
                
                BGimg_udName = [fullSessionName(1:end-1) '_' currentVidNumber '_BG_ud.bmp'];
                pawTrackName = [fullSessionName(1:end-1) '_' currentVidNumber '_RGB_rel_track.mat'];
                pawTrackName = fullfile(curProcFolder,pawTrackName);
                
                
                
                if exist(pawTrackName,'file');continue;end
%                 % TAKE OUT THIS COMMENT TO SKIP PREVIOUSLY PROCESSED
%                 VIDEOS
                
                if strcmp(sessionName,'20140528a') && i_rat == 1 &&  str2num(currentVidNumber) > 4
                    session_mp = matchedPoints.([fullSessionName(1:end-1) 'b']);
                    session_srCal = sr_calibration_mp(session_mp,'intrinsicmatrix',K);
                    boxCalibration.srCal = session_srCal;
                end
                
                if strcmp(sessionName,'20140427a') && i_rat == 2 &&  str2num(currentVidNumber) > 11
                    session_mp = matchedPoints.([fullSessionName(1:end-1) 'b']);
                    session_srCal = sr_calibration_mp(session_mp,'intrinsicmatrix',K);
                    boxCalibration.srCal = session_srCal;
                end
                
                boxRegions = boxRegionsfromMatchedPoints(session_mp, [h,w]);
                
                if exist(BGimg_udName,'file')
                    BGimg_ud = imread(BGimg_udName,'bmp');
%                     greenBGmask = findGreenBG_relRGB(BGimg_ud, boxRegions, sr_ratInfo(i_rat).pawPref, boxCalibration);
%                     greenBGmask = findGreenBG(BGimg_ud, boxRegions, pawHSVrange(7,:), sr_ratInfo(i_rat).pawPref);
                end
%                 if ~BGcalculated
%                     BGcalculated = true;
%                     BGimg = extractBGimg( video, 'numbgframes', numBGframes);
%                     BGimg_ud = undistortImage(BGimg, cameraParams);
%                 end
                
                
%                 triggerTime = identifyTriggerTime_greenPaw( video, sr_ratInfo(i_rat), session_mp, cameraParams,...
%                                                    'pawgraylevels',gray_paw_limits,...
%                                                    'hsvlimits',pawHSVrange,...
%                                                    'targetmean',targetMean,...
%                                                    'targetsigma',targetSigma);
                triggerTime = identifyTriggerTime_greenPaw_relRGB( video, sr_ratInfo(i_rat), session_mp, cameraParams);


                                               
                track_metadata.triggerTime = triggerTime;
                track_metadata.boxCalibration = boxCalibration;
                
                video.CurrentTime = triggerTime;
                image = readFrame(video);
                if strcmpi(class(image),'uint8')
                    image = double(image) / 255;
                end
                image_ud = undistortImage(image, cameraParams);
                
%                 initPawMask = find_initPawMask_greenPaw_relRGB( image_ud, BGimg_ud, sr_ratInfo(i_rat), session_mp, boxCalibration, boxRegions,greenBGmask,...
%                     'hsvlimits', pawHSVrange,...
%                     'foregroundthresh',foregroundThresh,...
%                     'targetmean',targetMean,...
%                     'targetsigma',targetSigma);
                initPawMask = find_initPawMask_greenPaw_relRGB_20170208_d( image_ud, BGimg_ud, sr_ratInfo(i_rat), session_mp, boxCalibration, boxRegions,greenBGmask);
                
%                 [ PCAcoeff, PCA_paw_hist, PCA_nonpaw_hist, PCAbinEdges ] = pawPCAregions( image_ud, initPawMask );
%                 [ PCAcoeff, PCAmean, PCAmean_nonPaw, PCAcovar ] = pawPCAregions( image_ud, initPawMask );

%                 initPawMask = find_initPawMask_greenPaw_mirror( video, BGimg_ud, sr_ratInfo(i_rat), session_mp, boxCalibration, boxRegions,triggerTime,'hsvlimits', pawHSVrange,'foregroundthresh',foregroundThresh);

                                  
%                 [points3d,points2d,timeList,isPawVisible] = trackGreenPaw_20160204(video, BGimg_ud, sr_ratInfo(i_rat), session_mp, triggerTime, initPawMask, boxCalibration,boxRegions,...
%                     'hsvlimits', pawHSVrange,...
%                     'foregroundthresh',foregroundThresh);
                
%                 [points2d,timeList,isPawVisible_mirror] = trackMirrorView_relRGB(video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo(i_rat), boxRegions,boxCalibration,...
%                     'hsvlimits', pawHSVrange,...
%                     'foregroundthresh',foregroundThresh,...
%                     'targetmean',targetMean,...
%                     'targetsigma',targetSigma,...
%                     'whitethresh_ext',whiteThresh_ext,...
%                     'whitethresh_int',whiteThresh_int,...
%                     'stretch_hist_limit_int',stretch_hist_limit_int,...
%                     'stretch_hist_limit_ext',stretch_hist_limit_ext);
                
                [points2d,timeList,isPawVisible_mirror] = trackMirrorView_relRGB_20170208_d(video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo(i_rat), boxRegions,boxCalibration,greenBGmask);
%                 [points2d,timeList,isPawVisible_mirror] = trackMirrorView_relRGB_PCA(video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo(i_rat), boxRegions,boxCalibration,PCAcoeff,PCA_paw_hist,PCA_nonpaw_hist,PCAbinEdges);
                
                save(pawTrackName,'points2d','timeList','isPawVisible_mirror','track_metadata');
            end    % for iVid
        end    % for iFolder

    
    end
    
end
