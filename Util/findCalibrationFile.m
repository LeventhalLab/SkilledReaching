function [calFileName, lastValidCalDate] = findCalibrationFile(mainCalibrationDir, sessionDate)

sessionYear = sessionDate(1:4);
sessionMonth = sessionDate(1:6);
        
foundValidCalFile = false;

while ~foundValidCalFile
    calibrationYearDir = fullfile(mainCalibrationDir, sessionYear);
    calibrationMonthDir = fullfile(calibrationYearDir,[sessionMonth '_calibration'],[sessionMonth '_calibration_files']);

    cd(calibrationMonthDir);
    calFileList = dir('SR_boxCalibration_*.mat');
    calDateList = cell(1,length(calFileList));
    calDateNums = zeros(length(calFileList),1);
    for iFile = 1 : length(calFileList)
        C = textscan(calFileList(iFile).name,'SR_boxCalibration_%8c.mat');
        calDateList{iFile} = C{1};
        calDateNums(iFile) = str2double(calDateList{iFile});
    end

    curDateNum = str2double(sessionDate);
    dateDiff = curDateNum - calDateNums;

    lastValidCalDate = min(dateDiff(dateDiff >= 0));
    if isempty(lastValidCalDate)    % there are no sessions in this month before the current date
        % look back one month
        monthNum = str2double(sessionMonth(5:6));
        if monthNum > 1
            new_monthNum = monthNum - 1;
        else
            sessionYear = num2str(str2double(sessionYear) - 1);
            new_monthNum = 12;
        end
        sessionMonth = sprintf('%s%02d',sessionYear,new_monthNum);
    else
        foundValidCalFile = true;
    end
    
end

calFileIdx = find(dateDiff == lastValidCalDate);

calFileName = ['SR_boxCalibration_' calDateList{calFileIdx} '.mat'];
calFileName = fullfile(calibrationMonthDir,calFileName);