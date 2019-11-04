% script_assessReconstructionQuality

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';
vidRootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');

ratInfo = readtable(csvfname);
% ratInfo = readExcelDB(xlfname, 'well learned');
ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

isPointValid = cell(1,2);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders(i_rat).name;
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    if istable(ratInfo)
        thisRatInfo = ratInfo(ratInfo_idx,:);
    else
        thisRatInfo = ratInfo(ratInfo_idx);
    end
    if iscell(thisRatInfo.pawPref)
        pawPref = thisRatInfo.pawPref{1};
    else
        pawPref = thisRatInfo.pawPref;
    end
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    ratVidPath = fullfile(vidRootPath,ratID);   % root path for the original videos
    
    for iSession = 1 : numSessions
    
        fprintf('working on session %s\n', sessionDirectories{iSession});
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        vidDirectory = fullfile(ratVidPath,sessionDirectories{iSession});
        
        cd(fullSessionDir);
        
        matList = dir([ratID '_*_3dtrajectory.mat']);
        

        for iVid = 1 : length(matList)
            
            if exist('low_p_valid','var')
                clear reproj_error
                clear high_p_invalid
                clear low_p_valid
            end
            load(matList(iVid).name); 
            vidStartTime = triggerTime + frameTimeLimits(1);
            
%             if ~exist('low_p_valid','var')
                if iscell(thisRatInfo.pawPref)
                    pawPref = thisRatInfo.pawPref{1};
                else
                    pawPref = thisRatInfo.pawPref;
                end
                [reproj_error,high_p_invalid,low_p_valid] = assessReconstructionQuality(pawTrajectory, direct_pts, mirror_pts, direct_p, mirror_p, direct_bp, mirror_bp, bodyparts, ROIs, boxCal, pawPref);
                save(matList(iVid).name,'reproj_error','high_p_invalid','low_p_valid','thisRatInfo','-append');
%             end
            
        end
    end
end
            
%             vidName = [matList(iVid).name(1:27) '.avi'];
%             fullVidName = fullfile(vidDirectory,vidName);
%             vidOutName = [matList(iVid).name(1:27) '_marked'];
%             fullVidOutName = fullfile(fullSessionDir, vidOutName);
%             
%             iFrame = 1;
%             while hasFrame(vidIn)
%                 curFrame = readFrame(vidIn);
% 
%                 % need to undistort vidIn frames and points to mark
%                 curFrame_ud = undistortImage(curFrame, boxCal.cameraParams);
% 
%                 points3D = squeeze(pawTrajectory(iFrame,:,:))';
%                 direct_pt = squeeze(direct_pts(:,iFrame,:));
%                 mirror_pt = squeeze(mirror_pts(:,iFrame,:));
%                 frame_direct_p = squeeze(direct_p(:,iFrame));
%                 frame_mirror_p = squeeze(mirror_p(:,iFrame));
%                 isPointValid{1} = ~direct_invalid_points(:,iFrame);
%                 isPointValid{2} = ~mirror_invalid_points(:,iFrame);
% 
%                 curFrame_out = overlayDLCreconstruction(curFrame_ud, points3D, ...
%                     direct_pt, mirror_pt, frame_direct_p, frame_mirror_p, ...
%                     direct_bp, mirror_bp, bodyparts, isPointValid, ROIs, ...
%                     boxCal, pawPref);
%                 
%                 % summarize how many times high probability points are
%                 % declared invalid
%                 
% %                 writeVideo(vidOut,curFrame_out);
%                 
%                 iFrame = iFrame + 1; 
%             end
% 
%             close(vidOut);
%             
%         end
%         
%     end
%     
% end