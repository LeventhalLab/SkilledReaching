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

% for iField = 1 : size(ratTable_in,2)
%     
%     fieldName = ratTable_in.Properties.VariableNames{iField};
%     
%     if isdatetime(ratTable_in.(fieldName))
%         
%        ratTable_out.(fieldName).Year(ratTable_in.(fieldName).Year < 100) = ...
%            ratTable_in.(fieldName).Year(ratTable_in.(fieldName).Year < 100) + 2000;
%     end
% end

for iCol = 1 : size(ratTable_in,2)
    
    if isdatetime(ratTable_in{:,iCol})
        
        ratTable_out{:,iCol}.Year(ratTable_in{:,iCol}.Year < 100) = ...
            ratTable_in{:,iCol}.Year(ratTable_in{:,iCol}.Year < 100) + 2000;
        
    end
    
end