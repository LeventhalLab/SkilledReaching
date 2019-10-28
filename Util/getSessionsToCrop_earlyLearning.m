function sessions_to_crop = getSessionsToCrop_earlyLearning(sessionTable)
%
%
% extract all sessions starting with the last 2 training sessions

    
% divide sessionTable into blocks of similar sessions
sessionBlockLabels = identifySessionTransitions(sessionTable);
% sessions_remaining = calcSessionsRemainingFromBlockLabels(sessionBlockLabels);

% find the table row with the second-to-last "retraining" session
trainingRows = sessionTable.trainingStage == 'training';
startRow = find(trainingRows,1,'first');
endRow = find(trainingRows,1,'last');

sessions_to_crop = sessionTable(startRow:endRow,:);
