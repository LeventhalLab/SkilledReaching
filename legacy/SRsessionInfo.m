function sessionInfo = SRsessionInfo(ratInfo, sessionDate)
%
% create a structure that describes where the current session fits in the
% experiment (i.e., first day laser, 5th day laser, nth day occlusion,
% etc.)
%
% INPUTS
%
% OUTPUTS
%


sessionDateNum = datenum(sessionDate,'yyyymmdd');

lastDateRetrainingNum = datenum(ratInfo.lastDateRetraining,'yyyymmdd');
firstDateLaserNum = datenum(ratInfo.firstDateLaser,'yyyymmdd');
lastDateLaserNum = datenum(ratInfo.lastDateLaser,'yyyymmdd');
firstDateOcclusionNum = datenum(ratInfo.firstDateOcclusion,'yyyymmdd');
firstDateTrainingNum = datenum(ratInfo.firstDateTraining,'yyyymmdd');
lastDateOcclusionNum = datenum(ratInfo.lastDateOcclusion,'yyyymmdd');


% NEED TO THINK ABOUT HOW TO DEAL WITH DAYS OFF
if sessionDateNum <= lastDateRetrainingNum
    sessionInfo.sessionType = 'training';
    sessionInfo.dayFromBlockStart = sessionDateNum - firstDateTrainingNum + 1;
    sessionInfo.dayFromBlockEnd = lastDateRetrainingNum - sessionDateNum;
end

if sessionDateNum >= firstDateLaserNum && sessionDateNum <= lastDateLaserNum
    sessionInfo.sessionType = 'laser';
    
    
    
if sessionDateNum >= firstDateOcclusionNum && sessionDateNum <= lastDateLaserNum
    sessionInfo.sessionType = 'occlusion';