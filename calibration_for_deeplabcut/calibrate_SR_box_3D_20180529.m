% script to calculate calibration matrices given points labelled in Fiji
% these are distorted images, so all points need to be undistorted using
% the camera matrix before calculating 3D transformations

% will need the camera matrix to remove distortion

% 
cal_imgFolder = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% cal_imgFolder = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';

calibrationFileLabel = 'GridCalibration';   % all calibration file names should begin with this string
m_checkerboard = 3;   % number of rows in each checkerboard
n_checkerborad = 4;   % number of columns in each checkerboard
checkSpacing = 8;     % checkerboard spacing in mm

% first, load in the marked points

% any x-coordinate less than 400 is from the left mirror
% any x-coordinate greater than 1600 is the right mirror
% any y-coordinate less than 400 is the top mirror

% in .csv files, put points in the following order:

% 1-12: left direct view
% 13-24: top direct view
% 25-36: right direct view
% 37-48: left mirror
% 49-60: top mirror
% 61-72: right mirror

cd(cal_imgFolder);
cal_imgList = dir([calibrationFileLabel '_*.png']);
num_cal_img = length(cal_imgList);
% extract session dates from cal_imgList names
sessionDates = cell(1);
numUniqueSessions = 0;
for i_img = 1 : num_cal_img
    dateStartIdx = length(calibrationFileLabel) + 2;
    dateEndIdx = dateStartIdx + 7;
    curDate = cal_imgList(i_img).name(dateStartIdx : dateEndIdx);
    
    if any(strcmp(sessionDates,curDate))
        continue;
    end
    
    numUniqueSessions = numUniqueSessions + 1;
    sessionDates{numUniqueSessions} = curDate;
end

for iDate = 1 : numUniqueSessions
    
    test_csv_string = [calibrationFileLabel '_' sessionDates{iDate} '_*.csv'];

    sessionCSVlist = dir(test_csv_string);
    
    num_csv = length(sessionCSVlist);
    
    for i_csv = 1 : num_csv
        
        % code to read in .csv file here
    end
end
