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
% WORKING HERE...



sessionFields = fieldnames(sessions_to_extract);
ratTableOut = ratInfo;

for iField = 1 : length(exptFields)
    % the field 'type' is just an identifier for the type of experiment
    % (e.g., chr2 during reaches, arch between reaches, etc)
    if strcmpi(sessions_to_extract{iField},'type')
        continue
    end
    
    % if field value is irrelevant, don't pull out any rows
    if strcmpi(experimentInfo.(exptFields{iField}),'any')
        continue;
    end
    
    ratTableOut = extractTableRows(ratTableOut,exptFields{iField},experimentInfo.(exptFields{iField}));

end