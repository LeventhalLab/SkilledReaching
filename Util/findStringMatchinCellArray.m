function match_idx = findStringMatchinCellArray(cell_array, str_fragment)
%
% INPUTS
%   cell_array - cell array of strings
%   str_fragment - character array containing fragment of a string to look
%       for in cell_array
%
% OUTPUTS
%   match_idx - boolean vector with true for any element of cell_array that
%       contains str_fragment

stringSearch = strfind(cell_array,str_fragment);

match_idx = false(length(stringSearch),1);
for ii = 1 : length(stringSearch)
    
    match_idx(ii) = ~isempty(stringSearch{ii});
    
end

end