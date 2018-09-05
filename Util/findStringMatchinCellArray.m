function match_idx = findStringMatchinCellArray(cell_array, str_fragment)

stringSearch = strfind(cell_array,str_fragment);

match_idx = zeros(length(stringSearch),1);
for ii = 1 : length(stringSearch)
    
    match_idx = ~isempty(stringSearch{ii});
    
end

end