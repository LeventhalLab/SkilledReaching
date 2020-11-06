function [sessionType] = determineSessionType(thisRatInfo, sessionDates, varargin)
%
% INPUTS
%   thisRatInfo - information about this rat extracted from the rat info 
%       table
%   sessionDates - character array of dates (each row is a string containing
%       a date)
%
% VARARGS
%   csvdateformat - format string for converting strings to datetime
%       objects. default is YYYYMMDD
%
% OUTPUTS
%   sessionType - structure with an element for each sessionDate, with the
%       following fields:
%       .date - date for that session (datetime object)
%       .type - what type of session? possibilities in Leventhal lab are
%               'pretraining'
%               'training'
%               'laser_during'
%               'laser_between'
%               'occlusion'
%               'alternating'
%               'post_occlusion'
%       .sessionsInBlock - number of sessions performed of the same type in
%           the current block
%       

csvDateFormat = '';
for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'csvdateformat'
            csvDateFormat = varargin{iarg + 1};
    end
end

sessionDates = convertToDateTime(sessionDates,csvDateFormat);

sessionDates = sort(sessionDates);
numSessions = length(sessionDates);

numPreTrainingSessions = 0;
numTrainingSessions = 0;
numLaserSessions = 0;
numOcclusionSessions = 0;
numPostOcclusionSessions = 0;

laserTiming = thisRatInfo.laserTiming;
if iscategorical(laserTiming)
    laserTiming = char(laserTiming);
end
if iscell(laserTiming)
    laserTiming = laserTiming{1};
end

for iSession = 1 : numSessions
    
    sessionDate = sessionDates(iSession);
    
    sessionType(iSession).date = sessionDate;
    
    firstDatePretraining = convertToDateTime(thisRatInfo.firstDatePretraining,csvDateFormat);
    firstDateTraining = convertToDateTime(thisRatInfo.firstDateTraining,csvDateFormat);
    lastDateRetraining = convertToDateTime(thisRatInfo.lastDateRetraining,csvDateFormat);
    firstDateLaser = convertToDateTime(thisRatInfo.firstDateLaser,csvDateFormat);
    lastDateLaser = convertToDateTime(thisRatInfo.lastDateLaser,csvDateFormat);
    firstDateOcclusion = convertToDateTime(thisRatInfo.firstDateOcclusion,csvDateFormat);
    lastDateOcclusion = convertToDateTime(thisRatInfo.lastDateOcclusion,csvDateFormat);

    % is this a pre-training session?
    if ~isnat(firstDateTraining) && ~isnat(firstDatePretraining)
        if sessionDate >= firstDatePretraining && sessionDate < firstDateTraining
            sessionType(iSession).type = 'pretraining';
            numPreTrainingSessions = numPreTrainingSessions + 1;
            sessionType(iSession).sessionsInBlock = numPreTrainingSessions;
%             sessionType(iSession).sessionsLeftInBlock = days(firstDateTraining - sessionDate) - 1;
            continue
        end
    end

% is this a training session?
% re-work this later once the ratInfo table is completely filled in; for
% now, consider anything before lastDateRetraining as "training"
    
    if ~isnat(lastDateRetraining)
        % comment below line back in once rat table is filled out
        if sessionDate <= lastDateRetraining
            sessionType(iSession).type = 'training';
            numTrainingSessions = numTrainingSessions + 1;
            sessionType(iSession).sessionsInBlock = numTrainingSessions;
            continue
        end
    end

    % is this a laser stimulation session?
    if ~isnat(firstDateLaser) && ~isnat(lastDateLaser)
        if sessionDate >= firstDateLaser && sessionDate <= lastDateLaser
            switch lower(laserTiming)
                case 'during reach'
                    sessionType(iSession).type = 'laser_during';
                case 'between reach'
                    sessionType(iSession).type = 'laser_between';
            end
            numLaserSessions = numLaserSessions + 1;
            sessionType(iSession).sessionsInBlock = numLaserSessions;
            continue;
        end

    end

    % is this an occlusion session
    if ~isnat(firstDateOcclusion) && ~isnat(lastDateOcclusion)
        if sessionDate >= firstDateOcclusion && sessionDate <= lastDateOcclusion
            sessionType(iSession).type = 'occlusion';
            numOcclusionSessions = numOcclusionSessions + 1;
            sessionType(iSession).sessionsInBlock = numOcclusionSessions;
    %         sessionType(iSession).sessionsLeftInBlock = days(lastDateOcclusion - sessionDate);
            continue
        end
    end

    if ~isnat(lastDateOcclusion)
        if sessionDate > lastDateOcclusion
            sessionType(iSession).type = 'post_occlusion';
            numPostOcclusionSessions = numPostOcclusionSessions + 1;
            sessionType(iSession).sessionsInBlock = numPostOcclusionSessions;
            continue
        end
    end
    % if couldn't indentify the trial type
    sessionType(iSession).type = 'undefined';
    sessionType(iSession).sessionsInBlock = NaN;
    sessionType(iSession).sessionsLeftInBlock = NaN;
end

for iSession = 1 : numSessions
    switch lower(sessionType(iSession).type)
        case 'pretraining'
            sessionType(iSession).sessionsLeftInBlock = numPreTrainingSessions - sessionType(iSession).sessionsInBlock;
        case 'training'
            sessionType(iSession).sessionsLeftInBlock = numTrainingSessions - sessionType(iSession).sessionsInBlock;
        case {'laser_during','laser_between'}
            sessionType(iSession).sessionsLeftInBlock = numLaserSessions - sessionType(iSession).sessionsInBlock;
        case 'occlusion'
            sessionType(iSession).sessionsLeftInBlock = numOcclusionSessions - sessionType(iSession).sessionsInBlock;
        case 'alternating'
            sessionType(iSession).sessionsLeftInBlock = numAlternatingSessions - sessionType(iSession).sessionsInBlock;
        case 'post_occlusion'
            sessionType(iSession).sessionsLeftInBlock = numPostOcclusionSessions - sessionType(iSession).sessionsInBlock;
    end
end


end   % function


