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
foregroundThresh = 25/255;

pawHSVrange = [1/3, 0.01, 0.999, 1.0, 0.99, 1.0   % for restrictive external masking
               1/3, 0.03, 0.99, 1.0, 0.97, 1.0     % for more liberal external masking
               1/3, 0.01, 0.999, 1.0, 0.99, 1.0    % for restrictive internal masking
               1/3, 0.03, 0.99, 1.0, 0.95, 1.0    % for liberal internal masking
               1/3, 0.01, 0.999, 1.0, 0.99, 1.0    % for restrictive masking just behind the front panel
               1/3, 0.03, 0.99, 1.0, 0.95, 1.0    % for liberal masking just behind the front panel
               1/3, 0.015, 0.99, 1.0, 0.50, 1.0
               1/3, 0.02, 0.99, 1.0, 0.9, 1.0];  % for green masking below the shelf
           
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
    for iSession = 7 : 7%length(sessionList);
        
        if exist('session_mp','var')
            clear session_mp;
        end
        if exist('session_srCal','var')
            clear session_srCal;
        end
        
        sessionName = sessionList{iSession};
        fullSessionName = [ratID '_' sessionName];
        curDateStr = sessionName(1:8);
        
        % IF R0027 5/28, NEED TO USE TWO DIFFERENT SETS OF
        % MATCHED POINTS AND FUNDAMENTAL MATRICES BECAUSE THE LEFT MIRROR
        % MOVED DURING TRIAL 004
        
        % SIMILARLY, IF R0028, 4/27, NEED TO USE TWO DIFFERENT SETS OF
        % MATCHED POINTS AND FUNDAMENTAL MATRICES BECAUSE THE CAMERA MOVED
        % BETWEEN TRIALS 11 AND 12
        
        if isfield(matchedPoints,fullSessionName(1:end-1))    % ugly workaround for mirrors shifting during 20140528 session for R0027
            session_mp{1} = matchedPoints.(fullSessionName(1:end-1));
            session_mp{2} = matchedPoints.(fullSessionName(1:end-1));
        elseif strcmp(curDateStr, '20140528') && strcmp(ratID,'R0027')
            session_mp{1} = matchedPoints.R0027_20140528a;
            session_mp{2} = matchedPoints.R0027_20140528b;
        elseif (strcmp(sessionName,'20140427a') && i_rat == 2)  
            session_mp{1} = matchedPoints.R0028_20140427a;
            session_mp{2} = matchedPoints.R0028_20140427b;
        else
            continue;
        end
        for iSessionCal = 1 : 2
            session_srCal{iSessionCal} = sr_calibration_mp(session_mp{iSessionCal},'intrinsicmatrix',K);
        end
        
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
            
            for iVid = 84 : length(vidList)
                if vidList(iVid).bytes < 10000; continue; end
                if strcmp(vidList(iVid).name(1:2),'._'); continue; end
                
                currentVidName = vidList(iVid).name
                currentVidNumber = currentVidName(end-6:end-4);
                scoreIdx = find(csv_trialNums == str2double(currentVidNumber));
                
                if str2double(currentVidNumber) < 4
                    boxCalibration.srCal = session_srCal{1};
                    cur_session_mp = session_mp{1};
                else
                    boxCalibration.srCal = session_srCal{2};
                    cur_session_mp = session_mp{2};
                end
                if ~any(validScores == csv_scores(scoreIdx)); continue; end
                
                disp(currentVidName)

                video = VideoReader(currentVidName);
                h = video.Height;
                w = video.Width;
                
                BGimg_udName = [fullSessionName(1:end-1) '_' currentVidNumber '_BG_ud.bmp'];
                pawTrackMirrorName = [fullSessionName(1:end-1) '_' currentVidNumber '_mirror_track.mat'];
                pawTrackName = [fullSessionName(1:end-1) '_' currentVidNumber '_full_track.mat'];
                pawTrackMirrorName = fullfile(curProcFolder,pawTrackMirrorName);
                pawTrackName = fullfile(curProcFolder,pawTrackName);
                
                if exist(pawTrackName,'file');continue;end
                
                boxRegions = boxRegionsfromMatchedPoints(cur_session_mp, [h,w]);
                boxRegions.floorCoords = estimateFloor_3dcoords(cur_session_mp,boxCalibration);
                
                if exist(BGimg_udName,'file')
                    BGimg_ud = imread(BGimg_udName,'bmp');
                    greenBGmask = findGreenBG(BGimg_ud, boxRegions, pawHSVrange(2,:), sr_ratInfo(i_rat).pawPref);
                end
%                 if ~BGcalculated
%                     BGcalculated = true;
%                     BGimg = extractBGimg( video, 'numbgframes', numBGframes);
%                     BGimg_ud = undistortImage(BGimg, cameraParams);
%                 end
                
                if exist(pawTrackMirrorName,'file');
                    load(pawTrackMirrorName);
                    triggerTime = track_metadata.triggerTime;
%                     initPawMask = find_initPawMask_greenPaw_mirror( video, BGimg_ud, sr_ratInfo(i_rat), session_mp, boxCalibration, boxRegions,triggerTime,'hsvlimits', pawHSVrange,'foregroundthresh',foregroundThresh);
%                     initPawMask = find_initPawMask_greenPaw_mirror_20160330( video, BGimg_ud, sr_ratInfo(i_rat), session_mp, boxCalibration, boxRegions,triggerTime,...
%                                         'hsvlimits', pawHSVrange,...
%                                         'foregroundthresh',foregroundThresh,...
%                                         'targetmean',targetMean,...
%                                         'targetsigma',targetSigma);
                    initPawMask = find_initPawMask_greenPaw_direct( video, BGimg_ud, sr_ratInfo(i_rat), cur_session_mp, mirror_points2d,boxCalibration, boxRegions,triggerTime,greenBGmask,...
                                        'hsvlimits', pawHSVrange,...
                                        'foregroundthresh',foregroundThresh);
                else
                    triggerTime = identifyTriggerTime_greenPaw( video, BGimg_ud, sr_ratInfo(i_rat), cur_session_mp, mirror_points2d, cameraParams,...
                                                       'pawgraylevels',gray_paw_limits,...
                                                       'hsvlimits',pawHSVrange);
                    track_metadata.triggerTime = triggerTime;
                    track_metadata.boxCalibration = boxCalibration;
                    initPawMask = find_initPawMask_greenPaw_20160309( video, BGimg_ud, sr_ratInfo(i_rat), cur_session_mp, boxCalibration, boxRegions,triggerTime,'hsvlimits', pawHSVrange,'foregroundthresh',foregroundThresh);
                    [mirror_points2d,~,isPawVisible_mirror] = trackMirrorView(video, triggerTime, initPawMask, BGimg_ud, sr_ratInfo(i_rat), boxRegions,boxCalibration,...
                        'hsvlimits', pawHSVrange,...
                        'foregroundthresh',foregroundThresh);
                end
                    
               
                [points3d,points2d,timeList,isPawVisible] = trackDirectView_c(video, triggerTime, initPawMask, mirror_points2d, BGimg_ud, sr_ratInfo(i_rat), boxRegions,boxCalibration,greenBGmask,...
                    'hsvlimits', pawHSVrange,...
                    'foregroundthresh',foregroundThresh);
                
%                 [points3d,points2d,timeList,isPawVisible] = trackGreenPaw_20160302(video, BGimg_ud, sr_ratInfo(i_rat), session_mp, triggerTime, initPawMask, boxCalibration,boxRegions,...
%                     'hsvlimits', pawHSVrange,...
%                     'foregroundthresh',foregroundThresh);
%                 points2d{1} = direct_points2d;
%                 points2d{2} = mirror_points2d;
%                 isPawVisible = [isPawVisible_mirror,isPawVisible_direct];
                save(pawTrackName,'points2d','points3d','timeList','isPawVisible','track_metadata');
            end    % for iVid
        end    % for iFolder

    
    end
    
end
