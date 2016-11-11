xl_directory = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/R118_136_analysis';
% xl_file = 'R118_R136_vidTimes.csv';
% xl_file = fullfile(xl_directory, xl_file);

trialRow = 7;
maxTrials = 150;

root_SRdir = '/Volumes/RecordingsLeventhal04/SkilledReaching/';

opto_SR_rats = getOptoSR_rats();

for i_rat = 11 : length(opto_SR_rats)
    
    ratID = opto_SR_rats(i_rat).ratID;
    
    text_file = sprintf('R%03d_vidTimes.txt',ratID);
    text_file = fullfile(xl_directory,text_file);
    
    ratID_str = sprintf('R%04d',ratID);
    rawDataDir = fullfile(root_SRdir, ratID_str, [ratID_str '-rawdata']);
    
    startDateStr = opto_SR_rats(i_rat).startDate;
    if isempty(opto_SR_rats(i_rat).endDate)
        endDateStr = '12-31-2050';
    else
        endDateStr = opto_SR_rats(i_rat).endDate;
    end
    
    startDateNum = datenum(startDateStr,'mm-dd-yyyy');
    endDateNum = datenum(endDateStr,'mm-dd-yyyy');
    
    if ~exist(rawDataDir,'dir'); continue; end
    
    cd(rawDataDir);
    
    dirList = dir;
    
    sessionDates = cell(1,1);
    numValidDates = 0;
    
    finalCell = cell(maxTrials + 1,1);
    for iDir = 1 : length(dirList)
        if length(dirList(iDir).name) < 15; continue; end
        if strcmp(dirList(iDir).name(1:2),'._'); continue; end
        if ~isempty(strfind(dirList(iDir).name,'accident')); continue; end
        
        curDate = dirList(iDir).name(7:14);
        curDateNum = datenum(curDate,'yyyymmdd');
        curDateStr = datestr(curDateNum,'mm-dd-yyyy');
        
        if curDateNum < startDateNum || curDateNum > endDateNum
            continue;
        end
        
        if any(strcmpi(sessionDates, curDate))    % all the folders for this date should have already been checked
            continue;
        end
        numValidDates = numValidDates + 1;
        sessionDates{numValidDates} = curDate;
            
        % find all sessions that occurred on the current date
        numSessionsPerDate = 0;
        for ii = 1 : length(dirList)
            if length(dirList(ii).name) < 15; continue; end
            if strcmp(dirList(ii).name(1:2),'._'); continue; end
            if ~isempty(strfind(dirList(ii).name,'accident')); continue; end
            if strcmpi(dirList(ii).name(7:14), curDate)
                numSessionsPerDate = numSessionsPerDate + 1;
                sessionDateIdx(numSessionsPerDate) = ii;
            end
        end
        
        % loop through each folder for this date and create a list of all
        % videos for this date
        numValidVids = 0;
        vidTimeStr = cell(1,1);
        finalVidNumberStr = blanks(3);
        vidSession = [];
        vidNumber = [];
        lastSessionVidNum = zeros(numSessionsPerDate,1);
        numLogFiles = 0;
        logTimeStr = cell(1,1);
        logTimeNum = [];
        for ii = 1 : numSessionsPerDate
            
            curSessionDir = fullfile(rawDataDir, dirList(sessionDateIdx(ii)).name);
            if ~isdir(curSessionDir); continue; end
            
            cd(curSessionDir);
            
            vidList = dir('*.avi');
            logList = dir('*.log');
            
            if isempty(vidList); continue; end
            
            for iVid = 1 : length(vidList)
                if vidList(iVid).bytes < 10000; continue; end
                if strcmp(vidList(iVid).name(1:2),'._'); continue; end
                
                numValidVids = numValidVids + 1;
                tempTimeStr = vidList(iVid).name(16:23);
                tempTimeStr = strrep(tempTimeStr,'-',':');
                
                vidNumberStr = vidList(iVid).name(25:27);
                vidNumber(numValidVids,1) = str2double(vidNumberStr);
                vidTimeStr{numValidVids} = tempTimeStr;
                vidSession(numValidVids) = ii;                
            end

            % not really using the .log files for anything now, but will
            % hold onto this code in case they're useful in the future
            for iLog = 1 : length(logList);
                if strcmp(logList(iLog).name(1:2),'._'); continue; end
                
                cur_logTimeStr = logList(iLog).name(16:23);
                cur_logTimeNum = datenum(cur_logTimeStr,'HH-MM-SS');
                if any(logTimeNum == cur_logTimeNum); continue; end   % this log file was already found
                
                numLogFiles = numLogFiles + 1;
                logTimeStr{numLogFiles} = logList(iLog).name(16:23);
                logTimeNum(numLogFiles) = datenum(logTimeStr{numLogFiles},'HH-MM-SS');
            end
            
        end
%         logTimeNum = sort(logTimeNum);
        if numValidVids == 0; continue; end
        
        % now have a full list of video numbers and times; only use the
        % unique times
        for ii = 1 : numValidVids
            % comnpare current date and vid number to all others, make sure
            % there's only one time in the list
            testCellArray = vidTimeStr;
            testCellArray{ii} = 'test';
            repeatedTimes = strcmpi(testCellArray, vidTimeStr{ii});
            isTimeRepeated = any(repeatedTimes);
            if isTimeRepeated
                vidTimeStr{ii} = '';
                vidNumber(ii) = 0;
            end
        end
        % eliminate duplicated video times
        idxToEliminate = (vidNumber == 0);
        if any(idxToEliminate)
            updatedTimeStrArray = {};
            vidNumber = vidNumber(~idxToEliminate);
            numUpdatedTimes = 0;
            for ii = 1 : numValidVids
                if ~idxToEliminate(ii)
                    numUpdatedTimes = numUpdatedTimes + 1;
                    updatedTimeStrArray{numUpdatedTimes} = vidTimeStr{ii};
                end
            end
            vidTimeStr = updatedTimeStrArray;
        end
        numValidVids = length(vidNumber);
        
        % sort videos by timestamp
        vidTimeNum = zeros(numValidVids,1);
        for ii = 1 : numValidVids
            vidTimeNum(ii) = datenum(vidTimeStr{ii},'HH:MM:SS');
        end
        [sortedTime, idx] = sort(vidTimeNum);
        vidNumber = vidNumber(idx);
        
        oldVidTimeStr = vidTimeStr;
        for ii = 1 : numValidVids
            vidTimeStr{ii} = oldVidTimeStr{idx(ii)};
        end
        % there are occasionally two video files with differen timestamps
        % but the same video number from within a single recording session.
        % When this happens, the second video with the same number somehow
        % got triggered but doesn't contain a reach (I think - we haven't
        % systematically verified this, but it seems to be true).
        vidNumberDelta = diff(vidNumber);
        repeatNumIdx = (vidNumberDelta == 0);
        if any(repeatNumIdx)
            repeatNumIdx = [false;repeatNumIdx];
            updatedTimeStrArray = {};
            vidNumber = vidNumber(~repeatNumIdx);
            numUpdatedTimes = 0;
            for ii = 1 : numValidVids
                if ~repeatNumIdx(ii)
                    numUpdatedTimes = numUpdatedTimes + 1;
                    updatedTimeStrArray{numUpdatedTimes} = vidTimeStr{ii};
                end
            end
            vidTimeStr = updatedTimeStrArray;
        end
        finalVidNumber = vidNumber;
        

        lastSessionEndNumber = 0;
        for ii = 1 : length(vidNumber)-1
            if vidNumber(ii+1) <= vidNumber(ii)    % this must be a point where the computer crashed
                lastSessionEndNumber = lastSessionEndNumber + vidNumber(ii);
            end
            finalVidNumber(ii+1) = lastSessionEndNumber + vidNumber(ii+1);
        end

        
        finalVidTimeStr = cell(maxTrials,1);%blanks(8);
        for ii = 1 : finalVidNumber(end)
            vidNumIdx = (finalVidNumber == ii);
%             vidNum = 
            if ~any(vidNumIdx)
                finalVidTimeStr{ii} = blanks(8);
            else
                finalVidTimeStr{ii} = vidTimeStr{vidNumIdx};
            end
        end
        
        if numValidDates == 1
            finalCell{1,1} = 'Trial';
            for ii = 1 : maxTrials
                finalCell{ii+1} = ii;
            end
        end
        for ii = 1 : maxTrials
            finalCell{ii+1,numValidDates+1} = finalVidTimeStr{ii};
        end
        finalCell{1,numValidDates+1} = curDateStr;
%         headerCellArray{1,numValidDates+1} = curDateStr;
        
%         sheetName = sprintf('R%03d',ratID);
%         if numValidDates == 1
%             trialHeaderCell = sprintf('A%d',trialRow);
%             trialListCell = sprintf('A%d',trialRow + 1);
%             xlswrite(xl_file,'Trial',sheetName,trialHeaderCell);
%             xlswrite(xl_file,numArrayToWrite,sheetName,trialListCell);
%         end
%         dateCell = [num2letters(numValidDates + 1), num2str(trialRow+1)];
    end
    
    fileID = fopen(text_file,'w');
    [nrows,ncols] = size(finalCell);
    firstRowFormatSpec = '%s,';
    otherRowFormatSpec = '%d,';
    for iCol = 2 : ncols-1
        firstRowFormatSpec = [firstRowFormatSpec '%s,'];
        otherRowFormatSpec = [otherRowFormatSpec '%s,'];
    end
    firstRowFormatSpec = [firstRowFormatSpec '%s\n'];
    otherRowFormatSpec = [otherRowFormatSpec '%s\n'];
    fprintf(fileID,firstRowFormatSpec,finalCell{1,:});
    for iRow = 2 : nrows
        fprintf(fileID, otherRowFormatSpec,finalCell{iRow,:});
    end
        
    fclose(fileID);
end