function new_array = removeRow(old_array, row_idx_to_remove)
%
% function to remove specific rows from a 2-D array
%
% INPUTS:
%   old_array - original 2-D array
%   row_idx_to_remove - vector containing indices of rows to cut out
%
% OUTPUTS:
%   new_array - old_array with the rows indicated by row_idx_to_remove cut
%       out

new_array = old_array;
for ii = 1 : length(row_idx_to_remove)
    
    switch row_idx_to_remove(ii)
        case 1,
        
            if size(new_array,1) > 1
                new_array = new_array(2:end,:);
            else
                new_array = [];
            end
            if ii < length(row_idx_to_remove)
                row_idx_to_remove(ii+1:end) = row_idx_to_remove(ii+1:end) - 1;
            end
        
        case size(new_array,1),
        
            new_array = new_array(1:end-1,:);
        
        otherwise,
            
            temp1 = new_array(1:row_idx_to_remove(ii)-1,:);
            temp2 = new_array(row_idx_to_remove(ii)+1:end,:);
            new_array = [temp1;temp2];
            
            if ii < length(row_idx_to_remove)
                row_idx_to_remove(row_idx_to_remove > row_idx_to_remove(ii)) = ...
                    row_idx_to_remove(row_idx_to_remove > row_idx_to_remove(ii)) - 1;
            end
            
    end
    
end