function [csvFiles_from_same_boxdate, boxList, datesForBox] = group_csv_files_by_boxdate(csvList)
%
% INPUTS
%   csvList - list of potential files of calibration images stored in the
%       file structure returned by 'dir'. file names should be of the
%       format 'GridCalibration_yyyymmdd_#.png' where # is the file index
%       (1,2,3,etc) and yyyymmdd is the date
%
% OUTPUTS
%   csvFiles_from_same_boxdate
%   dateList

boxList = [];
csvFiles_from_same_boxdate.box = [];
csvFiles_from_same_boxdate.date = datetime;
csvFiles_from_same_boxdate.picTimes = datetime;
csvFiles_from_same_boxdate.fnames = {};
datesForBox = {};    % list of dates for an individual box

for iFile = 1 : length(csvList)
    
    if contains(lower(csvList(iFile).name),'box')
        C = textscan(lower(csvList(iFile).name),'gridcalibration_box%d_%8s_%8s_*');
        curBox = C{1};
        fileDateString = C{2}{1};
        picTimeString = C{3}{1};
        fullDateTimeString = [fileDateString '-' picTimeString];
        fileDate = datetime(fileDateString,'inputformat','yyyyMMdd');
        picTime = datetime(fullDateTimeString,'inputformat','yyyyMMdd-HH-mm-ss');
    else
        C = textscan(lower(csvList(iFile).name),'gridcalibration_%8s_*');
        fileDateString = C{1}{1};
        fileDate = datetime(fileDateString,'inputformat','yyyyMMdd');
        curBox = 99;
        picTime = datetime([fileDateString '-00-00-01'],'inputformat','yyyyMMdd-HH-mm-ss');
    end        
    boxIdx = find(boxList == curBox);
    
    if iFile == 1
        % first file, so of course need a new structure for this box/date
        % combination
        csvFiles_from_same_boxdate.box = curBox;
        csvFiles_from_same_boxdate.date = fileDate;
        csvFiles_from_same_boxdate.picTimes = picTime;
        csvFiles_from_same_boxdate.fnames{1} = csvList(iFile).name;
        boxList = curBox;
        datesForBox{1}(1) = fileDate;
    elseif length(datesForBox) <= boxIdx   % this box has already been found
        if any(ismember(datesForBox{boxIdx},fileDate))   % has the current date already been found for this box?
            % yes, it has
            % find the imFiles_from_same_boxdate structure for this box/date
            % combination
            for i_boxDate = 1 : length(csvFiles_from_same_boxdate)
                if (csvFiles_from_same_boxdate(i_boxDate).box == curBox && ...
                    csvFiles_from_same_boxdate(i_boxDate).date == fileDate)
                    % another file for this box/date combo
                    csvFiles_from_same_boxdate(i_boxDate).fnames{end+1} = csvList(iFile).name;
                    csvFiles_from_same_boxdate(i_boxDate).picTimes(end+1) = picTime;
                end
            end
        else
            % this box has been used before, but not for this date
            csvFiles_from_same_boxdate(end+1).box = curBox;
            csvFiles_from_same_boxdate(end).date = fileDate;
            csvFiles_from_same_boxdate(end).picTimes = picTime;
            csvFiles_from_same_boxdate(end).fnames{1} = csvList(iFile).name;
            
            datesForBox{boxIdx}(end+1) = fileDate;
        end
    else   % this box hasn't been used before
        boxList(end+1) = curBox;
        boxIdx = length(boxList);
        csvFiles_from_same_boxdate(end+1).box = curBox;
        csvFiles_from_same_boxdate(end).date = fileDate;
        csvFiles_from_same_boxdate(end).picTimes = picTime;
        csvFiles_from_same_boxdate(end).fnames{1} = csvList(iFile).name;
        datesForBox{boxIdx} = fileDate;
    end
    
end 
    
end