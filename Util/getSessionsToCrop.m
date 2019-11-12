function sessions_to_crop = getSessionsToCrop(sessionTable)
%
%
% extract all sessions starting with the last 2 training sessions

    
% divide sessionTable into blocks of similar sessions
sessionBlockLabels = identifySessionTransitions(sessionTable);
sessions_remaining = calcSessionsRemainingFromBlockLabels(sessionBlockLabels);

% find the table row with the second-to-last "retraining" session
retrainingRows = sessionTable.trainingStage == 'retraining';% | sessionTable.trainingStage == 'training';
startRow = find(retrainingRows,2,'last');
startRow = startRow(1);

sessions_to_crop = sessionTable(startRow:end,:);
