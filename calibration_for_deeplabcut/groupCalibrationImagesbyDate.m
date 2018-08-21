function [imFiles_from_same_date, dateList] = groupCalibrationImagesbyDate(imgList)
%
% INPUTS
%   imgList - list of potential files of calibration images stored in the
%       file structure returned by 'dir'. file names should be of the
%       format 'GridCalibration_yyyymmdd_#.png' where # is the file index
%       (1,2,3,etc) and yyyymmdd is the date
%
% OUTPUTS
%   imFiles_from_same_date
%   dateList

dateList = cell(1);
imFiles_from_same_date = {};
numDates = 0;
numFiles_perDate = 0;
for iFile = 1 : length(imgList)
    
    if ~isempty(strfind(imgList(iFile).name,'marked'))
        continue;
    end
    
    C = textscan(lower(imgList(iFile).name),'gridcalibration_%8s_*');
    
    dateIdx = strcmp(dateList, C{1}{1});
    
    if ~any(dateIdx)
        % first time this date was found
        numDates = numDates + 1;
        dateList{numDates} = C{1}{1};
        
        imFiles_from_same_date{numDates}{1} = imgList(iFile).name;
        numFiles_perDate(numDates) = 1;
    else
        numFiles_perDate(dateIdx) = numFiles_perDate(dateIdx) + 1;
        imFiles_from_same_date{dateIdx}{numFiles_perDate(dateIdx)} = imgList(iFile).name;
    end
    
end 
    
end