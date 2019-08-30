% script_manually_assign_endPtFrame

% script to manually assign the frame at which any of the digits breached the slot when the algorithm fails

% labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/Leventhal_lab_HD01/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/SharedX-1/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';
labeledBodypartsFolder = '/Volumes/LL EXHD #2/DLC output';
% shouldn't need this - calibration should be included in the pawTrajectory
% files
% calImageDir = '/Volumes/Tbolt_02/Skilled Reaching/calibration_images';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'rat_info_pawtracking_20190819.csv');
ratInfo = readRatInfoTable(csvfname);

% vidRootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
vidRootPath = '/Volumes/SharedX/Neuro-Leventhal/data/Skilled Reaching/SR Raw Data';
ratInfo_IDs = [ratInfo.ratID];

% paramaeters for readReachScores
csvDateFormat = 'MM/dd/yyyy';
ratIDs_with_new_date_format = [284];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

for i_rat = 6:numRatFolders

    ratID = ratFolders(i_rat).name
    ratIDnum = str2double(ratID(2:end));
    ratVidPath = fullfile(vidRootPath,ratID);   % root path for the original videos
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx,:);
    pawPref = thisRatInfo.pawPref;
    if iscategorical(pawPref)
        pawPref = char(pawPref);
    end
    if iscell(pawPref)
        pawPref = pawPref{1};
    end
    
%     if any(ratIDs_with_new_date_format == ratIDnum)
%         csvDateFormat = 'yyyyMMdd';
%     end
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    reachScoresFile = [ratID '_scores.csv'];
    reachScoresFile = fullfile(ratRootFolder,reachScoresFile);
    reachScores = readReachScores(reachScoresFile,'csvdateformat',csvDateFormat);
    allSessionDates = [reachScores.date]';
    
    numTableSessions = length(reachScores);
    dateNums_from_scores_table = zeros(numTableSessions,1);
    for iSession = 1 : numTableSessions
        dateNums_from_scores_table(iSession) = datenum(reachScores(iSession).date);
%         dateNums_from_scores_table(iSession) = datenum(reachScores(iSession).date,'mm/dd/yy');
    end
        
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    sessionType = determineSessionType(thisRatInfo, allSessionDates);
    
    switch ratID
        case 'R0158'
            startSession = 1;
            endSession = numSessions;
        case 'R0159'
            startSession = 5;
            endSession = numSessions;
        case 'R0160'
            startSession = 1;
            endSession = 22;
        case 'R0217'
            startSession = 1;
            endSession = numSessions;
        otherwise
            startSession = 1;
            endSession = numSessions;
    end
    for iSession = startSession : 1 : endSession
        
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDateString = C{1};
        sessionDate = datetime(sessionDateString,'inputformat','yyyyMMdd');
        sessionDates{iSession} = sessionDate;
        
        allSessionIdx = find(sessionDate == allSessionDates);
        
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        cd(fullSessionDir);
        
        sessionSummaryName = [ratID '_' sessionDateString '_kinematicsSummary.mat'];
        sessionSummaryName = fullfile(fullSessionDir, sessionSummaryName);
        try
            if exist('is_paw_through_slot_frame_ManuallyMarked','var')
                clear is_paw_through_slot_frame_ManuallyMarked
            end
            load(sessionSummaryName);
        catch
            fprintf('no session summary found for %s\n', sessionDirectories{iSession});
            continue
        end
        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
%         numReachingParts = length([mcpIdx,pipIdx,digIdx,pawDorsumIdx]);
        
%         vidDirectory = fullfile(ratVidPath,sessionDirectories{iSession});
%         cd(vidDirectory);
        
        nan_paw_through_slot_frame = isnan(all_paw_through_slot_frame);
        trialNumbers_nan_paw_through_slot_frame = trialNumbers(nan_paw_through_slot_frame,:);
        trialIdx_nan_paw_through_slot_frame = find(isnan(all_paw_through_slot_frame));
        
        frames_between_slot_and_endpoint = all_endPtFrame - all_paw_through_slot_frame;
        reachTooLong = frames_between_slot_and_endpoint > 30;
        trialIdx_reachTooLong = find(reachTooLong);
        
        slot_after_endpoint = all_endPtFrame <= all_paw_through_slot_frame;
        trialIdx_slot_after_endpoint = find(slot_after_endpoint);
        
        missedTrials = nan_paw_through_slot_frame | reachTooLong | slot_after_endpoint;
        missedTrials_idx = find(missedTrials);
        
        %%%%%%%%%%%%%%%
%         if want to work on a specific trial
%         missedTrials = false(size(trialNumbers,1),1);
%         missedTrials(end) = true;
%         missedTrials_idx = find(missedTrials);
        %%%%%%%%%%%%%%%
        
        if isempty(missedTrials_idx)
            continue;
        end
        
        if ~exist('is_paw_through_slot_frame_ManuallyMarked','var')
            is_paw_through_slot_frame_ManuallyMarked = false(size(trialNumbers,1),1);
        end
        for i_missedTrial = 1 : length(missedTrials_idx)
            curTrialNums = trialNumbers(missedTrials_idx(i_missedTrial),:);
            fprintf('paw through slot frame for session %s, label %d, trial %d\n',[ratID sessionDateString], curTrialNums(1),curTrialNums(2));
                
            if any(all_trialOutcomes(missedTrials_idx(i_missedTrial)) == [6,8,11]) || ...
                is_paw_through_slot_frame_ManuallyMarked(missedTrials_idx(i_missedTrial))
                % exclude trials where paw started outside the slot or the
                % reach was with the wrong paw
                continue;
            end
            
            if reachTooLong(missedTrials_idx(i_missedTrial))
                fprintf('%d frames between paw through slot and reach end\n',frames_between_slot_and_endpoint(missedTrials_idx(i_missedTrial)))
            elseif slot_after_endpoint(missedTrials_idx(i_missedTrial))
                fprintf('reach end point occurred before slot breach\n')
            end
            q = squeeze(allTrajectories(:,3,10:11,missedTrials_idx(i_missedTrial)));
            pellet_z = all_initPellet3D(missedTrials_idx(i_missedTrial),3);
            slot_z_wrt_pellet = slot_z - pellet_z;
            
            h_dig2z = figure(1);
            hold off
            plot(q(:,1));
            hold on
            x1 = find(~isnan(q(:,1)),1,'first');
            x2 = find(~isnan(q(:,1)),1,'last');
            line([x1,x2],[slot_z_wrt_pellet,slot_z_wrt_pellet]);
            
            % overlay the current reach end points
            cur_dig2_endFrames = all_reachFrameIdx{missedTrials_idx(i_missedTrial)}{10};
            if ~isempty(cur_dig2_endFrames)
                cur_dig2_reachPts = q(cur_dig2_endFrames,1);
                if isrow(cur_dig2_endFrames)
                    cur_dig2_endFrames = cur_dig2_endFrames';
                end
                if isrow(cur_dig2_reachPts)
                    cur_dig2_reachPts = cur_dig2_reachPts';
                end
                dig_2_endpoints = [cur_dig2_endFrames,cur_dig2_reachPts];
                h_endpts_dig2 = scatter(dig_2_endpoints(:,1),dig_2_endpoints(:,2),[],'g');
            else
                dig_2_endpoints = [];
            end
            
            % overlay the current paw through slot frames
            cur_paw_through_slot_frame = all_paw_through_slot_frame(missedTrials_idx(i_missedTrial));
            if ~isempty(cur_paw_through_slot_frame) && ~isnan(cur_paw_through_slot_frame)
                cur_dig2_start_z = q(cur_paw_through_slot_frame,1);
                dig_2_startPt = [cur_paw_through_slot_frame,cur_dig2_start_z];
                h_startpt_dig2 = scatter(dig_2_startPt(1),dig_2_startPt(2),[],'r');
            else
                dig_2_startPt = [];
            end
            set(gcf,'name',sprintf('%s, trial %d, %d, second digit',[ratID '_' sessionDateString], curTrialNums(1),curTrialNums(2)),...
                'position',[100   130   560   420]);
            dcm_obj_dig2 = datacursormode(h_dig2z);
            set(dcm_obj_dig2,'enable','on');
            dt_dig2 = add_data_tips(dcm_obj_dig2,h_startpt_dig2,dig_2_startPt);
            
            h_dig3z = figure(2);
            hold off
            plot(q(:,2));
            hold on
            x1 = find(~isnan(q(:,2)),1,'first');
            x2 = find(~isnan(q(:,2)),1,'last');
            line([x1,x2],[slot_z_wrt_pellet,slot_z_wrt_pellet]);
            
            % overlay the current reach end points
            cur_dig3_endFrames = all_reachFrameIdx{missedTrials_idx(i_missedTrial)}{11};
            if ~isempty(cur_dig3_endFrames)
                cur_dig3_reachPts = q(cur_dig3_endFrames,2);
                if isrow(cur_dig3_endFrames)
                    cur_dig3_endFrames = cur_dig3_endFrames';
                end
                if isrow(cur_dig3_reachPts)
                    cur_dig3_reachPts = cur_dig3_reachPts';
                end
                dig_3_endpoints = [cur_dig3_endFrames,cur_dig3_reachPts];
                h_endpts_dig3 = scatter(dig_3_endpoints(:,1),dig_3_endpoints(:,2),[],'g');
            else
                dig_3_endpoints = [];
            end
            % overlay the current paw through slot frames
            cur_paw_through_slot_frame = all_paw_through_slot_frame(missedTrials_idx(i_missedTrial));
            if ~isempty(cur_paw_through_slot_frame) && ~isnan(cur_paw_through_slot_frame)
                cur_dig3_start_z = q(cur_paw_through_slot_frame,2);
                dig_3_startPt = [cur_paw_through_slot_frame,cur_dig3_start_z];
                h_startpt_dig3 = scatter(dig_3_startPt(1),dig_3_startPt(2),[],'r');
            else
                dig_3_startPt = [];
            end
            
            set(gcf,'name',sprintf('%s, trial %d, %d, third digit',[ratID '_' sessionDateString], curTrialNums(1),curTrialNums(2)),...
                'position',[700   130   560   420]);
            dcm_obj_dig3 = datacursormode(h_dig3z);
            set(dcm_obj_dig3,'enable','on');
            dt_dig3 = add_data_tips(dcm_obj_dig3,h_startpt_dig3,dig_3_startPt);
            
            dig2_through_slot_frame = input('first paw through slot frame for digit 2: ');
            dig3_through_slot_frame = input('first paw through slot frame for digit 3: ');
            
            if isempty(dig2_through_slot_frame) && isempty(dig3_through_slot_frame)
                is_paw_through_slot_frame_ManuallyMarked(missedTrials_idx(i_missedTrial)) = true;
                save(sessionSummaryName,'all_paw_through_slot_frame','is_paw_through_slot_frame_ManuallyMarked','-append');
                continue
            elseif isempty(dig2_through_slot_frame)
                paw_through_slot_frame = dig3_through_slot_frame;
            elseif isempty(dig3_through_slot_frame)
                paw_through_slot_frame = dig2_through_slot_frame;
            else
                paw_through_slot_frame = min(dig2_through_slot_frame,dig3_through_slot_frame);
            end
            is_paw_through_slot_frame_ManuallyMarked(missedTrials_idx(i_missedTrial)) = true;
            all_paw_through_slot_frame(missedTrials_idx(i_missedTrial)) = paw_through_slot_frame;
            
            save(sessionSummaryName,'all_paw_through_slot_frame','is_paw_through_slot_frame_ManuallyMarked','-append');
            
            close(h_dig2z);close(h_dig3z)
        end
        clear is_paw_through_slot_frame_ManuallyMarked
        
    end
    
end
        
        