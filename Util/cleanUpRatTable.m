function ratTable_out = cleanUpRatTable(ratTable_in)
%
% make sure all numeric data are entered as numbers and not strings/cells.
% Also turn appropriate cell arrays into categorical data

numericFields = {'ratID'};
    
categoricalFields = {'Sex',...
                     'Virus',...
                     'trainingLevel',...
                     'laserWavelength',...
                     'laserTiming',...
                     'pawPref',...
                     'digitColors',...
                     'virusLot'};
                 
ratTable_out = ratTable_in;

for iField = 1 : length(numericFields)
    
    if iscell(ratTable_in.(numericFields{iField}))
        
        ratTable_out.(numericFields{iField}) = ...
            cells_to_array(ratTable_in.(numericFields{iField}));
        
    end
    
end

for iField = 1 : length(categoricalFields)
        
        ratTable_out.(categoricalFields{iField}) = ...
            categorical(ratTable_in.(categoricalFields{iField}));
    
end
