function [calFileName, lastValidCalDate] = findCalibrationFile(mainCalibrationDir, boxNum, sessionDate)
%
% function to find the relevant calibration file for a given session
% performed in a given skilled reaching box/chamber
%
% INPUTS:
%   mainCalibrationDir - path to the parent calibration files directory
%   boxNum - integer - number of the reaching box to get the calibration
%       file for
%   sessionDate - date on which the videos were recorded
%
% OUTPUTS:
%   calFileName - name of the calibration .mat file including path
%   lastValidCalDate - most recent date for which a calibration file was
%       found for this box (hopefully same day videos were generated...)

% Calibration Files Directory Structure
% -	Parent directory
% o	Year (e.g., ‘2018’)
% 	YYYYMM_calibration (e.g., ‘201810_calibration’ would contain calibration images/files for October, 2018)
% •	YYYYMM_all_marked – contains images/.mat files with coordinates of all checkerboard points (automatically detected and manually marked)
% •	YYYYMM_auto_marked – contains images/.mat files with coordinates of all automatically detected checkerboard points
% •	YYYYMM_calibration_files – calibration files. These are .mat files containing fundamental, essential matrices, etc.
% •	YYYYMM_manually_marked – calibration images that have been manually marked in Fiji, as well as .csv files containing checkerboard corner coordinates

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
    calBoxNums = zeros(length(calFileList),1);
    for iFile = 1 : length(calFileList)
        C = textscan(calFileList(iFile).name,'SR_boxCalibration_box%d_%8c.mat');
        calBoxNums(iFile) = C{1};
        calDateList{iFile} = C{2};
        calDateNums(iFile) = str2double(calDateList{iFile});
    end
    validCalFiles = calBoxNums == boxNum;
    validCalDates = calDateList(validCalFiles);
    validCalDateNums = calDateNums(validCalFiles);
    
    curDateNum = str2double(sessionDate);
    dateDiff = curDateNum - validCalDateNums;

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

calFileName = sprintf('SR_boxCalibration_box%02d_%s.mat',boxNum,validCalDates{calFileIdx});
calFileName = fullfile(calibrationMonthDir,calFileName);