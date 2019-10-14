function new_sessionTable = getRetrainingThroughOcclusionSessions(sessionTable)
%
%
% extract all sessions starting with the last 2 training sessions

    
% divide sessionTable into blocks of similar sessions
sessionBlockLabels = identifySessionTransitions(sessionTable);
sessions_remaining = calcSessionsRemainingFromBlockLabels(sessionBlockLabels);

% find the table row with the second-to-last "retraining" session
retrainingRows = sessionTable.trainingStage == 'retraining';
startRow = find(retrainingRows,2,'last');
startRow = startRow(1);

% find the table row with the last "occlusion" sessions
occludeRows = (sessionTable.laserStim == 'occlude') | (sessionTable.laserStim == 'occluded');
endRow = find(occludeRows,1,'last');

new_sessionTable = sessionTable(startRow:endRow,:);
