function [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts)
%
% INPUTS
%
% OUTPUTS
%

numDigits = 4;
mcp_idx = zeros(numDigits,1);
pip_idx = zeros(numDigits,1);
digit_idx = zeros(numDigits,1);
for iDigit = 1 : numDigits
    mcp_string = sprintf('mcp%d',iDigit);
    pip_string = sprintf('pip%d',iDigit);
    digit_string = sprintf('digit%d',iDigit);
    
    mcp_idx(iDigit) = find(findStringMatchinCellArray(bodyparts, mcp_string));
    pip_idx(iDigit) = find(findStringMatchinCellArray(bodyparts, pip_string));
    digit_idx(iDigit) = find(findStringMatchinCellArray(bodyparts, digit_string));
end

pawdorsum_idx = find(findStringMatchinCellArray(bodyparts, 'pawdorsum'));
nose_idx = find(findStringMatchinCellArray(bodyparts, 'nose'));
pellet_idx = find(findStringMatchinCellArray(bodyparts, 'pellet'));
poss_paw_idx = find(findStringMatchinCellArray(bodyparts, 'paw'));

for ii = 1 : length(poss_paw_idx)
    if poss_paw_idx(ii) ~= pawdorsum_idx
        otherpaw_idx = poss_paw_idx(ii);
        break;
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function match_idx = findStringMatchinCellArray(cell_array, str_fragment)

stringSearch = strfind(cell_array,str_fragment);

match_idx = zeros(length(stringSearch),1);
for ii = 1 : length(stringSearch)
    
    match_idx = ~isempty(stringSearch{ii});
    
end

end