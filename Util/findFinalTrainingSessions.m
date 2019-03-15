function sessionDatesOut = findFinalTrainingSessions(sessionsInfo, n)
%
% find the dates of the last n training sessions before testing started
%
% INPUTS
%
% OUTUPUTS
%

% make sure sessions are ordered in the table by date acquired
sessionsInfo_sorted = sortrows(sessionsInfo,'date','ascend');

trainingStage = sessionsInfo_sorted.trainingStage;
firstTestingIdx = find(trainingStage == 'testing',1);

% if there are fewer than n sessions before testing started, start with
% session 1
startIdx = max(firstTestingIdx-n,1);
sessionDatesOut = sessionsInfo_sorted.date(startIdx:firstTestingIdx-1);
    