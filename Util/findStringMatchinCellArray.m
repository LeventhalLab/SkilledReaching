function match_idx = findStringMatchinCellArray(cell_array, str_fragment)

stringSearch = strfind(cell_array,str_fragment);

match_idx = false(length(stringSearch),1);
for ii = 1 : length(stringSearch)
    
    match_idx(ii) = ~isempty(stringSearch{ii});
    
end

end