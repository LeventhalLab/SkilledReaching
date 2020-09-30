function sessions_to_crop = getSessionsToCrop_earlyLearning(sessionTable)
%
%
% extract the first 10 training sessions

    
% divide sessionTable into blocks of similar sessions
% sessionBlockLabels = identifySessionTransitions(sessionTable);
% sessions_remaining = calcSessionsRemainingFromBlockLabels(sessionBlockLabels);

% find the table row with the second-to-last "retraining" session
trainingRows = sessionTable.trainingStage == 'training';
startRow = find(trainingRows,1,'first');
lastTrainingRow = find(trainingRows,1,'last');

twentiethTrainingRow = startRow + 19;

endRow = min(lastTrainingRow,twentiethTrainingRow);


sessions_to_crop = sessionTable(startRow:endRow,:);
