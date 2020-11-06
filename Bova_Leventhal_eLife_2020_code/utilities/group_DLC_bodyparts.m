function [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts,pawPref)
%
% INPUTS
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   pawPref - 'left' or 'right'
%
% OUTPUTS
%   mcp_idx - indices of mcp knuckles in bodyparts
%   pip_idx - indices of pip knuckles in bodyparts
%   digit_idx - indices of digit tips in bodyparts
%   pawdorsum_idx - index of the reaching paw dorsum in bodyparts
%   nose_idx - index of the nose in bodyparts
%   pellet_idx - index of the pellet in bodyparts
%   otherpaw_idx - index of the non-reaching paw in bodyparts

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

end