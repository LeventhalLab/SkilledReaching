function triangulateOneRat(sr_ratInfo, cameraParams)
%
% INPUTS:
%   sr_ratInfo - single element of the sr_ratInfo structure array generated
%       by get_sr_RatList
%   cameraParams - standard matlab camera parameters structure
%
% OUTPUTS:
%   none
%
% NEED THE FRAME RATE FOR EACH SET OF VIDEOS

xl_directory = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';
xlName = 'rubiks_matched_points_DL.xlsx';

% kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';

ratID = sr_ratInfo.ID;
% kinematics_ratDir = fullfile(kinematics_rootDir,ratID);
processed_rootDir = sr_ratInfo.directory.processed;
rawdata_rootDir = sr_ratInfo.directory.rawdata;

K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
                                    %       version - Hartley and Zisserman and the rest of the world seem to
                                    %       use the transpose of matlab K)
                                    
matchedPoints = read_xl_matchedPoints_rubik( ratID, ...
                                             'xldir', xl_directory, ...
                                             'xlname', xlName );
[x1_left,x2_left,x1_right,x2_right,mp_metadata] = generateMatchedPointVectors(matchedPoints);
% srCal = sr_calibration(x1_left,x2_left,x1_right,x2_right);
    
% triDir = fullfile(kinematics_ratDir,'triData');
% cd(triDir);
% triDirList = dir('*.mat');

sessionList = sr_ratInfo.sessionList;
numSessions = length(sessionList);

sessionDate = cell(1,numSessions);
for iSession = 12:14%1 : numSessions
    sessionDate{iSession} = sessionList{iSession}(1:8);
    
    cd(processed_rootDir);
    
    fullSessionName = [ratID '_' sessionDate{iSession}];
    fprintf('working on session %s, %d of %d\n', ...
             fullSessionName, iSession, numSessions);
    
    if ~isfield(matchedPoints,fullSessionName)
        disp('No calibration image for this session');
        continue;
    end
    session_mp = matchedPoints.(fullSessionName);
    
    rat_processedDir = dir([fullSessionName '*']);
    if length(rat_processedDir) ~= 1; continue; end
    
    processedDir = fullfile(processed_rootDir, rat_processedDir.name);
    reconstruction_name = [rat_processedDir.name '_trajectories.mat'];
    reconstruction_name = fullfile(processedDir, reconstruction_name);
%     if exist(reconstruction_name,'file')   % if reconstruction file already exists, skip
%         points3d = [];
%         trajectory_metadata = [];
%         continue;
%     end
    
    rawdataDir = fullfile(rawdata_rootDir, rat_processedDir.name);
    
    cd(rawdataDir);
    vidList = dir('*.avi');
    for iVid = 1 : length(vidList)
        if strcmp(vidList(iVid).name(1:2),'._')
            continue;
        end
        video = VideoReader(vidList(iVid).name);
        trajectory_metadata.frameRate = video.FrameRate;
        trajectory_metadata.numFrames = video.FrameRate * video.Duration;
        break;
    end
    
%     csvInfo = dir('*.csv');
%     if isempty(csvInfo)
        cd(processedDir);
        csvInfo = dir('*.csv');
%     end
    if length(csvInfo) == 1
        fid = fopen(csvInfo.name);
        readInfo = textscan(fid,'%f %f %f %f %f %f','delimiter',',','HeaderLines',0);
        fclose(fid);
        
        trajectory_metadata.csv_trialNums = readInfo{1};
        trajectory_metadata.csv_scores = readInfo{2};
    end

    cd(fullfile(processedDir, 'center', 'trials'));
    trialFiles = dir('*.mat');
    numTrials = length(trialFiles);
    
    session_srCal = sr_calibration_mp(session_mp,'intrinsicmatrix',K);
%     session_srCal.F = squeeze(srCal.F(:,:,:,iSession));
%     session_srCal.P = squeeze(srCal.P(:,:,:,iSession));
%     session_srCal.E = squeeze(srCal.E(:,:,:,iSession));
    
%     session_srCal.scale = sr_estimateScale(matchedPoints.(mp_metadata.sessionNames{iSession}), ...
%                                                           squeeze(srCal.P(:,:,:,iSession)), ...
%                                                           K);
	
    trajectory_metadata.trial_numbers = zeros(1,numTrials);
    trajectory_metadata.session_srCal = session_srCal;
    trajectory_metadata.matchedCalPoints = session_mp;
    for iTrial = 1 : numTrials
%         iTrial
        trialNum = str2num(trialFiles(iTrial).name(end-6:end-4));
        pawData = load_pawTrackData(processedDir, trialNum);
        if iTrial == 1
            points3d = NaN(size(pawData,1),3,numTrials);
        end
        trajectory_metadata.trial_numbers(iTrial) = trialNum;
        
        points3d(:,:,iTrial) = triangulateOneTrial(sr_ratInfo, session_srCal, cameraParams, pawData);
    end
            
    save(reconstruction_name,'points3d','trajectory_metadata');

end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            