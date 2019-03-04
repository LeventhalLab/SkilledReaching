function ratTable_out = cleanUpRatTable(ratTable_in)
%
% make sure all numeric data are entered as numbers and not strings/cells.
% Also turn appropriate cell arrays into categorical data

dateFormat = 'MM/dd/yyyy';

numericFields = {'ratID'};
    
categoricalFields = {'Sex',...
                     'Virus',...
                     'trainingLevel',...
                     'laserWavelength',...
                     'laserTiming',...
                     'pawPref',...
                     'digitColors',...
                     'virusLot'};
                 
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