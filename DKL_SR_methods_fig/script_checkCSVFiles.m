% script_checkCSVFiles

% isCSVvalid = 1 --> valid csv file, at least by matching vid numbers with
%                    valid csv file scores
%              2 --> mismatch between video numbers and valid scores
%              3 --> no csv file (or improperly named)
%              4 --> more than one csv file in the processed data directory

sr_ratInfo = get_sr_RatList();

isCSVvalid = cell(1,length(sr_ratInfo));
sessionLists = cell(1,length(sr_ratInfo));

for i_rat = 1 : length(sr_ratInfo)
    
    sessionList = sr_ratInfo(i_rat).sessionList;
    processedDir = sr_ratInfo(i_rat).directory.processed;
    rawdataDir = sr_ratInfo(i_rat).directory.rawdata;
    
    ratID = sr_ratInfo(i_rat).ID;
    sessionLists{i_rat} = sessionList;
    
    for iSession = 1 : numSessions
        
        sessionName = sessionList{iSession};
        fprintf('rat %s, %s\n',ratID, sessionName);
        
        fullSessionName = [ratID '_' sessionName];
        
        
        vidDir = fullfile(rawdataDir, fullSessionName);

        cd(vidDir);
        vidList = dir('*.avi');
        numVids = 0;
        % count number of actual videos
        vidNumbers = [];
        for iVid = 1 : length(vidList)
            if strcmp(vidList(iVid).name(1:2),'._')
                continue;
            end
            numVids = numVids + 1;
            vidNumbers = [vidNumbers, str2num(vidList(iVid).name(end-6:end-4))];
        end
        vidNumbers = vidNumbers';
        
        dirName = fullfile(processedDir, fullSessionName);
        cd(dirName)
        
        % find the csv file
        csvName = [fullSessionName '.csv'];
        
        csvInfo = dir(csvName);
        
        if length(csvInfo) == 1
            fid = fopen(csvInfo.name);
            readInfo = textscan(fid,'%f %f %f %f %f %f','delimiter',',','HeaderLines',0);
            fclose(fid);

            csv_trialNums = readInfo{1};
            csv_scores = readInfo{2};
        
            validScoreIdx = find(~isnan(csv_scores));
            validTrialNums = csv_trialNums(validScoreIdx);

            if length(validScoreIdx) == length(vidNumbers)
                if validTrialNums == vidNumbers
                    isCSVvalid{i_rat}(iSession) = 1;
                else
                    isCSVvalid{i_rat}(iSession) = 2;
                end
            else
                isCSVvalid{i_rat}(iSession) = 2;
            end
            
        elseif isempty(csvInfo)
            isCSVvalid{i_rat}(iSession) = 3;
        else
            isCSVvalid{i_rat}(iSession) = 4;
        end
        
    end
    
end