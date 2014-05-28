function logData = readLogData(directory)
dirs=dir(fullfile(directory,'*.log'));
fname= dirs(1).name;
%
% usage: logData = readLogData( fname )
%
% INPUTS:
%   fname - name of the .log file
%
% OUTPUTS:
%   logData - structure with the following fields:
%       fileVersion (uint16) - version of the logData file written by LabView
%       taskID (uint8) - this is a task identifier (ie, stop-signal,
%           go-nogo, simple choice, RL, food-water, etc.). This number
%           should match with the code used in the sql database
%       taskVersion - version number of the specific task. This differs
%           from "fileVersion" in that fileVersion refers to the log file
%           structure, while "taskVersion" refers to the version of the
%           actual data written for the specific task
%       subject - string containing the subject name. Max 10 characters in
%           fileVersion 1
%       date - string containing the data formatted as yyyymmdd
%       startTime - string containing 24-hour start time based on the
%           behavior computer clock, in 'HH:MM' format.
%       comment - string containing a session comment (max 1024 characters)
%
%       After that is a collection of "header" fields. The names of these
%           fields are written into the .log file. These are parameters
%           that do not change over the course of a session and are
%           task-specific.
%
%       After that comes the actual data. The structure data field names
%           are also written into the .log file and are task-specific.

bitOrder = 'b';

commentLength = 200;
fid = fopen(fullfile(directory,fname), 'r');

logData.fileVersion = fread(fid, 1, 'uint16', 0, bitOrder);
logData.taskID      = fread(fid, 1, 'uint8', 0, bitOrder);
logData.taskVersion = fread(fid, 1, 'uint8', 0, bitOrder);
logData.subject     = deblank(fread(fid, 10, '*char')');
logData.date        = fread(fid, 8, '*char')';
logData.startTime   = fread(fid, 5, '*char')';

fseek(fid, 2 * 1024, 'bof');

logData.comment = deblank(fread(fid, 1024, '*char')');

fseek(fid, 3 * 1024, 'bof');
% read in the header fields
fullHeaderString = deblank(fread(fid, 1024, '*char')');
dlmIdx = findstr(fullHeaderString, ',');   % find the location of all the commas
dlmIdx = [0, dlmIdx, length(fullHeaderString)+1];
numHeaderFields = length(dlmIdx) - 1;
headerFieldNames = cell(1, numHeaderFields);

for iField = 1 : numHeaderFields
    headerFieldNames{iField} = fullHeaderString(dlmIdx(iField)+1:dlmIdx(iField+1)-1);
end

fseek(fid, 4 * 1024, 'bof');
% read in the values for the header fields
for iField = 1 : numHeaderFields
    logData.(headerFieldNames{iField}) = fread(fid, 1, 'double', 0, bitOrder);
end

fseek(fid, 5 * 1024, 'bof');
% read in the data fields
fullDataString = deblank(fread(fid, 1024, '*char')');
dlmIdx = findstr(fullDataString, ',');   % find the location of all the commas
dlmIdx = [0, dlmIdx, length(fullDataString)+1];
numDataFields = length(dlmIdx) - 1;
dataFieldNames = cell(1, numDataFields);
for iField = 1 : numDataFields
    dataFieldNames{iField} = fullDataString(dlmIdx(iField)+1:dlmIdx(iField+1)-1);
end

fseek(fid, 6 * 1024, 'bof');
% read in the actual data
data = fread(fid, [numDataFields, inf], 'double', 0, bitOrder);
if ~isempty(data)
for iField = 1 : numDataFields
    logData.(dataFieldNames{iField}) = data(iField, :)';
end    
end
fclose(fid);