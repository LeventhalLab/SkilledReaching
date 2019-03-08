function ratTable_out = cleanUpRatTable(ratTable_in)
%
% make sure all numeric data are entered as numbers and not strings/cells.
% Also turn appropriate cell arrays into categorical data, and make sure
% excel dates (which seem to start counting at 2000) are converted to dates
% after 2000 for matlab. That is, if excel codes a date as 1/1/0017, change
% it to 1/1/2017
%
% INPUTS
%   ratTable_in - matlab table with experiment-specific information for
%       each rat. data are still somewhat disorganized (numbers stored in
%       cells, dates as strings, etc.)
%
% OUTPUTS
%   ratTable_out - matlab table containing information about each rat, with
%       the modifications described above

dateFormat = 'MM/dd/yyyy';

numericFields = {'ratID'};

% change this to match experiment-specific information stored in the
% ratInfo .csv file
categoricalFields = {'Sex',...
                     'Virus',...
                     'trainingLevel',...
                     'laserWavelength',...
                     'laserTiming',...
                     'pawPref',...
                     'digitColors',...
                     'virusLot'};

% change this to match experiment-specific information stored in the
% ratInfo .csv file
dateFields = {'virusDate',...
              'fiberDate',...
              'firstDatePretraining',...
              'firstDateTraining',...
              'lastDateRetraining',...
              'firstDateLaser',...
              'lastDateLaser',...
              'firstDateOcclusion',...
              'lastDateOcclusion'};
                 
ratTable_out = ratTable_in;

for iField = 1 : length(numericFields)
    
    if iscell(ratTable_in.(numericFields{iField}))
        
        ratTable_out.(numericFields{iField}) = ...
            cells_to_array(ratTable_in.(numericFields{iField}));
        
    end
    
end

for iField = 1 : length(dateFields)
    
    if iscell(ratTable_in.(dateFields{iField}))
        
        ratTable_out.(dateFields{iField}) = ...
            datetime(ratTable_in.(dateFields{iField}),'inputformat',dateFormat);
        
    end
    
end

for iField = 1 : length(categoricalFields)
        
        ratTable_out.(categoricalFields{iField}) = ...
            categorical(ratTable_in.(categoricalFields{iField}));
    
end

for iCol = 1 : size(ratTable_in,2)
    
    if isdatetime(ratTable_out{:,iCol})

        ratTable_out{:,iCol}.Year(ratTable_out{:,iCol}.Year < 100) = ...
            ratTable_out{:,iCol}.Year(ratTable_out{:,iCol}.Year < 100) + 2000;
        
    end
    
end