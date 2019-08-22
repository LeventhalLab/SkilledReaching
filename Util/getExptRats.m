function ratTableOut = getExptRats(ratInfo,experimentInfo)
%
% INPUTS
%   ratInfo - table of information about each rat in the skilled reaching
%       experiment
%   experimentInfo - structure with fields that match with ratInfo column
%       headers
%
% OUTPUTS
%   ratTableOut - table of rows from ratInfo that match with experimentInfo

exptFields = fieldnames(experimentInfo);
ratTableOut = ratInfo;

for iField = 1 : length(exptFields)
    % the field 'type' is just an identifier for the type of experiment
    % (e.g., chr2 during reaches, arch between reaches, etc)
    if strcmpi(exptFields{iField},'type')
        continue
    end
    
    % if field value is irrelevant, don't pull out any rows
    if strcmpi(experimentInfo.(exptFields{iField}),'any')
        continue;
    end
    
    ratTableOut = extractTableRows(ratTableOut,exptFields{iField},experimentInfo.(exptFields{iField}));

end