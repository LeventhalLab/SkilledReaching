function [sessionType] = determineSessionType(thisRatInfo, sessionDate)

% 'pretraining'
% 'training'
% 'laser_during'
% 'laser_between'
% 'occlusion'
% 'alternating'

if ~isdatetime(sessionDate)
    sessionType.type = 'undefined';
    sessionType.daysInBlock = NaN;
    sessionType.daysUntilBlockEnd = NaN;
    return;
end

if isnat(sessionDate)
    sessionType.type = 'undefined';
    sessionType.daysInBlock = NaN;
    sessionType.daysUntilBlockEnd = NaN;
    return;
end

if isdatetime(thisRatInfo.firstDatePretraining)
    firstDatePretraining = thisRatInfo.firstDatePretraining;
    if firstDatePretraining.Year < 100
        firstDatePretraining.Year = firstDatePretraining.Year + 2000;
    end
else
    firstDatePretraining = NaT;
end
if isdatetime(thisRatInfo.firstDateTraining)
    firstDateTraining = thisRatInfo.firstDateTraining;
    if firstDateTraining.Year < 100
        firstDateTraining.Year = firstDateTraining.Year + 2000;
    end
else
    firstDateTraining = NaT;
end
if isdatetime(thisRatInfo.lastDateRetraining)
    lastDateRetraining = thisRatInfo.lastDateRetraining;
    if lastDateRetraining.Year < 100
        lastDateRetraining.Year = lastDateRetraining.Year + 2000;
    end
else
    lastDateRetraining = NaT;
end
if isdatetime(thisRatInfo.firstDateLaser)
    firstDateLaser = thisRatInfo.firstDateLaser;
    if firstDateLaser.Year < 100
        firstDateLaser.Year = firstDateLaser.Year + 2000;
    end
else
    firstDateLaser = NaT;
end
if isdatetime(thisRatInfo.lastDateLaser)
    lastDateLaser = thisRatInfo.lastDateLaser;
    if lastDateLaser.Year < 100
        lastDateLaser.Year = lastDateLaser.Year + 2000;
    end
else
    lastDateLaser = NaT;
end
if isdatetime(thisRatInfo.firstDateOcclusion)
    firstDateOcclusion = thisRatInfo.firstDateOcclusion;
    if firstDateOcclusion.Year < 100
        firstDateOcclusion.Year = firstDateOcclusion.Year + 2000;
    end
else
    firstDateOcclusion = NaT;
end
if isdatetime(thisRatInfo.lastDateOcclusion)
    lastDateOcclusion = thisRatInfo.lastDateOcclusion;
    if lastDateOcclusion.Year < 100
        lastDateOcclusion.Year = lastDateOcclusion.Year + 2000;
    end
else
    lastDateOcclusion = NaT;
end

% is this a pre-training session?
if ~isnat(firstDateTraining) && ~isnat(firstDatePretraining)
    
    if sessionDate >= firstDatePretraining && sessionDate < firstDateTraining

        sessionType.type = 'pretraining';
        sessionType.daysInBlock = days(sessionDate - firstDatePretraining) + 1;
        sessionType.daysUntilBlockEnd = days(firstDateTraining - sessionDate) - 1;
        return

    end
    
end

% is this a training session?
% re-work this later once the ratInfo table is completely filled in; for
% now, consider anything before lastDateRetraining as "training"
% comment the next line back in later
% if ~isnat(firstDateTraining) && ~isnat(lastDateRetraining)
    
if ~isnat(lastDateRetraining)
    
    % comment below line back in once rat table is filled out
%     if sessionDate >= firstDateTraining && sessionDate <= lastDateRetraining
        
    if sessionDate <= lastDateRetraining

        sessionType.type = 'training';
        sessionType.daysInBlock = days(sessionDate - firstDateTraining) + 1;
        sessionType.daysUntilBlockEnd = days(lastDateRetraining - sessionDate);
        return

    end
    
end

% is this a laser stimulation session?
if ~isnat(firstDateLaser) && ~isnat(lastDateLaser)
    
    if sessionDate >= firstDateLaser && sessionDate <= lastDateLaser

        switch lower(thisRatInfo.laserTiming{1})
            case 'during reach'
                sessionType.type = 'laser_during';
            case 'between reach'
                sessionType.type = 'laser_between';
        end
        sessionType.daysInBlock = days(sessionDate - firstDateLaser) + 1;
        sessionType.daysUntilBlockEnd = days(lastDateLaser - sessionDate);
        return;
    end
    
end

if ~isnat(firstDateOcclusion) && ~isnat(lastDateOcclusion)
    
    if sessionDate >= firstDateOcclusion && sessionDate <= lastDateOcclusion

        sessionType.type = 'occlusion';
        sessionType.daysInBlock = days(sessionDate - firstDateOcclusion) + 1;
        sessionType.daysUntilBlockEnd = days(lastDateOcclusion - sessionDate);
        return
    end
    
end

% if couldn't indentify the trial type
sessionType.type = 'undefined';
sessionType.daysInBlock = NaN;
sessionType.daysUntilBlockEnd = NaN;
