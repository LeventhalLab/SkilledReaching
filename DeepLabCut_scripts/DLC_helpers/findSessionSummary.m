function [sessionSummaryName,varargout] = findSessionSummary(ratID, sessionDate,varargin)
%
% INPUTS
%   ratID - rat ID as either an integer or string (e.g., 'R0100' will give
%       the same result as 100)
%   sessionDate - date on which the session was recorded - can be either a
%       string in 'yyyymmdd' format or a matlab datetime object
%
% OUTPUTS
%
DLCdirectory = '/Volumes/LL EXHD #2/DLC output';

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'dlcdirectory'
            DLCdirectory = varargin{iarg + 1};
    end
end

if isnumeric(ratID)
    ratID = sprintf('R%04d',ratID);
end

if isdatetime(sessionDate)
    sessionDate = datestr(sessionDate,'yyyymmdd');
end

rat_DLCfolder = fullfile(DLCdirectory,ratID);

cd(rat_DLCfolder);
sessionString = [ratID '_' sessionDate];
sessionSummaryName = [sessionString '_kinematicsSummary.mat'];

sessionDir = dir([sessionString, '*']);   % need to do it this way in case there's an "a" or "b" session on the same date
sessionFolder = fullfile(rat_DLCfolder,sessionDir(1).name);

sessionSummaryName = fullfile(sessionFolder,sessionSummaryName);
varargout{1} = true;

if ~exist(sessionSummaryName,'file')
    varargout{1} = false;
end