% script_manually_assign_endPtFrame

% script to manually assign reach end point frames when the algorithm fails

% labeledBodypartsFolder = '/Volumes/Tbolt_02/Skilled Reaching/DLC output';
% labeledBodypartsFolder = '/Volumes/Leventhal_lab_HD01/Skilled Reaching/DLC output';
labeledBodypartsFolder = '/Volumes/SharedX-1/Neuro-Leventhal/data/Skilled Reaching/DLC output/Rats';
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

for i_rat = 3:3%numRatFolders

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
            startSession = 17;
            endSession = 17;
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
            load(sessionSummaryName);
        catch
            fprintf('no session summary found for %s\n', sessionDirectories{iSession});
            continue
        end
        [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
%         numReachingParts = length([mcpIdx,pipIdx,digIdx,pawDorsumIdx]);
        
        vidDirectory = fullfile(ratVidPath,sessionDirectories{iSession});
%         cd(vidDirectory);
        
        nanEndPtFrame = isnan(all_endPtFrame);
        trialNumbers_nanEndPtFrame = trialNumbers(nanEndPtFrame,:);
        trialIdx_nanEndPtFrame = find(isnan(all_endPtFrame));
        
        foundTooManyReaches = (all_trialOutcomes == 1) & (all_numReaches > 1);
        trialIdx_tooManyReaches = find(foundTooManyReaches);
        missedTrials = foundTooManyReaches | nanEndPtFrame;
        missedTrials_idx = find(missedTrials);
        
        %%%%%%%%%%%%%%%
%         if want to work on a specific trial
        missedTrials = false(size(trialNumbers,1),1);
        missedTrials(71) = true;
        missedTrials_idx = find(missedTrials);
        %%%%%%%%%%%%%%%
        
        if ~any(missedTrials)
            continue;
        end
        
        if ~exist('isEndPtManuallyMarked','var')
            isEndPtManuallyMarked = false(size(trialNumbers,1),1);
        end
        for i_missedTrial = 1 : length(missedTrials_idx)
            curTrialNums = trialNumbers(missedTrials_idx(i_missedTrial),:);
            fprintf('reach end points for session %s, label %d, trial %d\n',[ratID sessionDateString], curTrialNums(1),curTrialNums(2));
            if foundTooManyReaches(missedTrials_idx(i_missedTrial))
                fprintf('too many reaches identified\n');
            elseif nanEndPtFrame(missedTrials_idx(i_missedTrial))
                fprintf('no reach identified\n');
            end
                
            if any(all_trialOutcomes(missedTrials_idx(i_missedTrial)) == [6,8,11]) || ...
                isEndPtManuallyMarked(missedTrials_idx(i_missedTrial))
                % exclude trials where paw started outside the slot or the
                % reach was with the wrong paw
                continue;
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
            set(gcf,'name',sprintf('%s, trial %d, %d, second digit',[ratID '_' sessionDateString], curTrialNums(1),curTrialNums(2)),...
                'position',[100   630   560   420]);
            
            h_dig3z = figure(2);
            hold off
            plot(q(:,2));
            hold on
            x1 = find(~isnan(q(:,2)),1,'first');
            x2 = find(~isnan(q(:,2)),1,'last');
            line([x1,x2],[slot_z_wrt_pellet,slot_z_wrt_pellet]);
            set(gcf,'name',sprintf('%s, trial %d, %d, third digit',[ratID '_' sessionDateString], curTrialNums(1),curTrialNums(2)),...
                'position',[700   630   560   420]);
            
            dig2_endFrames = input('reach endpoint frames for digit 2: ');
            dig3_endFrames = input('reach endpoint frames for digit 3: ');
            
            if isempty(dig2_endFrames) && isempty(dig3_endFrames)
                continue
            elseif isempty(dig2_endFrames)
                endPtFrame = dig3_endFrames(1);
                final_endPtFrame = dig3_endFrames(end);
            elseif isempty(dig3_endFrames)
                endPtFrame = dig2_endFrames(1);
                final_endPtFrame = dig3_endFrames(end);
            else
                endPtFrame = max(dig2_endFrames(1),dig3_endFrames(1));
                final_endPtFrame = max(dig2_endFrames(end),dig3_endFrames(end));
            end
            isEndPtManuallyMarked(missedTrials_idx(i_missedTrial)) = true;
            all_endPtFrame(missedTrials_idx(i_missedTrial)) = endPtFrame;
            all_final_endPtFrame(missedTrials_idx(i_missedTrial)) = final_endPtFrame;
            
            all_reachFrameIdx{missedTrials_idx(i_missedTrial)}{10} = dig2_endFrames;
            all_reachFrameIdx{missedTrials_idx(i_missedTrial)}{11} = dig3_endFrames;
            
            all_numReaches(missedTrials_idx(i_missedTrial)) = max(length(dig2_endFrames),length(dig3_endFrames));
            all_numReaches_byPart{10,missedTrials_idx(i_missedTrial)} = length(dig2_endFrames);
            all_numReaches_byPart{11,missedTrials_idx(i_missedTrial)} = length(dig3_endFrames);
            save(sessionSummaryName,'all_endPtFrame','all_final_endPtFrame','all_reachFrameIdx','isEndPtManuallyMarked','all_numReaches','-append');
            
            close(h_dig2z);close(h_dig3z)
        end
        
    end
    
end
        
        