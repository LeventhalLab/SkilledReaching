function sessionTableOut = extractSpecificSessions(sessionTable,sessions_to_extract)
%
% INPUTS
%   sessionTable - table of information about each session in the skilled reaching
%       experiment
%   sessions_to_extract - structure with fields that match with sessionTable column
%       headers
%
% OUTPUTS
%   sessionTableOut - table of rows from sessionTable that match with experimentInfo


% divide sessionTable into blocks of similar sessions
sessionBlockLabels = identifySessionTransitions(sessionTable);
sessions_remaining = calcSessionsRemainingFromBlockLabels(sessionBlockLabels);

sessionFields = fieldnames(sessions_to_extract);
sessionTableOut = sessionTable;

for iField = 1 : length(sessionFields)
    switch sessions_to_extract{iField}
        case 'sessions_remaining'
            validRows = (sessions_remaining == sessions_to_extract)
            sessionTableOut = sessionTableOut(
            sessions_remaining = sessions_remaining
    end
    
    % if field value is irrelevant, don't pull out any rows
    if strcmpi(experimentInfo.(exptFields{iField}),'any')
        continue;
    end
    
    ratTableOut = extractTableRows(ratTableOut,exptFields{iField},experimentInfo.(exptFields{iField}));
    
end