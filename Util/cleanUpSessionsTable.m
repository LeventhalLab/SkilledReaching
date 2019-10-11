function sessionsTable_out = cleanUpSessionsTable(sessionsTable_in)
%
% make sure all numeric data are entered as numbers and not strings/cells.
% Also turn appropriate cell arrays into categorical data, and make sure
% excel dates (which seem to start counting at 2000) are converted to dates
% after 2000 for matlab. That is, if excel codes a date as 1/1/0017, change
% it to 1/1/2017
%
% INPUTS
%   sessionsTable_in - matlab table with experiment-specific information for
%       each rat. data are still somewhat disorganized (numbers stored in
%       cells, dates as strings, etc.)
%
% OUTPUTS
%   sessionsTable_out - matlab table containing information about each rat, with
%       the modifications described above

dateFormat = 'yyyyMMdd';

numericFields = {'ratID',...
                 'totalSessions',...
                 'session_in_block',...
                 'laserProbability',...
                 'frameRate',...
                 'preTriggerFrames',...
                 'postTriggerFrames'};

% change this to match experiment-specific information stored in the
% ratInfo .csv file
categoricalFields = {'trainingStage',...
                     'laserStim',...
                     'laserTrialSetting',...
                     'laserOnTiming',...
                     'laserOffTiming'};

% change this to match experiment-specific information stored in the
% ratInfo .csv file
dateFields = {'date'};
                 
sessionsTable_out = sessionsTable_in;

for iField = 1 : length(numericFields)
    
    if iscell(sessionsTable_in.(numericFields{iField}))
        
        sessionsTable_out.(numericFields{iField}) = ...
            cells_to_array(sessionsTable_in.(numericFields{iField}));
        
    end
    
end

for iField = 1 : length(dateFields)
    
    if iscell(sessionsTable_in.(dateFields{iField}))
        
        sessionsTable_out.(dateFields{iField}) = ...
            datetime(sessionsTable_in.(dateFields{iField}),'inputformat',dateFormat);
        
    end
    
    if isnumeric(sessionsTable_out.(dateFields{iField}))
        sessionsTable_out.(dateFields{iField}) = ...
            datetime(sessionsTable_in.(dateFields{iField}),'convertfrom','yyyymmdd');
    end
    
end

for iField = 1 : length(categoricalFields)
        
        sessionsTable_out.(categoricalFields{iField}) = ...
            categorical(sessionsTable_in.(categoricalFields{iField}));
    
end

for iCol = 1 : size(sessionsTable_in,2)
    
    if isdatetime(sessionsTable_out{:,iCol})

        sessionsTable_out{:,iCol}.Year(sessionsTable_out{:,iCol}.Year < 100) = ...
            sessionsTable_out{:,iCol}.Year(sessionsTable_out{:,iCol}.Year < 100) + 2000;
        
    end
    
end