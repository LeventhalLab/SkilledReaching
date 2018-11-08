function [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts,pawPref)
%
% INPUTS
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%
% OUTPUTS
%   mcp_idx - 

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

nose_idx = find(findStringMatchinCellArray(bodyparts, 'nose'));
pellet_idx = find(findStringMatchinCellArray(bodyparts, 'pellet'));
% poss_paw_idx = find(findStringMatchinCellArray(bodyparts, 'paw'));

if iscategorical(pawPref)
    pawPref = char(pawPref);
end

switch pawPref
    case 'left'
        otherPaw = 'rightpaw';
    case 'right'
        otherPaw = 'leftpaw';
end
pawdorsum_idx = find(findStringMatchinCellArray(bodyparts, [pawPref 'pawdorsum']));
otherpaw_idx = find(findStringMatchinCellArray(bodyparts, otherPaw));
% 
% for ii = 1 : length(poss_paw_idx)
%     if poss_paw_idx(ii) ~= pawdorsum_idx
%         otherpaw_idx = poss_paw_idx(ii);
%         break;
%     end
% end

end