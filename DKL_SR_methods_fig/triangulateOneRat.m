function points3d = triangulateOneRat(sr_ratInfo, cameraParams)

% NEED THE FRAME RATE FOR EACH SET OF VIDEOS

xl_directory = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';
xlName = 'rubiks_matched_points_DL.xlsx';

kinematics_rootDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Matlab Kinematics/PlotGrossTrajectory';

ratID = sr_ratInfo.ID;
kinematics_ratDir = fullfile(kinematics_rootDir,ratID);
processed_rootDir = sr_ratInfo.directory.processed;
rawdata_rootDir = sr_ratInfo.directory.rawdata;

K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
                                    %       version - Hartley and Zisserman and the rest of the world seem to
                                    %       use the transpose of matlab K)
                                    
matchedPoints = read_xl_matchedPoints_rubik( ratID, ...
                                             'xldir', xl_directory, ...
                                             'xlname', xlName);
[x1_left,x2_left,x1_right,x2_right,mp_metadata] = generateMatchedPointVectors(matchedPoints);
srCal = sr_calibration(x1_left,x2_left,x1_right,x2_right);
    
triDir = fullfile(kinematics_ratDir,'triData');
cd(triDir);
triDirList = dir('*.mat');

numSessions = length(triDirList);

for ii = 1 : length(triDirList)
    sessionDate{ii} = triDirList(ii).name(7:14);
end



for iSession = 1 : numSessions
    cd(processed_rootDir);
    
    rat_processedDir = dir([ratID '_' sessionDate{iSession} '*']);
    if length(rat_processedDir) ~= 1; continue; end
    
    processedDir = fullfile(processed_rootDir, rat_processedDir.name);
    cd(fullfile(processedDir, 'center', 'trials'));
    trialFiles = dir('*.mat');
    numTrials = length(trialFiles);
    
    session_srCal.F = squeeze(srCal.F(:,:,:,iSession));
    session_srCal.P = squeeze(srCal.P(:,:,:,iSession));
    session_srCal.E = squeeze(srCal.E(:,:,:,iSession));
    
    session_srCal.scale = sr_estimateScale(matchedPoints.(mp_metadata.sessionNames{iSession}), ...
                                                          squeeze(srCal.P(:,:,:,iSession)), ...
                                                          K);
                          
    for iTrial = 1 : numTrials
    
        trialNum = str2num(trialFiles(iTrial).name(end-6:end-4));
        
        points3d = triangulateOneTrial(sr_ratInfo, processedDir, session_srCal, cameraParams, trialNum);

    end
            

end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            