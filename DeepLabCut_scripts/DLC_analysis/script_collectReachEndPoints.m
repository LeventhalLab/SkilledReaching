% script_collectReachEndPoints

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';

xlDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
csvfname = fullfile(xlDir,'rat_info_pawtracking_DL.csv');
ratInfo = readtable(csvfname);
ratInfo = cleanUpRatTable(ratInfo);

ratInfo_IDs = [ratInfo.ratID];

ratFolders = findRatFolders(labeledBodypartsFolder);
numRatFolders = length(ratFolders);

for i_rat = 2 : numRatFolders
    
    ratID = ratFolders{i_rat};
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
    
    sessionDirectories = listFolders([ratID '_2*']);   % all were recorded after the year 2000
    numSessions = length(sessionDirectories);
    
    reachEndPts = cell(numSessions,1);
    for iSession = 1 : numSessions
        
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        
        cd(fullSessionDir);
        
        sessionSummaryName = [ratID '_' sessionDate '_kinematicsSummary.mat'];
        
        load(sessionSummaryName);
        
        numTrials = size(allTrajectories,4);
        num_pawParts = size(all_endPts,1);
        
        reachEndPts{iSession} = NaN(numTrials,3);
        for iTrial = 1 : numTrials
            curTrajectory = squeeze(allTrajectories(:,:,1:num_pawParts, iTrial));   % note this indexing assumes the first "parts" belong to the paw
            lastPt = all_endPtFrame(iTrial);%min(all_partEndPtFrame(:,iTrial));
            cur_endPts = NaN(num_pawParts,3);
            for i_pawPart = 1 : num_pawParts
                cur_endPts(i_pawPart,:) = curTrajectory(lastPt,:,i_pawPart);
            end
            % find the paw part closest to the camera
            pawPartIdx = (cur_endPts(:,3) == min(cur_endPts(:,3)));
            
            % use the 2nd digit, which is generally visible in both views
            % at full reach extension.
            reachEndPts{iSession}(iTrial,:) = cur_endPts(10,:);
%             if sum(pawPartIdx == 1)
%                 try
%                     reachEndPts{iSession}(iTrial,:) = cur_endPts(pawPartIdx,:);
%                 catch
%                     keyboard
%                 end
%             end
        end
    end
    
    figure
    scatter3(0,0,0,25,'k','o','markerfacecolor','k')
    hold on
    scatter3(reachEndPts{1}(:,1),reachEndPts{1}(:,3),reachEndPts{1}(:,2),2,'b','.');
    scatter3(nanmean(reachEndPts{1}(:,1)),nanmean(reachEndPts{1}(:,3)),nanmean(reachEndPts{1}(:,2)),10,'b','+');
    
    scatter3(reachEndPts{3}(:,1),reachEndPts{3}(:,3),reachEndPts{3}(:,2),2,'r','.');
    scatter3(nanmean(reachEndPts{3}(:,1)),nanmean(reachEndPts{3}(:,3)),nanmean(reachEndPts{3}(:,2)),10,'r','+');
    set(gca,'zdir','reverse');
    xlabel('x');ylabel('z');zlabel('y')
    set(gcf,'name',ratID);
        
        
end